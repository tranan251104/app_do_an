import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';

class QrRepository {
  final ApiClient api;

  QrRepository(this.api);

  Future<Map<String, dynamic>> mine() async {
    AppLogger.repo('QR', 'LOAD my QR start');
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/wallets/me/qr');
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success('QR', 'LOAD my QR success');
      return data;
    } catch (error, stackTrace) {
      AppLogger.error('QR', 'LOAD my QR failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> resolve(String value) async {
    AppLogger.repo('QR', 'RESOLVE QR start', {'valueLength': value.length});
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/qr/resolve',
        data: {'value': value},
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'QR',
        'RESOLVE QR success',
        {'type': data['type']?.toString(), 'walletCode': AppLogger.mask(data['walletCode']?.toString())},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error('QR', 'RESOLVE QR failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }
}
