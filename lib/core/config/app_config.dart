import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl {
    const override = String.fromEnvironment('ANPAY_API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kDebugMode &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'https://app-do-an-backend.onrender.com/api/v1';
  }
}
