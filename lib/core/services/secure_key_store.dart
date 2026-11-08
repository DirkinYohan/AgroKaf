import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the database encryption key in the OS keystore (Android Keystore /
/// iOS Keychain). The key never leaves the device and is never logged.
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            // "this device only": never synced to iCloud or restored elsewhere.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const String _databaseKeyName = 'agrokaf.db_key';
  static const int _keyLengthBytes = 32; // 256-bit

  final FlutterSecureStorage _storage;

  /// Returns the existing key, or generates a random one on first launch.
  Future<String> getOrCreateDatabaseKey() async {
    final String? existing = await _storage.read(key: _databaseKeyName);
    if (existing != null && existing.isNotEmpty) return existing;

    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(
      _keyLengthBytes,
      (_) => random.nextInt(256),
    );
    final String key = base64UrlEncode(bytes);
    await _storage.write(key: _databaseKeyName, value: key);
    return key;
  }

  /// Removes every secret stored by the app.
  Future<void> deleteAll() => _storage.deleteAll();
}
