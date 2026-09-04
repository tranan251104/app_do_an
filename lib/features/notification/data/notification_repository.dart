import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/paged_result.dart';

class NotificationRepository {
  final ApiClient api;

  NotificationRepository(this.api);

  Future<PagedResult<Map<String, dynamic>>> list({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
    String category = 'ALL',
  }) async {
    AppLogger.repo('NOTIFICATION', 'LIST start', {
      'page': page,
      'size': size,
      'unreadOnly': unreadOnly,
      'category': category,
    });
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {
          'page': page,
          'size': size,
          'unreadOnly': unreadOnly,
          'category': category,
        },
      );
      final data = response.data?['data'];
      final result = PagedResult<Map<String, dynamic>>.fromSpringPage(
        data is Map ? Map<String, dynamic>.from(data) : null,
        (item) => item,
      );
      AppLogger.success('NOTIFICATION', 'LIST success', {
        'count': result.items.length,
        'page': result.page,
        'totalPages': result.totalPages,
        'totalElements': result.totalElements,
      });
      return result;
    } catch (error, stackTrace) {
      AppLogger.error(
        'NOTIFICATION',
        'LIST failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<int> unreadCount({String category = 'ALL'}) async {
    AppLogger.repo('NOTIFICATION', 'UNREAD COUNT start', {
      'category': category,
    });
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/notifications/unread-count',
        queryParameters: {'category': category},
      );
      final data = response.data?['data'];
      final count = data is Map
          ? (data['unreadCount'] as num?)?.toInt() ?? 0
          : 0;
      AppLogger.success('NOTIFICATION', 'UNREAD COUNT success', {
        'category': category,
        'count': count,
      });
      return count;
    } catch (error, stackTrace) {
      AppLogger.error(
        'NOTIFICATION',
        'UNREAD COUNT failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<void> read(String id) async {
    AppLogger.repo('NOTIFICATION', 'MARK READ start', {
      'id': AppLogger.mask(id),
    });
    try {
      await api.dio.patch('/notifications/$id/read');
      AppLogger.success('NOTIFICATION', 'MARK READ success', {
        'id': AppLogger.mask(id),
      });
    } catch (error, stackTrace) {
      AppLogger.error(
        'NOTIFICATION',
        'MARK READ failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<int> readAll({String category = 'ALL'}) async {
    AppLogger.repo('NOTIFICATION', 'MARK ALL READ start', {
      'category': category,
    });
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/notifications/read-all',
        queryParameters: {'category': category},
      );
      final changed = (response.data?['data'] as num?)?.toInt() ?? 0;
      AppLogger.success('NOTIFICATION', 'MARK ALL READ success', {
        'category': category,
        'changed': changed,
      });
      return changed;
    } catch (error, stackTrace) {
      AppLogger.error(
        'NOTIFICATION',
        'MARK ALL READ failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }
}
