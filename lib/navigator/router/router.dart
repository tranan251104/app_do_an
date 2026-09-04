import 'package:app_do_an/core/logging/app_logger.dart';
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

GoRouter buildRouter(bool isFirstLaunch) {
  final observer = AppRouteObserver();
  final initialLocation = isFirstLaunch ? '/createprofile' : '/welcome';
  AppLogger.app(
    'Router created',
    {
      'isFirstLaunch': isFirstLaunch,
      'initialLocation': initialLocation,
      'startupPolicy': 'first_install_register_otherwise_login',
    },
  );
  return GoRouter(
    observers: [observer],
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),
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
        builder: (context, state) => const TabbarScreen(),
      ),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => const TransferMoneyScreen(),
      ),
    ],
  );
}
