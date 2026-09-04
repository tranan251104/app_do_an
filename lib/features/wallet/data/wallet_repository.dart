import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';

class WalletRepository {
  final ApiClient api;

  WalletRepository(this.api);

  Future<Map<String, dynamic>> me() async {
    AppLogger.repo('WALLET', 'LOAD wallet start');
    try {
      final response = await api.dio.get<Map<String, dynamic>>('/wallets/me');
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'WALLET',
        'LOAD wallet success',
        {
          'walletCode': AppLogger.mask(data['walletCode']?.toString()),
          'availableBalance': data['availableBalance'],
          'balance': data['balance'],
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error('WALLET', 'LOAD wallet failed', error: error, stackTrace: stackTrace);
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> accountNumberStatus() async {
    AppLogger.repo('WALLET_NUMBER', 'Checking wallet account-number setup status');
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/wallets/account-number/status',
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'WALLET_NUMBER',
        'Account-number setup status loaded',
        {
          'walletCreated': data['walletCreated'] == true,
          'walletCode': AppLogger.mask(data['walletCode']?.toString()),
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WALLET_NUMBER',
        'Account-number setup status failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> checkAccountNumber(String digitsOrCode) async {
    AppLogger.repo(
      'WALLET_NUMBER',
      'Checking beautiful account number',
      {'candidate': _maskCandidate(digitsOrCode)},
    );
    try {
      final response = await api.dio.get<Map<String, dynamic>>(
        '/wallets/account-number/check',
        queryParameters: {'code': digitsOrCode},
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'WALLET_NUMBER',
        'Beautiful account number checked',
        {
          'walletCode': _maskCandidate(data['walletCode']?.toString()),
          'available': data['available'] == true,
        },
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WALLET_NUMBER',
        'Beautiful account number check failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> claimAccountNumber(String digitsOrCode) async {
    AppLogger.repo(
      'WALLET_NUMBER',
      'Claiming beautiful account number',
      {'candidate': _maskCandidate(digitsOrCode)},
    );
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/wallets/account-number/claim',
        data: {'walletCode': digitsOrCode},
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'WALLET_NUMBER',
        'Beautiful account number claimed',
        {'walletCode': _maskCandidate(data['walletCode']?.toString())},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WALLET_NUMBER',
        'Beautiful account number claim failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  Future<Map<String, dynamic>> assignRandomAccountNumber() async {
    AppLogger.repo('WALLET_NUMBER', 'Requesting random AnPay account number');
    try {
      final response = await api.dio.post<Map<String, dynamic>>(
        '/wallets/account-number/random',
      );
      final data = Map<String, dynamic>.from(response.data?['data'] as Map);
      AppLogger.success(
        'WALLET_NUMBER',
        'Random AnPay account number assigned',
        {'walletCode': _maskCandidate(data['walletCode']?.toString())},
      );
      return data;
    } catch (error, stackTrace) {
      AppLogger.error(
        'WALLET_NUMBER',
        'Random AnPay account number assignment failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiClient.mapError(error);
    }
  }

  String _maskCandidate(String? value) {
    if (value == null || value.isEmpty) return '<empty>';
    final normalized = value.toUpperCase();
    if (normalized.length <= 6) return '***';
    return '${normalized.substring(0, 3)}***${normalized.substring(normalized.length - 3)}';
  }
}
