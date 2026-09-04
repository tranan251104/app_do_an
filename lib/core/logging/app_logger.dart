import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight debug logger for the Flutter app.
///
/// Goals:
/// - make every important user action visible in Android Studio / Logcat;
/// - make navigation, API calls, repositories and failures easy to follow;
/// - never print passwords, tokens or OTP values.
class AppLogger {
  AppLogger._();

  static int _sequence = 0;

  static void app(String message, [Map<String, Object?>? data]) =>
      _write('APP', message, data);

  static void action(String message, [Map<String, Object?>? data]) =>
      _write('ACTION', message, data);

  static void navigation(String message, [Map<String, Object?>? data]) =>
      _write('NAV', message, data);

  static void api(String message, [Map<String, Object?>? data]) =>
      _write('API', message, data);

  static void repo(String area, String message, [Map<String, Object?>? data]) =>
      _write(area.toUpperCase(), message, data);

  static void success(String area, String message, [Map<String, Object?>? data]) =>
      _write('${area.toUpperCase()}_OK', message, data);

  static void warning(String area, String message, [Map<String, Object?>? data]) =>
      _write('${area.toUpperCase()}_WARN', message, data);

  static void error(
    String area,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    final payload = <String, Object?>{
      if (data != null) ...data,
      if (error != null) 'error': error.toString(),
    };
    _write('${area.toUpperCase()}_ERR', message, payload);
    if (kDebugMode && stackTrace != null) {
      debugPrint('[${area.toUpperCase()}_STACK] $stackTrace');
    }
  }

  static String mask(String? value, {int keepStart = 3, int keepEnd = 3}) {
    if (value == null || value.isEmpty) return '';
    if (value.length <= keepStart + keepEnd) return '***';
    return '${value.substring(0, keepStart)}***${value.substring(value.length - keepEnd)}';
  }

  static dynamic sanitize(dynamic value, {String? key}) {
    final normalizedKey = key?.toLowerCase() ?? '';
    const hiddenParts = [
      'password',
      'token',
      'authorization',
      'otp',
      'secret',
      'credential',
    ];
    if (hiddenParts.any(normalizedKey.contains)) return '<redacted>';

    if (value is Map) {
      final output = <String, dynamic>{};
      value.forEach((k, v) {
        final keyText = k.toString();
        output[keyText] = sanitize(v, key: keyText);
      });
      return output;
    }
    if (value is Iterable) {
      final list = value.take(12).map((item) => sanitize(item)).toList();
      if (value.length > 12) list.add('<... ${value.length - 12} more>');
      return list;
    }
    final text = value?.toString();
    if (text != null) {
      final lower = text.toLowerCase();
      if (lower.startsWith('http://') ||
          lower.startsWith('https://') ||
          lower.startsWith('anpay://')) {
        final uri = Uri.tryParse(text);
        if (uri != null && uri.queryParameters.isNotEmpty) {
          final safeQuery = <String, String>{};
          for (final entry in uri.queryParameters.entries) {
            final queryKey = entry.key.toLowerCase();
            final sensitive = hiddenParts.any(queryKey.contains);
            safeQuery[entry.key] = sensitive ? '<redacted>' : entry.value;
          }
          final safeUrl = uri.replace(queryParameters: safeQuery).toString();
          if (safeUrl.length > 500) {
            return '${safeUrl.substring(0, 500)}...<truncated>';
          }
          return safeUrl;
        }
      }
      if (text.length > 500) {
        return '${text.substring(0, 500)}...<truncated>';
      }
    }
    return value;
  }

  static void _write(String tag, String message, Map<String, Object?>? data) {
    if (!kDebugMode) return;
    _sequence += 1;
    final time = DateTime.now().toIso8601String();
    final suffix = data == null || data.isEmpty ? '' : ' | ${sanitize(data)}';
    debugPrint('[$tag] #$_sequence $time $message$suffix');
  }
}

class AppRouteObserver extends NavigatorObserver {
  String _name(Route<dynamic>? route) {
    if (route == null) return '<null>';
    final settingsName = route.settings.name;
    if (settingsName != null && settingsName.isNotEmpty) return settingsName;
    return route.runtimeType.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.navigation(
      'PUSH',
      {'to': _name(route), 'from': _name(previousRoute)},
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.navigation(
      'POP',
      {'from': _name(route), 'to': _name(previousRoute)},
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppLogger.navigation(
      'REPLACE',
      {'old': _name(oldRoute), 'new': _name(newRoute)},
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.navigation(
      'REMOVE',
      {'route': _name(route), 'previous': _name(previousRoute)},
    );
    super.didRemove(route, previousRoute);
  }
}
