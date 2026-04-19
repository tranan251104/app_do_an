import 'package:app_do_an/navigator/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Luôn signOut khi mở app
  await FirebaseAuth.instance.signOut();

  // 🔹 Clear SharedPreferences để xoá toàn bộ thông tin user
  final prefs = await SharedPreferences.getInstance();
  //await prefs.clear();



  // Lấy flag đã đăng ký
  final isRegistered = prefs.getBool('isRegistered') ?? false;

  // Lấy ngôn ngữ hệ thống
  final systemLocale = PlatformDispatcher.instance.locale;
  final langCode = systemLocale.languageCode;
  final Locale defaultLocale = (langCode == 'en' || langCode == 'vi')
      ? Locale(langCode)
      : const Locale('vi');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      startLocale: defaultLocale,
      saveLocale: true,
      child: MyApp(isRegistered: isRegistered),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isRegistered;
  const MyApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: buildRouter(isRegistered), // ✅ truyền flag vào router
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

// Lệnh để build app thật trên máy 
// flutter devices 
// adb devices

// Lệnh để chạy api gửi otp
// firebase emulators:start --only functions

// Gọi api để gửi mã otp
// .\ngrok.exe http 5001

