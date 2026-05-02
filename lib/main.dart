import 'package:app_do_an/navigator/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
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

  final prefs = await SharedPreferences.getInstance();
  
  // Kiểm tra trạng thái đã có tài khoản
  final bool isRegisteredFlag = prefs.getBool('isRegistered') ?? false;
  final bool hasEmail = prefs.getString('user_email') != null;
  final bool hasPhone = prefs.getString('user_phone') != null;
  final isRegistered = isRegisteredFlag || hasEmail || hasPhone;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('vi')], // Chỉ hỗ trợ tiếng Việt
      path: 'assets/langs',
      fallbackLocale: const Locale('vi'),
      startLocale: const Locale('vi'),
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
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: context.localizationDelegates,
      routerConfig: buildRouter(isRegistered),
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

