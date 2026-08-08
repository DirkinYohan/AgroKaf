import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class FileStorageService {
  FileStorageService._();

  static final FileStorageService instance = FileStorageService._();

  static const String _profileImagesDirName = 'profile_images';

  Future<Directory> _getAppDocumentsDir() async {
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> _getProfileImagesDir() async {
    final Directory appDir = await _getAppDocumentsDir();
    final Directory dir = Directory(path_lib.join(
      appDir.path,
      _profileImagesDirName,
    ));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String?> copyImageToProfileDir({
    required XFile sourceImage,
    String? previousPathToDelete,
  }) async {
    try {
      if (previousPathToDelete != null && previousPathToDelete.isNotEmpty) {
        await _deleteFileIfExists(previousPathToDelete);
      }
      final Directory dir = await _getProfileImagesDir();
      final String rawExt = path_lib.extension(sourceImage.name);
      final String extension = (rawExt.isEmpty ? '.jpg' : rawExt).toLowerCase();
      final String fileName =
          'p_${DateTime.now().millisecondsSinceEpoch}_${identityHashCode(sourceImage)}$extension';
      final File destination = File(path_lib.join(dir.path, fileName));
      final File source = File(sourceImage.path);
      if (!source.existsSync()) {
        return null;
      }
      await source.copy(destination.path);
      return destination.absolute.path;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteProfileImage(String absolutePath) async {
    return _deleteFileIfExists(absolutePath);
  }

  Future<bool> _deleteFileIfExists(String absolutePath) async {
    try {
      final File file = File(absolutePath);
      if (file.existsSync()) {
        await file.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
