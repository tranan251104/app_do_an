import 'dart:ui';

import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/navigator/router/router.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FLUTTER',
      'Uncaught Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error(
      'UNCAUGHT',
      'Unhandled asynchronous/platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  };
  AppLogger.app('BOOT Flutter binding initialized');
  await EasyLocalization.ensureInitialized();
  AppLogger.success('APP', 'EasyLocalization initialized');

  // Firebase remains only for FCM and the phone-link verification flow.
  // Account sessions and money state are owned by the AnPay backend.
  AppLogger.app('Firebase initialization started');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.success('APP', 'Firebase initialized');
  AppLogger.app('Notification service initialization started');
  await NotificationService.init();
  AppLogger.success('APP', 'Notification service initialized');

  final isFirstLaunch = await AppServices.tokens.isFirstLaunchAndMark();

  // Security rule for AnPay:
  // - first cold launch after install -> registration screen;
  // - every later cold launch -> login screen, even if an old token exists.
  // Clear persisted auth tokens on returning launches so the user cannot be
  // treated as authenticated before entering credentials again.
  if (isFirstLaunch) {
    AppLogger.app(
      'First app launch detected; registration will be shown',
      {'initialRoute': '/createprofile'},
    );
  } else {
    AppLogger.app(
      'Returning app launch detected; login will be required',
      {'initialRoute': '/welcome'},
    );
    await AppServices.tokens.clear();
  }

  AppLogger.app('runApp called');
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi')],
      path: 'assets/langs',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
      saveLocale: true,
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: context.localizationDelegates,
      routerConfig: buildRouter(isFirstLaunch),
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
