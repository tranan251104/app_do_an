import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:go_router/go_router.dart';

/// Centralized routing for notification actions coming from both the backend
/// notification center and FCM/local-notification taps.
///
/// A push can launch the app before the user has logged in. In that case we
/// keep one pending action and replay it once an authenticated tabbar screen is
/// available instead of opening a protected screen with an invalid session.
class NotificationNavigationService {
  NotificationNavigationService._();

  static GoRouter? _router;
  static Map<String, dynamic>? _pendingData;

  static void attachRouter(GoRouter router) {
    _router = router;
    openPendingIfAuthenticated();
  }

  static Future<bool> open(
    Map<String, dynamic> rawData, {
    String source = 'unknown',
    bool markRead = true,
  }) async {
    final data = Map<String, dynamic>.from(rawData);
    final actionType = _actionType(data);
    final transactionId = _transactionId(data);

    if (actionType == null && transactionId == null) {
      AppLogger.warning('NOTIFICATION_NAV', 'No actionable notification data', {
        'source': source,
        'keys': data.keys.toList(),
      });
      return false;
    }

    if (_isExpired(data) && actionType != 'OPEN_TRANSACTION') {
      AppLogger.warning('NOTIFICATION_NAV', 'Notification action has expired', {
        'source': source,
        'actionType': actionType,
      });
      return false;
    }

    final accessToken = await AppServices.tokens.accessToken();
    if (_router == null || accessToken == null || accessToken.isEmpty) {
      _pendingData = data;
      AppLogger.repo('NOTIFICATION_NAV', 'Notification action queued', {
        'source': source,
        'actionType': actionType,
        'hasRouter': _router != null,
        'authenticated': accessToken != null && accessToken.isNotEmpty,
      });
      return false;
    }

    if (markRead) {
      await _markReadBestEffort(data, source: source);
    }

    final handled = _navigate(data, source: source);
    if (handled) {
      _pendingData = null;
    }
    return handled;
  }

  static Future<bool> openPendingIfAuthenticated() async {
    final pending = _pendingData;
    if (pending == null) return false;

    final accessToken = await AppServices.tokens.accessToken();
    if (_router == null || accessToken == null || accessToken.isEmpty) {
      return false;
    }

    await _markReadBestEffort(pending, source: 'pending_after_login');
    final handled = _navigate(pending, source: 'pending_after_login');
    if (handled) {
      _pendingData = null;
    }
    return handled;
  }

  static bool _navigate(
    Map<String, dynamic> data, {
    required String source,
  }) {
    final router = _router;
    if (router == null) return false;

    final actionType = _actionType(data) ??
        (_transactionId(data) != null ? 'OPEN_TRANSACTION' : null);
    final transactionId = _transactionId(data);
    final navigationToken = _navigationToken(data);

    late final String location;
    switch (actionType) {
      case 'OPEN_TRANSACTION':
        location = _tabLocation(
          tab: 3,
          transactionId: transactionId,
          navigationToken: navigationToken,
        );
        break;
      case 'OPEN_PROMOTIONS':
        location = _tabLocation(
          tab: 1,
          navigationToken: navigationToken,
        );
        break;
      case 'OPEN_QR':
        location = _tabLocation(
          tab: 2,
          navigationToken: navigationToken,
        );
        break;
      case 'OPEN_TRANSFER':
        location = Uri(
          path: '/transfer',
          queryParameters: navigationToken == null
              ? null
              : {'notification': navigationToken},
        ).toString();
        break;
      case 'OPEN_MOBILE_TOPUP':
        location = _tabLocation(
          tab: 0,
          homeAction: 'phone_topup',
          navigationToken: navigationToken,
        );
        break;
      case 'OPEN_SERVICES':
        location = _tabLocation(
          tab: 0,
          homeAction: 'service_catalog',
          navigationToken: navigationToken,
        );
        break;
      default:
        AppLogger.warning('NOTIFICATION_NAV', 'Unsupported notification action', {
          'source': source,
          'actionType': actionType,
          'actionData': data['actionData']?.toString(),
        });
        return false;
    }

    AppLogger.action('NOTIFICATION deep link opened', {
      'source': source,
      'actionType': actionType,
      'location': location,
      'transactionId': AppLogger.mask(transactionId),
    });
    router.go(location);
    return true;
  }

  static Future<void> _markReadBestEffort(
    Map<String, dynamic> data, {
    required String source,
  }) async {
    final id = (data['notificationId'] ?? data['id'])?.toString().trim();
    if (id == null || id.isEmpty) return;

    try {
      await AppServices.notification.read(id);
    } catch (error, stackTrace) {
      AppLogger.error(
        'NOTIFICATION_NAV',
        'Could not mark pushed notification as read',
        error: error,
        stackTrace: stackTrace,
        data: {'source': source, 'id': AppLogger.mask(id)},
      );
    }
  }

  static String? _actionType(Map<String, dynamic> data) {
    final value = data['actionType']?.toString().trim().toUpperCase();
    return value == null || value.isEmpty ? null : value;
  }

  static String? _transactionId(Map<String, dynamic> data) {
    final value = (data['transactionId'] ?? data['relatedTransactionId'])
        ?.toString()
        .trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String? _navigationToken(Map<String, dynamic> data) {
    final value = (data['notificationId'] ?? data['id'])?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  static bool _isExpired(Map<String, dynamic> data) {
    final raw = data['expiresAt']?.toString().trim();
    if (raw == null || raw.isEmpty) return false;
    final expiresAt = DateTime.tryParse(raw);
    if (expiresAt == null) return false;
    return expiresAt.isBefore(DateTime.now().toUtc());
  }

  static String _tabLocation({
    required int tab,
    String? homeAction,
    String? transactionId,
    String? navigationToken,
  }) {
    final query = <String, String>{'tab': '$tab'};
    if (homeAction != null && homeAction.isNotEmpty) {
      query['action'] = homeAction;
    }
    if (transactionId != null && transactionId.isNotEmpty) {
      query['transactionId'] = transactionId;
    }
    if (navigationToken != null && navigationToken.isNotEmpty) {
      query['notification'] = navigationToken;
    }
    return Uri(path: '/tabbar', queryParameters: query).toString();
  }
}
