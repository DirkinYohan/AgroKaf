import 'package:agrokaf/features/profile/domain/entities/user_profile.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile();

  Future<bool> saveProfile({
    required UserProfile profile,
    XFile? newProfileImage,
  });

  Future<bool> clearProfile();
}
