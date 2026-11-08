import 'package:sqflite_sqlcipher/sqflite.dart';

import 'package:agrokaf/core/services/database_service.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/domain/repositories/profile_repository.dart';

/// Profile stored in the encrypted database (single row, id = 1).
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._database, this._images);

  static const int _rowId = 1;

  final DatabaseService _database;
  final ImageService _images;

  @override
  Future<UserProfile?> getProfile() async {
    final List<Map<String, Object?>> rows = await _database.db.query(
      DatabaseService.tableProfile,
      where: 'id = ?',
      whereArgs: <Object>[_rowId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final Map<String, Object?> row = rows.first;
    return UserProfile(
      userName: row['user_name']! as String,
      farmName: (row['farm_name'] as String?) ?? '',
      municipality: row['municipality']! as String,
      coffeeVariety: (row['coffee_variety'] as String?) ?? '',
      profileImagePath: row['photo_path'] as String?,
    );
  }

  @override
  Future<UserProfile> saveProfile(
    UserProfile profile, {
    String? newPhotoSourcePath,
  }) async {
    final UserProfile? previous = await getProfile();

    String? photoPath = profile.profileImagePath;
    if (newPhotoSourcePath != null) {
      photoPath = await _images.savePrivateImage(
        newPhotoSourcePath,
        ImageFolder.profile,
      );
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, Object?> values = <String, Object?>{
      'id': _rowId,
      'user_name': profile.userName.trim(),
      'farm_name': _nullIfEmpty(profile.farmName),
      'municipality': profile.municipality.trim(),
      'coffee_variety': _nullIfEmpty(profile.coffeeVariety),
      'photo_path': photoPath,
      'updated_at': now,
    };

    try {
      await _database.db.transaction((Transaction txn) async {
        final int updated = await txn.update(
          DatabaseService.tableProfile,
          values,
          where: 'id = ?',
          whereArgs: <Object>[_rowId],
        );
        if (updated == 0) {
          await txn.insert(DatabaseService.tableProfile, <String, Object?>{
            ...values,
            'created_at': now,
          });
        }
      });
    } catch (_) {
      // Do not leave an orphan photo if the database write failed.
      if (newPhotoSourcePath != null) await _images.deleteImage(photoPath);
      rethrow;
    }

    // Old photo replaced or removed: delete the file.
    final String? oldPhoto = previous?.profileImagePath;
    if (oldPhoto != null && oldPhoto != photoPath) {
      await _images.deleteImage(oldPhoto);
    }
    await _images.clearTemporaryFiles();

    return profile.copyWith(
      profileImagePath: photoPath,
      clearProfileImage: photoPath == null,
    );
  }

  static String? _nullIfEmpty(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
