import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';

class BeneficiaryRepository {
  final ApiClient api;

  BeneficiaryRepository(this.api);

  Future<List<Map<String, dynamic>>> list({int page = 0, int size = 100}) async {
    AppLogger.repo('BENEFICIARY', 'LIST start', {'page': page, 'size': size});
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/beneficiaries',
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data?['data'];
      final content = data is Map ? data['content'] : null;
      final result = (content as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      AppLogger.success('BENEFICIARY', 'LIST success', {'count': result.length});
      return result;
    } catch (error, stackTrace) {
      AppLogger.error('BENEFICIARY', 'LIST failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    AppLogger.repo(
      'BENEFICIARY',
      'CREATE start',
      {
        'type': body['type'],
        'bankName': body['bankName'],
        'accountNumber': AppLogger.mask(body['accountNumber']?.toString()),
      },
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/beneficiaries',
        data: body,
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'BENEFICIARY',
        'CREATE success',
        {'id': AppLogger.mask(data['id']?.toString())},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error('BENEFICIARY', 'CREATE failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<void> delete(String id) async {
    AppLogger.repo('BENEFICIARY', 'DELETE start', {'id': AppLogger.mask(id)});
    try {
      await api.dio.delete('/beneficiaries/$id');
      AppLogger.success('BENEFICIARY', 'DELETE success', {'id': AppLogger.mask(id)});
    } catch (error, stackTrace) {
      AppLogger.error('BENEFICIARY', 'DELETE failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }
}
