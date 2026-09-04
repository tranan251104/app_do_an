import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  final TokenStorage tokens;
  late final Dio dio;

  Completer<void>? _refreshCompleter;
  int _requestSequence = 0;

  ApiClient(this.tokens) {
    AppLogger.app('ApiClient initializing', {'baseUrl': AppConfig.apiBaseUrl});
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requestId = ++_requestSequence;
          options.extra['_debugRequestId'] = requestId;
          options.extra['_debugStartedAt'] = DateTime.now().millisecondsSinceEpoch;

          final token = await tokens.accessToken();
          final hasAccessToken = token != null && token.isNotEmpty;
          if (hasAccessToken) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          AppLogger.api(
            '--> REQUEST',
            {
              'id': requestId,
              'method': options.method,
              'url': options.uri.toString(),
              'hasAccessToken': hasAccessToken,
              'query': AppLogger.sanitize(options.queryParameters),
              'body': AppLogger.sanitize(options.data),
              'headerKeys': options.headers.keys.toList(),
            },
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          final requestId = response.requestOptions.extra['_debugRequestId'];
          final startedAt = response.requestOptions.extra['_debugStartedAt'] as int?;
          final durationMs = startedAt == null
              ? null
              : DateTime.now().millisecondsSinceEpoch - startedAt;

          AppLogger.api(
            '<-- RESPONSE',
            {
              'id': requestId,
              'status': response.statusCode,
              'method': response.requestOptions.method,
              'url': response.requestOptions.uri.toString(),
              'durationMs': durationMs,
              'body': AppLogger.sanitize(response.data),
            },
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final requestId = error.requestOptions.extra['_debugRequestId'];
          final startedAt = error.requestOptions.extra['_debugStartedAt'] as int?;
          final durationMs = startedAt == null
              ? null
              : DateTime.now().millisecondsSinceEpoch - startedAt;

          AppLogger.error(
            'API',
            'XX REQUEST FAILED',
            error: error,
            data: {
              'id': requestId,
              'method': error.requestOptions.method,
              'url': error.requestOptions.uri.toString(),
              'status': status ?? 'NO_RESPONSE',
              'dioType': error.type.toString(),
              'durationMs': durationMs,
              'response': AppLogger.sanitize(error.response?.data),
            },
          );

          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            AppLogger.error(
              'API',
              'SERVER UNREACHABLE - backend/Docker may be stopped or baseUrl is wrong',
              error: error,
              data: {'baseUrl': AppConfig.apiBaseUrl},
            );
          } else if (error.type == DioExceptionType.receiveTimeout) {
            AppLogger.error(
              'API',
              'SERVER RECEIVE TIMEOUT',
              error: error,
            );
          } else if (error.type == DioExceptionType.sendTimeout) {
            AppLogger.error(
              'API',
              'SERVER SEND TIMEOUT',
              error: error,
            );
          } else if (status == 400) {
            AppLogger.warning('API', 'HTTP 400 BAD REQUEST');
          } else if (status == 401) {
            AppLogger.warning('API', 'HTTP 401 UNAUTHORIZED - trying token refresh when possible');
          } else if (status == 403) {
            AppLogger.error('API', 'HTTP 403 FORBIDDEN - server rejected permission/authentication');
          } else if (status == 404) {
            AppLogger.error('API', 'HTTP 404 NOT FOUND - check backend endpoint/path');
          } else if (status == 409) {
            AppLogger.warning('API', 'HTTP 409 CONFLICT');
          } else if (status != null && status >= 500) {
            AppLogger.error('API', 'HTTP $status SERVER ERROR');
          }

          final isRefreshCall = error.requestOptions.path.contains('/auth/refresh');

          if (status != 401 || isRefreshCall) {
            return handler.next(error);
          }

          final refresh = await tokens.refreshToken();
          if (refresh == null || refresh.isEmpty) {
            AppLogger.warning('AUTH', '401 received but no refresh token exists; clearing local session');
            await tokens.clear();
            return handler.next(error);
          }

          try {
            AppLogger.repo('AUTH', 'Starting automatic token refresh after 401');
            await _refreshSession(refresh);
            final access = await tokens.accessToken();
            if (access == null || access.isEmpty) {
              AppLogger.error('AUTH', 'Token refresh finished but no access token was stored');
              return handler.next(error);
            }

            final request = error.requestOptions;
            request.headers['Authorization'] = 'Bearer $access';
            AppLogger.repo(
              'AUTH',
              'Retrying original request after token refresh',
              {'method': request.method, 'url': request.uri.toString()},
            );
            final response = await dio.fetch<dynamic>(request);
            AppLogger.success('AUTH', 'Original request succeeded after token refresh');
            handler.resolve(response);
          } catch (refreshError, stackTrace) {
            AppLogger.error(
              'AUTH',
              'Automatic token refresh failed; clearing local session',
              error: refreshError,
              stackTrace: stackTrace,
            );
            await tokens.clear();
            handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _refreshSession(String refreshToken) async {
    if (_refreshCompleter != null) {
      AppLogger.repo('AUTH', 'Refresh already in progress; waiting for same refresh operation');
      return _refreshCompleter!.future;
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;

    try {
      final plain = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      AppLogger.api('--> REFRESH TOKEN REQUEST', {'url': '${AppConfig.apiBaseUrl}/auth/refresh'});
      final response = await plain.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken, 'deviceId': 'flutter-app'},
      );
      AppLogger.api('<-- REFRESH TOKEN RESPONSE', {'status': response.statusCode});

      final envelope = response.data;
      final data = envelope?['data'];
      if (data is! Map) {
        throw const ApiException(
          code: 'REFRESH_FAILED',
          message: 'Phiên đăng nhập đã hết hạn',
        );
      }

      await tokens.save(
        accessToken: data['accessToken'].toString(),
        refreshToken: data['refreshToken'].toString(),
      );
      AppLogger.success('AUTH', 'Token refresh succeeded');
      completer.complete();
    } catch (error, stack) {
      AppLogger.error(
        'AUTH',
        'Token refresh request failed',
        error: error,
        stackTrace: stack,
      );
      completer.completeError(error, stack);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  static ApiException mapError(Object error) {
    if (error is ApiException) {
      AppLogger.error(
        'API_MAP',
        'ApiException propagated',
        error: error,
        data: {'code': error.code, 'statusCode': error.statusCode},
      );
      return error;
    }
    if (error is DioException) {
      final body = error.response?.data;
      if (body is Map) {
        final apiError = body['error'];
        if (apiError is Map) {
          final mapped = ApiException(
            code: apiError['code']?.toString() ?? 'API_ERROR',
            message: apiError['message']?.toString() ?? 'Có lỗi xảy ra',
            statusCode: error.response?.statusCode,
          );
          AppLogger.error(
            'API_MAP',
            'Backend error mapped to ApiException',
            error: mapped,
            data: {'code': mapped.code, 'statusCode': mapped.statusCode},
          );
          return mapped;
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        const mapped = ApiException(
          code: 'NETWORK_ERROR',
          message: 'Không thể kết nối tới máy chủ AnPay',
        );
        AppLogger.error('API_MAP', 'Network error mapped', error: mapped);
        return mapped;
      }

      final mapped = ApiException(
        code: 'HTTP_ERROR',
        message: 'Máy chủ trả về lỗi ${error.response?.statusCode ?? ''}'.trim(),
        statusCode: error.response?.statusCode,
      );
      AppLogger.error(
        'API_MAP',
        'HTTP error mapped',
        error: mapped,
        data: {'statusCode': mapped.statusCode},
      );
      return mapped;
    }

    final mapped = ApiException(code: 'UNKNOWN_ERROR', message: error.toString());
    AppLogger.error('API_MAP', 'Unknown error mapped', error: mapped);
    return mapped;
  }
}
