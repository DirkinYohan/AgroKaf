import 'package:image_picker/image_picker.dart';
import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:agrokaf/features/profile/domain/repositories/profile_repository.dart';
import 'package:agrokaf/features/profile/data/services/file_storage_service.dart';
import 'package:agrokaf/features/profile/data/services/local_storage_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    LocalStorageService? localStorage,
    FileStorageService? fileStorage,
  })  : _localStorage = localStorage ?? LocalStorageService.instance,
        _fileStorage = fileStorage ?? FileStorageService.instance;

  final LocalStorageService _localStorage;
  final FileStorageService _fileStorage;

  static const String _kUserName = 'agrokaf.profile.userName';
  static const String _kFarmName = 'agrokaf.profile.farmName';
  static const String _kMunicipality = 'agrokaf.profile.municipality';
  static const String _kCoffeeVariety = 'agrokaf.profile.coffeeVariety';
  static const String _kProfileImagePath = 'agrokaf.profile.profileImagePath';

  @override
  Future<UserProfile?> getProfile() async {
    final bool has = await _localStorage.hasSavedProfile();
    if (!has) return null;
    final Map<String, String?> fields = await _localStorage.loadProfileFields();
    final String? userName = fields[_kUserName];
    final String? farmName = fields[_kFarmName];
    final String? municipality = fields[_kMunicipality];
    final String? coffeeVariety = fields[_kCoffeeVariety];
    final String? profileImagePath = fields[_kProfileImagePath];
    if (userName == null ||
        farmName == null ||
        municipality == null ||
        coffeeVariety == null ||
        profileImagePath == null) {
      return null;
    }
    return UserProfile(
      userName: userName,
      farmName: farmName,
      municipality: municipality,
      coffeeVariety: coffeeVariety,
      profileImagePath: profileImagePath,
    );
  }

  @override
  Future<bool> saveProfile({
    required UserProfile profile,
    XFile? newProfileImage,
  }) async {
    try {
      final String? existingPath = profile.profileImagePath;
      String? finalImagePath;
      if (newProfileImage != null) {
        finalImagePath = await _fileStorage.copyImageToProfileDir(
          sourceImage: newProfileImage,
          previousPathToDelete: null,
        );
        if (finalImagePath == null) {
          return false;
        }
      } else if (existingPath != null && existingPath.isNotEmpty) {
        finalImagePath = existingPath;
      }
      if (finalImagePath == null || finalImagePath.isEmpty) {
        return false;
      }
      final bool textSaved = await _localStorage.saveProfileFields(
        userName: profile.userName.trim(),
        farmName: profile.farmName.trim(),
        municipality: profile.municipality.trim(),
        coffeeVariety: profile.coffeeVariety.trim(),
        profileImagePath: finalImagePath,
      );
      if (!textSaved) {
        await _fileStorage.deleteProfileImage(finalImagePath);
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> clearProfile() async {
    try {
      final UserProfile? existing = await getProfile();
      if (existing?.profileImagePath != null) {
        await _fileStorage.deleteProfileImage(existing!.profileImagePath!);
      }
      return _localStorage.clearProfileFields();
    } catch (_) {
      return false;
    }
  }
}
