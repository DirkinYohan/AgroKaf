/// Route paths used with go_router.
class AppRoutes {
  AppRoutes._();

  // First-run flow (in this order).
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String privacyConsent = '/privacy-consent';
  static const String profileSetup = '/profile-setup';

  // Full-screen pages pushed over the tabs.
  static const String profileEdit = '/profile-edit';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String about = '/about';
  static const String analysisPreview = '/analysis-preview';
  static const String analysisResult = '/analysis-result';
  static const String analysisDetail = '/history-detail/:id';

  static String analysisDetailPath(int id) => '/history-detail/$id';

  // Bottom-navigation tabs (one branch each in the shell).
  static const String home = '/home';
  static const String history = '/history';
  static const String profile = '/profile';

  static const Set<String> firstRun = <String>{
    splash,
    onboarding,
    privacyConsent,
    profileSetup,
  };
}
