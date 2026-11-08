import 'package:sqflite_sqlcipher/sqflite.dart';

import 'package:agrokaf/core/services/database_service.dart';

/// Consent recorded under Ley 1581 de 2012: when and which policy version.
class PrivacyConsent {
  const PrivacyConsent({required this.acceptedAt, required this.policyVersion});

  final DateTime acceptedAt;
  final String policyVersion;
}

/// Small key/value settings stored inside the encrypted database.
class SettingsService {
  SettingsService(this._database);

  static const String _onboardingCompleted = 'onboarding_completed';
  static const String _consentAcceptedAt = 'consent_accepted_at';
  static const String _consentPolicyVersion = 'consent_policy_version';

  final DatabaseService _database;

  Future<String?> _get(String key) async {
    final List<Map<String, Object?>> rows = await _database.db.query(
      DatabaseService.tableSettings,
      columns: <String>['value'],
      where: 'key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> _set(String key, String value) {
    return _database.db.insert(DatabaseService.tableSettings, <String, Object>{
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> isOnboardingCompleted() async =>
      await _get(_onboardingCompleted) == 'true';

  Future<void> setOnboardingCompleted() => _set(_onboardingCompleted, 'true');

  Future<PrivacyConsent?> getPrivacyConsent() async {
    final String? acceptedAt = await _get(_consentAcceptedAt);
    final String? version = await _get(_consentPolicyVersion);
    if (acceptedAt == null || version == null) return null;
    final DateTime? date = DateTime.tryParse(acceptedAt);
    if (date == null) return null;
    return PrivacyConsent(acceptedAt: date, policyVersion: version);
  }

  Future<PrivacyConsent> savePrivacyConsent(String policyVersion) async {
    final DateTime now = DateTime.now();
    await _database.db.transaction((Transaction txn) async {
      for (final MapEntry<String, String> entry in <String, String>{
        _consentAcceptedAt: now.toIso8601String(),
        _consentPolicyVersion: policyVersion,
      }.entries) {
        await txn.insert(DatabaseService.tableSettings, <String, Object>{
          'key': entry.key,
          'value': entry.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    return PrivacyConsent(acceptedAt: now, policyVersion: policyVersion);
  }
}
