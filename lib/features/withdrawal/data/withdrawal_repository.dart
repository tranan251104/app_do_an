import 'package:dio/dio.dart';
import 'package:app_do_an/core/network/api_client.dart';
import 'package:app_do_an/core/util/idempotency_key.dart';

/// Backend-only wallet debits. No client-side balance mutation.
class WithdrawalRepository {
  final ApiClient api;
  WithdrawalRepository(this.api);

  Future<List<Map<String, dynamic>>> linkedBanks() async {
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/linked-bank-accounts');
      final rows = (response.data?['data'] as List? ?? const []);
      return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> linkBank({
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/linked-bank-accounts',
        data: {
          'bankBin': bankBin.trim(),
          'bankName': bankName.trim(),
          'accountNumber': accountNumber.trim(),
          'accountName': accountName.trim(),
          'confirmOwnAccount': true,
        },
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> unlinkBank(String id) async {
    try {
      await api.dio.delete('/linked-bank-accounts/$id');
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> prepare({
    required String linkedBankAccountId,
    required int amount,
    String? note,
    String? idempotencyKey,
  }) async {
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/withdrawals/prepare',
        data: {
          'linkedBankAccountId': linkedBankAccountId,
          'amount': amount,
          'note': note?.trim(),
        },
        options: Options(headers: {
          'Idempotency-Key': idempotencyKey ?? IdempotencyKey.generate(),
        }),
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> resendOtp(String transactionId) async {
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/withdrawals/$transactionId/resend-otp',
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> confirm(String transactionId, String otp) async {
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/withdrawals/$transactionId/confirm',
        data: {'otp': otp},
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> cancel(String transactionId) async {
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/withdrawals/$transactionId/cancel',
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<Map<String, dynamic>> get(String transactionId) async {
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/withdrawals/$transactionId',
      );
      return Map<String, dynamic>.from(response.data?['data'] as Map);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}
