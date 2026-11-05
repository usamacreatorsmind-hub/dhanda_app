import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/business_setup/presentation/screens/business_setup_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_shell_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String businessSetup = '/business-setup';
  static const String dashboard = '/dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: auth,
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: businessSetup,
        builder: (context, state) => const BusinessSetupScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardShellScreen(),
      ),
    ],
  );
}
