import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';

class TransactionRepository {
  final ApiClient api;

  TransactionRepository(this.api);

  Future<PagedResult<Map<String, dynamic>>> list({
    int page = 0,
    int size = 20,
    String? type,
    String? direction,
    String? status,
    String? keyword,
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (type != null && type.isNotEmpty && type != 'ALL') 'type': type,
      if (direction != null && direction.isNotEmpty && direction != 'ALL')
        'direction': direction,
      if (status != null && status.isNotEmpty && status != 'ALL')
        'status': status,
      if (keyword != null && keyword.trim().isNotEmpty)
        'keyword': keyword.trim(),
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
    };

    AppLogger.repo('TRANSACTION', 'LIST start', {
      'page': page,
      'size': size,
      'type': type,
      'direction': direction,
      'status': status,
      'keyword': keyword,
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
    });

    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/transactions',
        queryParameters: query,
      );
      final envelope = response.data?['data'];
      final result = PagedResult<Map<String, dynamic>>.fromSpringPage(
        envelope is Map ? Map<String, dynamic>.from(envelope) : null,
        (item) => item,
      );
      AppLogger.success('TRANSACTION', 'LIST success', {
        'count': result.items.length,
        'page': result.page,
        'totalPages': result.totalPages,
        'totalElements': result.totalElements,
      });
      return result;
    } catch (error, stackTrace) {
      AppLogger.error(
        'TRANSACTION',
        'LIST failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> get(String id) async {
    AppLogger.repo('TRANSACTION', 'GET detail start', {
      'id': AppLogger.mask(id),
    });
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/transactions/$id',
      );
      final data = response.data?['data'];
      if (data is! Map) {
        throw const FormatException('Transaction detail response is invalid');
      }
      final result = Map<String, dynamic>.from(data);
      AppLogger.success('TRANSACTION', 'GET detail success', {
        'id': AppLogger.mask(id),
      });
      return result;
    } catch (error, stackTrace) {
      AppLogger.error(
        'TRANSACTION',
        'GET detail failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }
}
