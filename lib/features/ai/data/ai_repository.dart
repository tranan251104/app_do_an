import 'package:app_do_an/core/network/api_client.dart';
import 'package:app_do_an/core/logging/app_logger.dart';

class AiRepository {
  final ApiClient _apiClient;

  AiRepository(this._apiClient);

  Future<String> chat(String message) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai/chat',
        data: {'message': message},
      );
      
      final data = response.data;
      if (data != null && data['success'] == true && data['data'] != null) {
        return data['data']['reply']?.toString() ?? "Xin lỗi, tôi không thể xử lý câu trả lời.";
      }
      throw Exception(data?['error']?['message'] ?? 'Phản hồi không hợp lệ từ máy chủ.');
    } catch (e) {
      AppLogger.error('AI_REPO', 'Chat failed', error: e);
      throw ApiClient.mapError(e);
    }
  }
}
