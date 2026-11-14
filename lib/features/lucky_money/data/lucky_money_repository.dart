import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/paged_result.dart';

class LuckyEnvelope {
  final String id, reference, status, template, greeting;
  final String senderName, senderWalletCode, receiverName, receiverWalletCode;
  final int? amount;
  final bool isSender;
  final DateTime? otpExpiresAt, expiresAt, openedAt;

  LuckyEnvelope.fromJson(Map<String, dynamic> data)
    : id = data['id'] as String,
      reference = data['reference'] as String,
      status = data['status'] as String,
      template = data['template'] as String,
      greeting = data['greeting'] as String,
      senderName = data['senderName'] as String,
      senderWalletCode = data['senderWalletCode'] as String,
      receiverName = data['receiverName'] as String,
      receiverWalletCode = data['receiverWalletCode'] as String,
      amount = (data['amount'] as num?)?.toInt(),
      isSender = data['isSender'] == true,
      otpExpiresAt = DateTime.tryParse(data['otpExpiresAt']?.toString() ?? ''),
      expiresAt = DateTime.tryParse(data['expiresAt']?.toString() ?? ''),
      openedAt = DateTime.tryParse(data['openedAt']?.toString() ?? '');

  bool get canOpen => !isSender && status == 'WAITING_OPEN';
  String get statusLabel =>
      const {
        'OTP_REQUIRED': 'Chờ xác nhận OTP',
        'WAITING_OPEN': 'Chờ mở',
        'COMPLETED': 'Đã nhận',
        'EXPIRED': 'Hết hạn · Đã hoàn tiền',
      }[status] ??
      'Đang xử lý';
}

class LuckyMoneyRepository {
  final ApiClient api;
  LuckyMoneyRepository(this.api);

  Future<LuckyEnvelope> prepare({
    required String walletCode,
    required int amount,
    required String template,
    required String greeting,
    required String idempotencyKey,
  }) => _request(
    '/prepare',
    data: {
      'recipientWalletCode': walletCode.trim().toUpperCase(),
      'amount': amount,
      'template': template,
      'greeting': greeting.trim(),
    },
    options: Options(headers: {'Idempotency-Key': idempotencyKey}),
  );

  Future<LuckyEnvelope> get(String id) =>
      _request('/${Uri.encodeComponent(id)}', get: true);
  Future<LuckyEnvelope> confirm(String id, String otp) =>
      _request('/${Uri.encodeComponent(id)}/confirm', data: {'otp': otp});
  Future<LuckyEnvelope> resend(String id) =>
      _request('/${Uri.encodeComponent(id)}/resend-otp');
  Future<LuckyEnvelope> open(String id) =>
      _request('/${Uri.encodeComponent(id)}/open');

  Future<PagedResult<LuckyEnvelope>> list({
    required String box,
    int page = 0,
  }) async {
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/lucky-money',
        queryParameters: {'box': box, 'page': page},
      );
      return PagedResult.fromSpringPage(
        Map<String, dynamic>.from(response.data!['data'] as Map),
        LuckyEnvelope.fromJson,
      );
    } catch (error) {
      throw _error(error);
    }
  }

  Future<LuckyEnvelope> _request(
    String path, {
    bool get = false,
    Map<String, dynamic>? data,
    Options? options,
  }) async {
    try {
      final response = get
          ? await api.dio.get<Map<String, dynamic>>('/lucky-money$path')
          : await api.dio.post<Map<String, dynamic>>(
              '/lucky-money$path',
              data: data,
              options: options,
            );
      return LuckyEnvelope.fromJson(
        Map<String, dynamic>.from(response.data!['data'] as Map),
      );
    } catch (error) {
      throw _error(error);
    }
  }

  ApiException _error(Object error) {
    if (error is DioException &&
        const [404, 405, 501].contains(error.response?.statusCode)) {
      return const ApiException(
        code: 'LUCKY_MONEY_UNAVAILABLE',
        message:
            'Dịch vụ lì xì chưa sẵn sàng trên máy chủ. Vui lòng thử lại sau.',
      );
    }
    return ApiClient.mapError(error);
  }
}
