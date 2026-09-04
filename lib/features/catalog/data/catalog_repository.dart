import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';

class CatalogRepository {
  final ApiClient api;

  CatalogRepository(this.api);

  Future<List<Map<String, dynamic>>> providers() async {
    AppLogger.repo('CATALOG', 'LOAD providers start');
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/catalog/providers');
      final result = _list(response.data?['data']);
      AppLogger.success('CATALOG', 'LOAD providers success', {'count': result.length});
      return result;
    } catch (error, stackTrace) {
      AppLogger.error('CATALOG', 'LOAD providers failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<List<Map<String, dynamic>>> products({String? category}) async {
    AppLogger.repo('CATALOG', 'LOAD products start', {'category': category});
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/catalog/products',
        queryParameters: {if (category != null) 'category': category},
      );
      final data = response.data?['data'];
      final result = _list(data is Map ? data['content'] : null);
      AppLogger.success(
        'CATALOG',
        'LOAD products success',
        {'category': category, 'count': result.length},
      );
      return result;
    } catch (error, stackTrace) {
      AppLogger.error('CATALOG', 'LOAD products failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<List<Map<String, dynamic>>> promotions() async {
    AppLogger.repo('CATALOG', 'LOAD promotions start');
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/promotions');
      final result = _list(response.data?['data']);
      AppLogger.success('CATALOG', 'LOAD promotions success', {'count': result.length});
      return result;
    } catch (error, stackTrace) {
      AppLogger.error('CATALOG', 'LOAD promotions failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<List<Map<String, dynamic>>> partners() async {
    AppLogger.repo('CATALOG', 'LOAD partners start');
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/partners');
      final result = _list(response.data?['data']);
      AppLogger.success('CATALOG', 'LOAD partners success', {'count': result.length});
      return result;
    } catch (error, stackTrace) {
      AppLogger.error('CATALOG', 'LOAD partners failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  static List<Map<String, dynamic>> _list(dynamic value) =>
      (value as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
}
