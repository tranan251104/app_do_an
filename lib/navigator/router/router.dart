import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/features/smart_otp/presentation/smart_otp_onboarding_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/create_account_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/goal_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/home_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/main_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/profile_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/wallet_number_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transfermoney_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:app_do_an/features/lucky_money/presentation/lucky_money_screen.dart';
import 'package:app_do_an/features/lucky_money/presentation/lucky_money_detail_screen.dart';

GoRouter buildRouter(bool isFirstLaunch) {
  final observer = AppRouteObserver();
  final initialLocation = isFirstLaunch ? '/createprofile' : '/welcome';
  AppLogger.app('Router created', {
    'isFirstLaunch': isFirstLaunch,
    'initialLocation': initialLocation,
    'startupPolicy': 'first_install_register_otherwise_login',
  });
  return GoRouter(
    observers: [observer],
    initialLocation: initialLocation,
    // Guard entry points, not just the Login button. This also handles direct
    // GoRouter navigation from push notifications or a stale in-app link.
    redirect: (context, state) async {
      final path = state.uri.path;
      final protected = path == '/' || path == '/main' || path == '/tabbar' ||
          path == '/transfer' || path == '/lucky-money' ||
          path.startsWith('/lucky-money/');
      if (!protected) return null;
      if (!await AppServices.tokens.hasSession()) return '/welcome';
      try {
        final status = await AppServices.smartOtp.status();
        final deviceId = status['deviceId']?.toString() ?? '';
        if (status['active'] == true && deviceId.isNotEmpty &&
            (await AppServices.smartOtpKeyStore.hasLocalDevice(deviceId) ||
             await AppServices.smartOtpKeyStore.recoverConfirmedDevice(deviceId))) {
          return null;
        }
      } catch (_) {
        // Fail closed; the onboarding page can retry and show a useful error.
      }
      return '/smart-otp/onboarding?next=main';
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),
      GoRoute(
        path: '/smart-otp/onboarding',
        builder: (context, state) => SmartOtpOnboardingScreen(
          next: state.uri.queryParameters['next'] ?? 'main',
        ),
      ),
      GoRoute(
        path: '/createprofile',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(path: '/goal', builder: (context, state) => GoalScreen()),
      GoRoute(
        path: '/wallet-number',
        builder: (context, state) {
          final finishToLogin = state.uri.queryParameters['finish'] != 'main';
          return WalletNumberScreen(finishToLogin: finishToLogin);
        },
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(fromLogin: true),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) {
          final fromLogin = state.uri.queryParameters['fromLogin'] == 'true';
          return MainScreen(fromLogin: fromLogin);
        },
      ),
      GoRoute(
        path: '/tabbar',
        builder: (context, state) {
          final rawTab =
              int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          final tab = rawTab.clamp(0, 4).toInt();
          return TabbarScreen(
            initialIndex: tab,
            homeAction: state.uri.queryParameters['action'],
            initialTransactionId: state.uri.queryParameters['transactionId'],
            navigationToken: state.uri.queryParameters['notification'],
          );
        },
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => const TransferMoneyScreen(),
      ),
      GoRoute(
        path: '/lucky-money',
        builder: (context, state) => const LuckyMoneyScreen(),
      ),
      GoRoute(
        path: '/lucky-money/:id',
        builder: (context, state) =>
            LuckyMoneyDetailScreen(envelopeId: state.pathParameters['id']!),
      ),
    ],
  );
}
