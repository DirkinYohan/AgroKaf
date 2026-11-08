/// Static information about the app, its author and its legal texts.
class AppInfo {
  AppInfo._();

  static const String appName = 'AgroKaf';
  static const String author = 'Dirkin Yohan Ojeda Rodríguez';
  static const String university = 'Universidad Cooperativa de Colombia';
  static const String region = 'Taminango, Nariño (Colombia)';

  /// Bump when the privacy policy text changes: users must accept again.
  static const String privacyPolicyVersion = '1.0';
  static const String privacyPolicyDate = '8 de noviembre de 2026';

  /// Contact for privacy requests (Ley 1581 de 2012). Fill in before release;
  /// while empty, the policy points to the university instead.
  static const String privacyContactEmail = '';
}
