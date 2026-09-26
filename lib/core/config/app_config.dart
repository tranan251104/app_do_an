import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl {
    const override = String.fromEnvironment('ANPAY_API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'https://app-do-an-backend.onrender.com/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://app-do-an-backend.onrender.com/api/v1';
    }
    return 'https://app-do-an-backend.onrender.com/api/v1';
  }
}
