import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Private sub-folders for the app's images.
enum ImageFolder { profile, analyses }

/// Thrown when a picked file cannot be decoded as an image.
class InvalidImageException implements Exception {
  const InvalidImageException();
}

/// Stores photos in the app's private directory, never in the public gallery.
///
/// Every photo is re-encoded before saving: EXIF orientation is applied to
/// the pixels and ALL metadata (GPS location, device, date...) is removed;
/// the image is resized to at most [maxDimension] px and compressed.
class ImageService {
  ImageService({
    Future<Directory> Function()? privateDirectory,
    Future<Directory> Function()? temporaryDirectory,
  }) : _privateDirectory = privateDirectory ?? getApplicationSupportDirectory,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  static const int maxDimension = 1280;
  static const int jpegQuality = 85;
  static const String _rootFolder = 'private_images';

  final Future<Directory> Function() _privateDirectory;
  final Future<Directory> Function() _temporaryDirectory;
  final Random _random = Random.secure();

  Future<Directory> _rootDir() async =>
      Directory(p.join((await _privateDirectory()).path, _rootFolder));

  Future<Directory> folderPath(ImageFolder folder) async {
    final Directory dir = Directory(
      p.join((await _rootDir()).path, folder.name),
    );
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Re-encodes [sourcePath] without metadata and returns the new file path.
  Future<String> savePrivateImage(String sourcePath, ImageFolder folder) async {
    final Uint8List bytes = await File(sourcePath).readAsBytes();
    final Uint8List? cleaned = await Isolate.run(() => sanitizeImage(bytes));
    if (cleaned == null) throw const InvalidImageException();

    final Directory dir = await folderPath(folder);
    final String name =
        '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1 << 32)}.jpg';
    final File output = File(p.join(dir.path, name));
    await output.writeAsBytes(cleaned, flush: true);
    return output.path;
  }

  /// Pure function (runs in a background isolate): orientation fix, resize,
  /// metadata removal and JPEG compression. Returns null if not an image.
  static Uint8List? sanitizeImage(Uint8List bytes) {
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    img.Image image = img.bakeOrientation(decoded);
    final int longest = max(image.width, image.height);
    if (longest > maxDimension) {
      image = image.width >= image.height
          ? img.copyResize(
              image,
              width: maxDimension,
              interpolation: img.Interpolation.average,
            )
          : img.copyResize(
              image,
              height: maxDimension,
              interpolation: img.Interpolation.average,
            );
    }
    image
      ..exif = img.ExifData()
      ..iccProfile = null
      ..textData = null;
    return img.encodeJpg(image, quality: jpegQuality);
  }

  /// Deletes one image, only if it belongs to the app's private folder.
  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    final String root = (await _rootDir()).path;
    if (!p.isWithin(root, path)) return;
    final File file = File(path);
    if (file.existsSync()) await file.delete();
  }

  /// Deletes every stored image and the picker's temporary copies.
  Future<void> deleteAllImages() async {
    final Directory root = await _rootDir();
    if (root.existsSync()) await root.delete(recursive: true);
    await clearTemporaryFiles();
  }

  /// image_picker copies picked photos to the cache directory; remove them.
  Future<void> clearTemporaryFiles() async {
    final Directory temp = await _temporaryDirectory();
    if (!temp.existsSync()) return;
    await for (final FileSystemEntity entity in temp.list()) {
      try {
        await entity.delete(recursive: true);
      } on FileSystemException {
        // A file in use by the OS; it will be cleaned next time.
      }
    }
  }
}
