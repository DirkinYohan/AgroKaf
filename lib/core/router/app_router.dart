import 'package:flutter/material.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/features/home/presentation/pages/home_page.dart';
import 'package:agrokaf/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:agrokaf/features/onboarding/presentation/pages/onboarding_page_2.dart';
import 'package:agrokaf/features/onboarding/presentation/pages/onboarding_page_3.dart';
import 'package:agrokaf/features/profile/presentation/pages/user_profile_page.dart';
import 'package:agrokaf/features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = _resolvePage(settings.name ?? AppRoutes.splash);
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  static Widget _resolvePage(String name) {
    return switch (name) {
      AppRoutes.splash => const SplashPage(),
      AppRoutes.onboarding => const OnboardingPage(),
      AppRoutes.onboarding2 => const OnboardingPage2(),
      AppRoutes.onboarding3 => const OnboardingPage3(),
      AppRoutes.profile => const UserProfilePage(),
      AppRoutes.home => const HomePage(),
      _ => const SplashPage(),
    };
  }

  static void push(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  static void pushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<T>(result);
    }
  }
}
