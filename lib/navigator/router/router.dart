import 'package:go_router/go_router.dart';
import 'package:app_do_an/navigator/navigator_screen/create_account_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/profile_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/goal_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/welcome_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/main_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/tabbar_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/home_screen.dart';
import 'package:app_do_an/navigator/secondary_screen/transfermoney_screen.dart';
import 'package:app_do_an/navigator/navigator_screen/profile_phone_screen.dart';

GoRouter buildRouter(bool isRegistered) {
  return GoRouter(
    initialLocation: isRegistered ? '/welcome' : '/createprofile',
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/createprofile', builder: (context, state) => CreateAccountScreen()),
      GoRoute(path: '/profile', builder: (context, state) => ProfileEmailScreen()),
      GoRoute(path: '/profile_phone', builder: (context, state) => ProfilePhoneScreen()),
      GoRoute(path: '/goal', builder: (context, state) => GoalScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => WelcomeScreen(fromLogin: true)),
      GoRoute(
        path: '/main',
        builder: (context, state) {
          final fromLogin = state.uri.queryParameters['fromLogin'] == 'true';
          return MainScreen(fromLogin: fromLogin);
        },
      ),
      GoRoute(path: '/tabbar', builder: (context, state) => TabbarScreen()),
      GoRoute(
        path: '/transfer',
        builder: (context, state) => const TransferMoneyScreen(),
      ),
    ],
  );
}



