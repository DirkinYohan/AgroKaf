import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Removes the unencrypted data written by the first prototype (profile in
/// SharedPreferences, photo in Documents/profile_images). Nothing is
/// migrated: the user had not given privacy consent for that data.
class LegacyDataCleaner {
  static const String _legacyPrefix = 'agrokaf.profile.';
  static const String _legacyPhotoFolder = 'profile_images';

  Future<void> run() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      for (final String key in prefs.getKeys()) {
        if (key.startsWith(_legacyPrefix)) await prefs.remove(key);
      }
      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory photos = Directory(p.join(docs.path, _legacyPhotoFolder));
      if (photos.existsSync()) await photos.delete(recursive: true);
    } catch (_) {
      // Best effort: never block app startup because of old prototype data.
    }
  }

  /// Clears every SharedPreferences entry (used by "delete all my data").
  Future<void> clearAll() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
