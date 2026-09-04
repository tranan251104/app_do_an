import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FCM background callback must be a top-level function and kept from tree
/// shaking so Android can invoke it while the Flutter UI isolate is not active.
///
/// Messages containing a `notification` payload are displayed by Android/iOS
/// automatically while the app is in the background. The handler is kept here
/// for logging/data payload handling and for the later backend integration.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint(
      '[FCM_BACKGROUND] messageId=${message.messageId} '
      'hasNotification=${message.notification != null} '
      'dataKeys=${message.data.keys.toList()}',
    );
  }
}

class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationService {
  static const String _notificationHistoryKey = 'notification_history';
  static const String _androidChannelId = 'anpay_transaction_channel';
  static const String _androidChannelName = 'Biến động số dư';

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _lastKnownFcmToken;

  static Future<void> init() async {
    await _initLocalNotifications();
    await _initFirebaseMessaging();
  }

  /// Returns the current app-instance token for the unauthenticated phone OTP
  /// request. This does not register the token to a user account; registration
  /// still happens only after the backend has issued an AnPay session.
  static Future<String?> currentFcmToken() async {
    try {
      final token = (_lastKnownFcmToken ?? await _messaging.getToken())?.trim();
      if (token == null || token.isEmpty) {
        AppLogger.warning('FCM', 'No FCM token available for phone OTP');
        return null;
      }
      _lastKnownFcmToken = token;
      return token;
    } catch (error, stackTrace) {
      AppLogger.error(
        'FCM',
        'Unable to obtain FCM token for phone OTP',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  static Future<void> _initLocalNotifications() async {
    AppLogger.repo('NOTIFICATION_LOCAL', 'Initialize local notifications');
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notificationsPlugin.initialize(settings);
    AppLogger.success(
      'NOTIFICATION_LOCAL',
      'Local notification plugin initialized',
    );

    if (Platform.isAndroid) {
      final plugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await plugin?.requestNotificationsPermission();

      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: 'Thông báo về các giao dịch tài chính',
        importance: Importance.max,
      );
      await plugin?.createNotificationChannel(channel);
      AppLogger.success(
        'NOTIFICATION_LOCAL',
        'Android notification channel ready',
        {'channelId': _androidChannelId},
      );
    }
  }

  static Future<void> _initFirebaseMessaging() async {
    AppLogger.repo('FCM', 'Initialize Firebase Cloud Messaging');

    // Must be registered before messages arrive while the app is backgrounded.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    AppLogger.success('FCM', 'Notification permission resolved', {
      'authorizationStatus': settings.authorizationStatus.name,
    });

    // Foreground FCM notifications are rendered through
    // flutter_local_notifications so Android and iOS behave consistently.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    final token = await _messaging.getToken();
    _lastKnownFcmToken = token;
    if (token == null || token.isEmpty) {
      AppLogger.warning(
        'FCM',
        'FCM token is not available yet. Check Google Play Services/network.',
      );
    } else {
      AppLogger.success('FCM', 'FCM registration token obtained', {
        'tokenLength': token.length,
      });
    }

    await _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'FCM',
          'Foreground message stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    await _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationOpened,
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'FCM',
          'Message-open stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
      (newToken) async {
        _lastKnownFcmToken = newToken;
        AppLogger.success('FCM', 'FCM registration token refreshed', {
          'tokenLength': newToken.length,
        });
        await registerCurrentDevice(token: newToken, source: 'token_refresh');
      },
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'FCM',
          'FCM token refresh stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage, source: 'terminated');
    }

