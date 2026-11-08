import 'package:agrokaf/core/constants/app_routes.dart';
import 'package:agrokaf/core/services/settings_service.dart';

enum StartupStatus { loading, ready, failed }

/// Persisted first-run progress, used by the router to decide where to go.
class AppState {
  const AppState({
    required this.status,
    this.onboardingCompleted = false,
    this.consent,
    this.hasProfile = false,
  });

  static const AppState initial = AppState(status: StartupStatus.loading);

  final StartupStatus status;
  final bool onboardingCompleted;
  final PrivacyConsent? consent;
  final bool hasProfile;

  bool get isReady => status == StartupStatus.ready;

  /// The first-run step still pending, or null when the app is set up.
  /// Order: onboarding -> privacy consent -> profile.
  String? get pendingFirstRunRoute {
    if (!onboardingCompleted) return AppRoutes.onboarding;
    if (consent == null) return AppRoutes.privacyConsent;
    if (!hasProfile) return AppRoutes.profileSetup;
    return null;
  }

  AppState copyWith({
    StartupStatus? status,
    bool? onboardingCompleted,
    PrivacyConsent? consent,
    bool? hasProfile,
  }) {
    return AppState(
      status: status ?? this.status,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      consent: consent ?? this.consent,
      hasProfile: hasProfile ?? this.hasProfile,
    );
  }
}
