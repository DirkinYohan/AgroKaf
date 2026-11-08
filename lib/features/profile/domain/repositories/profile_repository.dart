import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  /// The saved profile, or null if none was created yet.
  Future<UserProfile?> getProfile();

  /// Creates or updates the profile.
  ///
  /// [newPhotoSourcePath] is a freshly picked photo: it is sanitized (no
  /// EXIF/GPS, compressed) and stored privately; the previous photo is
  /// deleted. Passing a profile without photo removes the stored one.
  Future<UserProfile> saveProfile(
    UserProfile profile, {
    String? newPhotoSourcePath,
  });
}
