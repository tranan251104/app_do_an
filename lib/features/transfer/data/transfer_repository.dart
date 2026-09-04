import 'package:dio/dio.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/util/idempotency_key.dart';

class TransferRepository {
  final ApiClient api;

  TransferRepository(this.api);

  Future<Map<String, dynamic>> prepare({
    required String walletCode,
    required int amount,
    String? note,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? IdempotencyKey.generate();
    AppLogger.repo(
      'TRANSFER',
      'PREPARE start',
      {
        'recipientWallet': AppLogger.mask(walletCode),
        'amount': amount,
        'hasNote': note?.trim().isNotEmpty ?? false,
        'idempotencyKey': AppLogger.mask(key),
      },
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/transfers/prepare',
        options: Options(headers: {'Idempotency-Key': key}),
        data: {
          'recipientWalletCode': walletCode.trim(),
          'amount': amount,
          'note': note?.trim(),
        },
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'TRANSFER',
        'PREPARE success',
        {
          'transactionId': AppLogger.mask(data['transactionId']?.toString()),
          'reference': data['reference']?.toString(),
          'status': data['status']?.toString(),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'TRANSFER',
        'PREPARE failed',
        error: error,
        stackTrace: stackTrace,
        data: {'recipientWallet': AppLogger.mask(walletCode), 'amount': amount},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> confirm(String transferId, String otp) async {
    AppLogger.repo(
      'TRANSFER',
      'CONFIRM OTP start',
      {
        'transferId': AppLogger.mask(transferId),
        'otpLength': otp.length,
      },
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/transfers/$transferId/confirm',
        data: {'otp': otp},
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'TRANSFER',
        'CONFIRM success',
        {
          'transferId': AppLogger.mask(transferId),
          'status': data['status']?.toString(),
          'amount': data['amount'],
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'TRANSFER',
        'CONFIRM failed',
        error: error,
        stackTrace: stackTrace,
        data: {'transferId': AppLogger.mask(transferId)},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> resendOtp(String transferId) async {
    AppLogger.repo(
      'TRANSFER',
      'RESEND OTP start',
      {'transferId': AppLogger.mask(transferId)},
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/transfers/$transferId/resend-otp',
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'TRANSFER',
        'RESEND OTP success',
        {'transferId': AppLogger.mask(transferId)},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'TRANSFER',
        'RESEND OTP failed',
        error: error,
        stackTrace: stackTrace,
        data: {'transferId': AppLogger.mask(transferId)},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> get(String transferId) async {
    AppLogger.repo(
      'TRANSFER',
      'GET transfer status start',
      {'transferId': AppLogger.mask(transferId)},
    );
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/transfers/$transferId');
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'TRANSFER',
        'GET transfer status success',
        {'transferId': AppLogger.mask(transferId), 'status': data['status']?.toString()},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'TRANSFER',
        'GET transfer status failed',
        error: error,
        stackTrace: stackTrace,
        data: {'transferId': AppLogger.mask(transferId)},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> prepareExternal({
    required String bankBin,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required int amount,
    String? note,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? IdempotencyKey.generate();
    AppLogger.repo(
      'EXTERNAL_TRANSFER',
      'PREPARE start',
      {
        'bankBin': bankBin,
        'bankName': bankName,
        'account': AppLogger.mask(accountNumber),
        'accountName': AppLogger.mask(accountName),
        'amount': amount,
        'hasNote': note?.trim().isNotEmpty ?? false,
        'idempotencyKey': AppLogger.mask(key),
      },
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/external-transfers/prepare',
        options: Options(headers: {'Idempotency-Key': key}),
        data: {
          'bankBin': bankBin.trim(),
          'bankName': bankName.trim(),
          'accountNumber': accountNumber.trim(),
          'accountName': accountName.trim(),
          'amount': amount,
          'note': note?.trim(),
        },
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'EXTERNAL_TRANSFER',
        'PREPARE success',
        {
          'transactionId': AppLogger.mask(data['transactionId']?.toString()),
          'reference': data['reference']?.toString(),
          'status': data['status']?.toString(),
          'bank': data['bankName']?.toString(),
          'account': data['accountNumberMasked']?.toString(),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'EXTERNAL_TRANSFER',
        'PREPARE failed',
        error: error,
        stackTrace: stackTrace,
        data: {
          'bank': bankName,
          'account': AppLogger.mask(accountNumber),
          'amount': amount,
        },
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> confirmExternal(
    String transferId,
    String otp,
  ) async {
    AppLogger.repo(
      'EXTERNAL_TRANSFER',
      'CONFIRM OTP start',
      {
        'transferId': AppLogger.mask(transferId),
        'otpLength': otp.length,
      },
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/external-transfers/$transferId/confirm',
        data: {'otp': otp},
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'EXTERNAL_TRANSFER',
        'CONFIRM success',
        {
          'transferId': AppLogger.mask(transferId),
          'status': data['status']?.toString(),
          'amount': data['amount'],
          'bank': data['bankName']?.toString(),
          'providerReference': AppLogger.mask(
            data['providerReference']?.toString(),
          ),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'EXTERNAL_TRANSFER',
        'CONFIRM failed',
        error: error,
        stackTrace: stackTrace,
        data: {'transferId': AppLogger.mask(transferId)},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> resendExternalOtp(String transferId) async {
    AppLogger.repo(
      'EXTERNAL_TRANSFER',
      'RESEND OTP start',
      {'transferId': AppLogger.mask(transferId)},
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/external-transfers/$transferId/resend-otp',
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'EXTERNAL_TRANSFER',
        'RESEND OTP success',
        {'transferId': AppLogger.mask(transferId)},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'EXTERNAL_TRANSFER',
        'RESEND OTP failed',
        error: error,
        stackTrace: stackTrace,
        data: {'transferId': AppLogger.mask(transferId)},
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> getExternal(String transferId) async {
    AppLogger.repo(
      'EXTERNAL_TRANSFER',
      'GET status start',
      {'transferId': AppLogger.mask(transferId)},
    );
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/external-transfers/$transferId',
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'EXTERNAL_TRANSFER',
        'GET status success',
        {
          'transferId': AppLogger.mask(transferId),
          'status': data['status']?.toString(),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'EXTERNAL_TRANSFER',
        'GET status failed',
        error: error,
        stackTrace: stackTrace,
        data: {'transferId': AppLogger.mask(transferId)},
      );
      throw ApiClient.mapError(error);
    }
  }

}
