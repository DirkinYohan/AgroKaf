import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:agrokaf/core/app_state/app_state.dart';
import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/features/analysis/domain/analysis_draft.dart';
import 'package:agrokaf/features/analysis/presentation/pages/analysis_preview_page.dart';
import 'package:agrokaf/features/analysis/presentation/pages/analysis_result_page.dart';
import 'package:agrokaf/features/history/presentation/pages/history_detail_page.dart';
import 'package:agrokaf/features/history/presentation/pages/history_page.dart';
import 'package:agrokaf/features/home/presentation/pages/home_page.dart';
import 'package:agrokaf/features/home/presentation/pages/home_shell.dart';
import 'package:agrokaf/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:agrokaf/features/privacy/presentation/pages/privacy_consent_page.dart';
import 'package:agrokaf/features/privacy/presentation/pages/privacy_policy_page.dart';
import 'package:agrokaf/features/profile/presentation/pages/profile_page.dart';
import 'package:agrokaf/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:agrokaf/features/settings/presentation/pages/about_page.dart';
import 'package:agrokaf/features/settings/presentation/pages/settings_page.dart';
import 'package:agrokaf/features/splash/presentation/pages/splash_page.dart';

/// Pure routing decision, driven only by the persisted [AppState].
///
/// - Until startup finishes, stay on the splash.
/// - While a first-run step is pending, force that step (the privacy policy
///   may be opened from the consent screen).
/// - Once set up, first-run screens are no longer reachable.
String? resolveRedirect(AppState state, String location) {
  if (!state.isReady) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }
  final String? pending = state.pendingFirstRunRoute;
  if (pending != null) {
    if (location == pending) return null;
    final bool readingPolicy =
        pending == AppRoutes.privacyConsent &&
        location == AppRoutes.privacyPolicy;
    return readingPolicy ? null : pending;
  }
  return AppRoutes.firstRun.contains(location) ? AppRoutes.home : null;
}

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  // Re-evaluates the redirect whenever the app state changes.
  final ValueNotifier<AppState> refresh = ValueNotifier<AppState>(
    ref.read(appStateProvider),
  );
  ref.listen<AppState>(
    appStateProvider,
    (_, AppState next) => refresh.value = next,
  );

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (_, GoRouterState state) =>
        resolveRedirect(ref.read(appStateProvider), state.matchedLocation),
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, GoRouterState s) =>
            _fadePage(s, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.privacyConsent,
        pageBuilder: (_, GoRouterState s) =>
            _fadePage(s, const PrivacyConsentPage()),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        pageBuilder: (_, GoRouterState s) =>
            _fadePage(s, const ProfileSetupPage()),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (_, _) => const ProfileSetupPage(isEditing: true),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (_, _) => const PrivacyPolicyPage(),
      ),
      GoRoute(path: AppRoutes.about, builder: (_, _) => const AboutPage()),
      GoRoute(
        path: AppRoutes.analysisPreview,
        builder: (_, GoRouterState s) =>
            AnalysisPreviewPage(sourcePath: s.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.analysisResult,
        builder: (_, GoRouterState s) =>
            AnalysisResultPage(draft: s.extra! as AnalysisDraft),
      ),
      GoRoute(
        path: AppRoutes.analysisDetail,
        builder: (_, GoRouterState s) =>
            HistoryDetailPage(analysisId: int.parse(s.pathParameters['id']!)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, StatefulNavigationShell shell) =>
            HomeShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.history,
                builder: (_, _) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

/// Gentle fade used between the full-screen steps of the first-run flow.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
