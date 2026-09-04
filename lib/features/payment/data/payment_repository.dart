import 'package:dio/dio.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../../core/util/idempotency_key.dart';

class PaymentRepository {
  final ApiClient api;

  PaymentRepository(this.api);

  /// Creates a DEV/LOCAL ANPAY payment intent.
  ///
  /// The backend owns the amount, transaction, ledger and wallet update.
  /// Flutter only receives a checkoutUrl and opens the ANPAY gateway page.
  Future<Map<String, dynamic>> createAnPayGatewayTopup(int amount) async {
    final key = IdempotencyKey.generate();
    AppLogger.repo(
      'PAYMENT',
      'ANPAY GATEWAY TOPUP create start',
      {'amount': amount, 'idempotencyKey': AppLogger.mask(key)},
    );

    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/payments/topups/mock',
        options: Options(headers: {'Idempotency-Key': key}),
        data: {'amount': amount},
      );

      final rawData = response.data?['data'];
      if (rawData is! Map) {
        throw const FormatException('Backend payment response has no data object');
      }

      final data = Map<String, dynamic>.from(rawData);
      AppLogger.success(
        'PAYMENT',
        'ANPAY GATEWAY TOPUP create success',
        {
          'paymentIntentId': AppLogger.mask(data['paymentIntentId']?.toString()),
          'orderCode': data['orderCode']?.toString(),
          'amount': data['amount'],
          'status': data['status']?.toString(),
          'checkoutUrlPresent': (data['checkoutUrl']?.toString().isNotEmpty ?? false),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'PAYMENT',
        'ANPAY GATEWAY TOPUP create failed',
        error: error,
        stackTrace: stackTrace,
        data: {'amount': amount},
      );
      throw ApiClient.mapError(error);
    }
  }
}
