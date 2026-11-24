import 'package:app_do_an/core/network/api_client.dart';

class SmartOtpRepository {
  final ApiClient api;
  SmartOtpRepository(this.api);

  Future<Map<String, dynamic>> status() async => _get('/smart-otp/status');
  Future<Map<String, dynamic>> authorization(String transactionId) async =>
      _get('/smart-otp/transactions/$transactionId');
  Future<Map<String, dynamic>> beginEnrollment(String publicKey) async =>
      _post('/smart-otp/enroll/start', {'publicKey': publicKey});
  Future<Map<String, dynamic>> confirmEnrollment(
    String deviceId, String otp,
  ) async => _post('/smart-otp/enroll/confirm',
      {'deviceId': deviceId, 'otp': otp});
  Future<void> revoke(String deviceId) async {
    try {
      await api.dio.delete('/smart-otp/devices/$deviceId');
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await api.dio.get<Map<String, dynamic>>(path);
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> payload) async {
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        path,
        data: payload,
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (error) {
      throw ApiClient.mapError(error);
    }
  }
}
