import 'package:go_router/go_router.dart';
import 'package:laundryan/screens/main_screen.dart';
import 'package:laundryan/screens/onboarding_screen.dart';
import 'package:laundryan/screens/sessions_screen.dart';
import 'package:laundryan/screens/splash_screen.dart';
import 'package:laundryan/screens/wardrobe/wardrobe_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sessions',
                builder: (context, state) => const SessionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wardrobe',
                builder: (context, state) => const WardrobeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}