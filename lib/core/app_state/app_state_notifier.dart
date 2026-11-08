import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'package:agrokaf/core/app_state/app_state.dart';
import 'package:agrokaf/core/constants/app_info.dart';
import 'package:agrokaf/core/providers/service_providers.dart';
import 'package:agrokaf/core/services/database_service.dart';
import 'package:agrokaf/core/services/settings_service.dart';
import 'package:agrokaf/core/theme/app_spacing.dart';
import 'package:agrokaf/features/analysis/presentation/providers/analysis_providers.dart';

final NotifierProvider<AppStateNotifier, AppState> appStateProvider =
    NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

/// Owns startup and the first-run flow (onboarding, consent, profile).
class AppStateNotifier extends Notifier<AppState> {
  /// Minimum splash time, so the logo does not just flash.
  static Duration minimumSplashDuration = AppDurations.splashMinimum;

  @override
  AppState build() => AppState.initial;

  DatabaseService get _database => ref.read(databaseServiceProvider);
  SettingsService get _settings => ref.read(settingsServiceProvider);

  /// Opens the encrypted database, loads the persisted progress and the AI
  /// model (in parallel). A missing model never blocks startup: the app
  /// then shows "Modelo no disponible".
  Future<void> bootstrap() async {
    state = AppState.initial;
    try {
      final (AppState loaded, _, _) = await (
        _loadState(),
        ref.read(modelStatusProvider.future),
        Future<void>.delayed(minimumSplashDuration),
      ).wait;
      state = loaded;
    } catch (_) {
      // No details are logged: they could contain file paths or user data.
      state = const AppState(status: StartupStatus.failed);
    }
  }

  Future<AppState> _loadState() async {
    await ref.read(legacyDataCleanerProvider).run();
    await _openDatabase();
    await ref.read(analysisRepositoryProvider).deleteOrphanImages();
    final List<Map<String, Object?>> profileCount = await _database.db.rawQuery(
      'SELECT COUNT(*) AS n FROM ${DatabaseService.tableProfile}',
    );
    final PrivacyConsent? consent = await _settings.getPrivacyConsent();
    return AppState(
      status: StartupStatus.ready,
      onboardingCompleted: await _settings.isOnboardingCompleted(),
      // A consent for an older policy version is not valid anymore.
      consent: consent?.policyVersion == AppInfo.privacyPolicyVersion
          ? consent
          : null,
      hasProfile: ((profileCount.first['n'] as int?) ?? 0) > 0,
    );
  }

  Future<void> _openDatabase() async {
    final String key = await ref
        .read(secureKeyStoreProvider)
        .getOrCreateDatabaseKey();
    try {
      await _database.open(key);
    } on DatabaseException {
      // The key in the keystore no longer matches the file (e.g. the OS
      // keystore was reset). Encrypted data is unreadable without its key,
      // so start over with a fresh, empty database.
      await _wipeStorage();
      await _database.open(
        await ref.read(secureKeyStoreProvider).getOrCreateDatabaseKey(),
      );
    }
  }

  Future<void> completeOnboarding() async {
    await _settings.setOnboardingCompleted();
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> acceptPrivacyPolicy(String policyVersion) async {
    final PrivacyConsent consent = await _settings.savePrivacyConsent(
      policyVersion,
    );
    state = state.copyWith(consent: consent);
  }

  void markProfileCreated() {
    state = state.copyWith(hasProfile: true);
  }

  /// "Eliminar todos mis datos": database, photos, keys and caches are
  /// erased and a new empty database (with a new key) is created.
  ///
  /// The state is NOT changed here, so the caller can close its dialogs
  /// first; then [restartFirstRun] sends the user back to onboarding.
  Future<void> deleteAllData() async {
    await _wipeStorage();
    await ref.read(legacyDataCleanerProvider).clearAll();
    await _database.open(
      await ref.read(secureKeyStoreProvider).getOrCreateDatabaseKey(),
    );
  }

  void restartFirstRun() {
    state = const AppState(status: StartupStatus.ready);
  }

  Future<void> _wipeStorage() async {
    await ref.read(imageServiceProvider).deleteAllImages();
    await _database.deleteDatabaseFile();
    await ref.read(secureKeyStoreProvider).deleteAll();
  }
}
