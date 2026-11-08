import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// The user (or the OS) blocked access to the camera or the photo library.
class PhotoPermissionDeniedException implements Exception {
  const PhotoPermissionDeniedException(this.source);

  final ImageSource source;
}

/// Thin wrapper over image_picker.
///
/// Permissions are requested only at the moment of use. On Android the
/// system Photo Picker needs no permission and the camera is opened through
/// the system camera app; on iOS the OS asks the first time using the texts
/// in Info.plist. A denial surfaces as [PhotoPermissionDeniedException].
class PhotoPickerService {
  PhotoPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const Set<String> _deniedCodes = <String>{
    'camera_access_denied',
    'photo_access_denied',
    'no_available_camera',
  };

  /// Returns the picked file path, or null if the user cancelled.
  Future<String?> pick(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
        preferredCameraDevice: CameraDevice.rear,
      );
      return file?.path;
    } on PlatformException catch (e) {
      if (_deniedCodes.contains(e.code)) {
        throw PhotoPermissionDeniedException(source);
      }
      rethrow;
    }
  }
}
