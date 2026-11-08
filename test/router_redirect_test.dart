import 'package:flutter_test/flutter_test.dart';

import 'package:agrokaf/core/app_state/app_state.dart';
import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/router/app_router.dart';
import 'package:agrokaf/core/services/settings_service.dart';

void main() {
  final PrivacyConsent consent = PrivacyConsent(
    acceptedAt: DateTime(2026, 11, 8),
    policyVersion: '1.0',
  );
  const AppState fresh = AppState(status: StartupStatus.ready);
  final AppState setUp = AppState(
    status: StartupStatus.ready,
    onboardingCompleted: true,
    consent: consent,
    hasProfile: true,
  );

  group('resolveRedirect', () {
    test('stays on splash while starting', () {
      expect(resolveRedirect(AppState.initial, AppRoutes.splash), isNull);
      expect(
        resolveRedirect(AppState.initial, AppRoutes.home),
        AppRoutes.splash,
      );
    });

    test('first launch forces onboarding', () {
      expect(resolveRedirect(fresh, AppRoutes.splash), AppRoutes.onboarding);
      expect(resolveRedirect(fresh, AppRoutes.home), AppRoutes.onboarding);
      expect(resolveRedirect(fresh, AppRoutes.onboarding), isNull);
    });

    test('consent is required before the profile', () {
      final AppState s = fresh.copyWith(onboardingCompleted: true);
      expect(
        resolveRedirect(s, AppRoutes.onboarding),
        AppRoutes.privacyConsent,
      );
      expect(
        resolveRedirect(s, AppRoutes.profileSetup),
        AppRoutes.privacyConsent,
      );
      // The full policy can be read from the consent screen.
      expect(resolveRedirect(s, AppRoutes.privacyPolicy), isNull);
    });

    test('profile setup comes after consent', () {
      final AppState s = fresh.copyWith(
        onboardingCompleted: true,
        consent: consent,
      );
      expect(
        resolveRedirect(s, AppRoutes.privacyConsent),
        AppRoutes.profileSetup,
      );
      expect(resolveRedirect(s, AppRoutes.home), AppRoutes.profileSetup);
    });

    test('once set up, first-run screens go to home', () {
      for (final String route in AppRoutes.firstRun) {
        expect(resolveRedirect(setUp, route), AppRoutes.home);
      }
      expect(resolveRedirect(setUp, AppRoutes.settings), isNull);
      expect(resolveRedirect(setUp, AppRoutes.profileEdit), isNull);
    });
  });
}
