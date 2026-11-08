import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:agrokaf/core/app_state/app_state.dart';
import 'package:agrokaf/core/app_state/app_state_notifier.dart';
import 'package:agrokaf/core/services/settings_service.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:agrokaf/features/privacy/presentation/pages/privacy_consent_page.dart';
import 'package:agrokaf/features/splash/presentation/pages/splash_page.dart';
import 'package:agrokaf/main.dart';

/// App state without database: first launch, nothing completed yet.
class _FakeAppStateNotifier extends AppStateNotifier {
  @override
  Future<void> bootstrap() async {
    await Future<void>.delayed(AppDurations.splashMinimum);
    state = const AppState(status: StartupStatus.ready);
  }

  @override
  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingCompleted: true);
  }

  @override
  Future<void> acceptPrivacyPolicy(String policyVersion) async {
    state = state.copyWith(
      consent: PrivacyConsent(
        acceptedAt: DateTime(2026),
        policyVersion: policyVersion,
      ),
    );
  }
}

void main() {
  setUpAll(() => initializeDateFormatting(AgroKafApp.localeName));

  testWidgets('First launch: splash -> onboarding -> privacy consent', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appStateProvider.overrideWith(_FakeAppStateNotifier.new)],
        child: const AgroKafApp(),
      ),
    );
    await tester.pump(AppDurations.entrance);
    expect(find.text(SplashPage.tagline), findsOneWidget);

    // Startup finishes -> the router redirects to onboarding.
    await tester.pump(AppDurations.splashMinimum);
    await tester.pump(AppDurations.slow);
    expect(find.text('Bienvenido a AgroKaf'), findsOneWidget);

    // "Omitir" completes onboarding -> consent screen.
    await tester.tap(find.text(OnboardingScreen.skipLabel));
    await tester.pump();
    await tester.pump(AppDurations.slow);
    expect(find.text(PrivacyConsentPage.title), findsOneWidget);

    // The accept button stays disabled until the checkbox is ticked.
    final Finder acceptButton = find.widgetWithText(
      FilledButton,
      PrivacyConsentPage.acceptButton,
    );
    expect(tester.widget<FilledButton>(acceptButton).onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(acceptButton).onPressed, isNotNull);
  });
}
