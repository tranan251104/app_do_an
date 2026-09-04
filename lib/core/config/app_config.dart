import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl {
    const override = String.fromEnvironment('ANPAY_API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://192.168.1.38:8080/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.38:8080/api/v1';
    }
    return 'http://192.168.1.38:8080/api/v1';
  }
}
