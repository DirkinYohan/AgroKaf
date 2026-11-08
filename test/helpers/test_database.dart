import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:agrokaf/core/services/database_service.dart';
import 'package:agrokaf/core/services/image_service.dart';

/// Real SQLite (FFI) with the production schema. SQLCipher itself needs the
/// Android/iOS native library, so encryption is verified on the device; the
/// schema, queries and repositories are verified here.
class TestStorage {
  TestStorage._(this.root, this.database, this.images);

  final Directory root;
  final DatabaseService database;
  final ImageService images;

  static Future<TestStorage> create() async {
    sqfliteFfiInit();
    final Directory root = await Directory.systemTemp.createTemp(
      'agrokaf_test_',
    );
    final Directory dbDir = Directory(p.join(root.path, 'db'))..createSync();
    final Directory privateDir = Directory(p.join(root.path, 'private'))
      ..createSync();
    final Directory tempDir = Directory(p.join(root.path, 'cache'))
      ..createSync();

    final DatabaseService database = DatabaseService(
      databasesPath: () async => dbDir.path,
      opener:
          (
            String path, {
            required String password,
            required int version,
            required OnDatabaseCreateFn onCreate,
            required OnDatabaseVersionChangeFn onUpgrade,
            required OnDatabaseConfigureFn onConfigure,
          }) => databaseFactoryFfi.openDatabase(
            path,
            options: OpenDatabaseOptions(
              version: version,
              onCreate: onCreate,
              onUpgrade: onUpgrade,
              onConfigure: onConfigure,
            ),
          ),
    );
    await database.open('test-key');
    final ImageService images = ImageService(
      privateDirectory: () async => privateDir,
      temporaryDirectory: () async => tempDir,
    );
    return TestStorage._(root, database, images);
  }

  /// Writes a small JPEG picture (as if picked from the gallery).
  File writePickedPhoto(String name) {
    final img.Image photo = img.Image(width: 40, height: 30);
    img.fill(photo, color: img.ColorRgb8(40, 130, 60));
    final File f = File(p.join(root.path, 'cache', name));
    f.writeAsBytesSync(img.encodeJpg(photo));
    return f;
  }

  Future<void> dispose() async {
    await database.close();
    if (root.existsSync()) await root.delete(recursive: true);
  }
}
