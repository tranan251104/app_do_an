import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../logging/app_logger.dart';

class TokenStorage {
  static const _accessKey = 'anpay_access_token';
  static const _refreshKey = 'anpay_refresh_token';
  static const _openedBeforeKey = 'anpay_has_opened_before';

  final FlutterSecureStorage _storage;

  const TokenStorage([this._storage = const FlutterSecureStorage()]);

  Future<String?> accessToken() async {
    final value = await _storage.read(key: _accessKey);
    AppLogger.repo('SESSION', 'Read access token', {'exists': value?.isNotEmpty ?? false});
    return value;
  }

  Future<String?> refreshToken() async {
    final value = await _storage.read(key: _refreshKey);
    AppLogger.repo('SESSION', 'Read refresh token', {'exists': value?.isNotEmpty ?? false});
    return value;
  }


  /// Returns true only on the very first cold launch after installation.
  ///
  /// The marker is stored separately from auth tokens, so clearing a session
  /// does not make the app look like a fresh install again.
  Future<bool> isFirstLaunchAndMark() async {
    final openedBefore = await _storage.read(key: _openedBeforeKey);
    final isFirstLaunch = openedBefore != 'true';

    AppLogger.repo(
      'SESSION',
      'App launch marker checked',
      {'isFirstLaunch': isFirstLaunch},
    );

    if (isFirstLaunch) {
      await _storage.write(key: _openedBeforeKey, value: 'true');
      AppLogger.success('SESSION', 'First-launch marker saved');
    }

    return isFirstLaunch;
  }

  Future<bool> hasSession() async {
    final access = await accessToken();
    final refresh = await refreshToken();
    final hasSession = (access?.isNotEmpty ?? false) || (refresh?.isNotEmpty ?? false);
    AppLogger.repo('SESSION', 'Session availability checked', {'hasSession': hasSession});
    return hasSession;
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    AppLogger.repo('SESSION', 'Saving session tokens');
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    AppLogger.success('SESSION', 'Session tokens saved');
  }

  Future<void> clear() async {
    AppLogger.repo('SESSION', 'Clearing local session tokens');
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    AppLogger.success('SESSION', 'Local session cleared');
  }
}