    AppLogger.success('FCM', 'Firebase Cloud Messaging initialized');
  }

  /// Registers this Firebase app instance with the authenticated AnPay user.
  ///
  /// FCM token creation happens before login, so this method is intentionally
  /// called after a valid AnPay access token has been stored. Registration is
  /// best-effort: push setup must never make login or a money flow fail.
  static Future<bool> registerCurrentDevice({
    String? token,
    String source = 'post_login',
  }) async {
    try {
      final accessToken = await AppServices.tokens.accessToken();
      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.warning(
          'FCM_DEVICE',
          'Skip push-device registration because user is not authenticated',
          {'source': source},
        );
        return false;
      }

      final effectiveToken =
          (token ?? _lastKnownFcmToken ?? await _messaging.getToken())?.trim();
      if (effectiveToken == null || effectiveToken.isEmpty) {
        AppLogger.warning(
          'FCM_DEVICE',
          'Cannot register push device because FCM token is unavailable',
          {'source': source},
        );
        return false;
      }

      _lastKnownFcmToken = effectiveToken;
      AppLogger.repo('FCM_DEVICE', 'Register push device with backend', {
        'source': source,
        'platform': _platformName,
        'tokenLength': effectiveToken.length,
      });

      await AppServices.api.dio.post<Map<String, dynamic>>(
        '/push/devices',
        data: {
          'token': effectiveToken,
          'platform': _platformName,
          'deviceId': 'flutter-app',
        },
      );

      AppLogger.success('FCM_DEVICE', 'Push device registered with backend', {
        'source': source,
        'platform': _platformName,
      });
      return true;
    } catch (error, stackTrace) {
      AppLogger.error(
        'FCM_DEVICE',
        'Push-device registration failed; app session remains usable',
        error: error,
        stackTrace: stackTrace,
        data: {'source': source},
      );
      return false;
    }
  }

  /// Disables the current FCM token for this AnPay user before an explicit
  /// logout. This is also best-effort so users can always log out locally.
  static Future<bool> unregisterCurrentDevice({
    String source = 'logout',
  }) async {
    try {
      final accessToken = await AppServices.tokens.accessToken();
      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.warning(
          'FCM_DEVICE',
          'Skip push-device unregister because no authenticated session exists',
          {'source': source},
        );
        return false;
      }

      final effectiveToken = (_lastKnownFcmToken ?? await _messaging.getToken())
          ?.trim();
      if (effectiveToken == null || effectiveToken.isEmpty) {
        AppLogger.warning(
          'FCM_DEVICE',
          'Skip push-device unregister because FCM token is unavailable',
          {'source': source},
        );
        return false;
      }

      AppLogger.repo('FCM_DEVICE', 'Unregister push device from backend', {
        'source': source,
        'tokenLength': effectiveToken.length,
      });
      await AppServices.api.dio.post<Map<String, dynamic>>(
        '/push/devices/unregister',
        data: {'token': effectiveToken},
      );
      AppLogger.success('FCM_DEVICE', 'Push device unregistered from backend', {
        'source': source,
      });
      return true;
    } catch (error, stackTrace) {
      AppLogger.error(
        'FCM_DEVICE',
        'Push-device unregister failed; logout may continue',
        error: error,
        stackTrace: stackTrace,
        data: {'source': source},
      );
      return false;
    }
  }

  static String get _platformName {
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isIOS) return 'IOS';
    return Platform.operatingSystem.toUpperCase();
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final remoteNotification = message.notification;
    final title = (remoteNotification?.title ?? message.data['title'] ?? '')
        .toString()
        .trim();
    final body = (remoteNotification?.body ?? message.data['body'] ?? '')
        .toString()
        .trim();

    AppLogger.repo('FCM', 'Foreground remote message received', {
      'messageId': message.messageId,
      'hasNotification': remoteNotification != null,
      'dataKeys': message.data.keys.toList(),
      'titleLength': title.length,
      'bodyLength': body.length,
    });

    if (title.isEmpty && body.isEmpty) {
      AppLogger.warning(
        'FCM',
        'Remote message has no title/body; no visible notification shown',
        {'messageId': message.messageId},
      );
      return;
    }

    await showNotification(
      id: _notificationIdFor(message),
      title: title.isEmpty ? 'ANPAY' : title,
      body: body,
      recordInHistory: message.data['type'] != 'DEMO_PHONE_OTP',
    );
  }

  static void _handleNotificationOpened(
    RemoteMessage message, {
    String source = 'background',
  }) {
    AppLogger.action('FCM notification opened', {
      'source': source,
      'messageId': message.messageId,
      'data': message.data,
    });
    // Later step: route by notificationId / transactionId from message.data.
  }

  static int _notificationIdFor(RemoteMessage message) {
    final messageId = message.messageId;
    if (messageId != null && messageId.isNotEmpty) {
      return messageId.hashCode & 0x7fffffff;
    }
    return DateTime.now().millisecondsSinceEpoch.remainder(0x7fffffff);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool recordInHistory = true,
  }) async {
    AppLogger.repo('NOTIFICATION_LOCAL', 'Show notification', {
      'id': id,
      'title': title,
      'bodyLength': body.length,
    });
    if (recordInHistory) {
      await recordNotification(
        AppNotification(
          id: id,
          title: title,
          body: body,
          createdAt: DateTime.now(),
        ),
      );
    }

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: 'Thông báo về các giao dịch tài chính',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );
    await _notificationsPlugin.show(id, title, body, details);
    AppLogger.success('NOTIFICATION_LOCAL', 'Notification displayed', {
      'id': id,
    });
  }

  static Future<void> recordNotification(AppNotification notification) async {
    AppLogger.repo('NOTIFICATION_LOCAL', 'Record notification history', {
      'id': notification.id,
    });
    final prefs = await SharedPreferences.getInstance();
    final current = await getNotifications();
    final updated = [
      notification,
      ...current.where((item) => item.id != notification.id),
    ].take(100);
    await prefs.setStringList(
      _notificationHistoryKey,
      updated.map((item) => jsonEncode(item.toJson())).toList(growable: false),
    );
  }

  static Future<List<AppNotification>> getNotifications() async {
    AppLogger.repo('NOTIFICATION_LOCAL', 'Read notification history');
    final prefs = await SharedPreferences.getInstance();
    final encodedItems =
        prefs.getStringList(_notificationHistoryKey) ?? const <String>[];
    final notifications = <AppNotification>[];
    for (final encodedItem in encodedItems) {
      try {
        notifications.add(
          AppNotification.fromJson(
            jsonDecode(encodedItem) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    AppLogger.success('NOTIFICATION_LOCAL', 'Notification history loaded', {
      'count': notifications.length,
    });
    return notifications;
  }

  static Future<void> clearNotifications() async {
    AppLogger.action('Clear local notification history');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationHistoryKey);
  }
}
