import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:agrokaf/core/services/database_service.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';

/// Analysis history stored in the encrypted database. Photos live in the
/// private `analyses` folder, already sanitized (no EXIF/GPS).
class AnalysisRepository {
  AnalysisRepository(this._database, this._images);

  final DatabaseService _database;
  final ImageService _images;

  static const String _table = DatabaseService.tableAnalyses;

  /// Newest first.
  Future<List<Analysis>> getAll() async {
    final List<Map<String, Object?>> rows = await _database.db.query(
      _table,
      orderBy: 'created_at DESC',
    );
    return rows.map(Analysis.fromRow).toList(growable: false);
  }

  Future<Analysis?> getById(int id) async {
    final List<Map<String, Object?>> rows = await _database.db.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );
    return rows.isEmpty ? null : Analysis.fromRow(rows.first);
  }

  Future<Analysis> insert(Analysis analysis) async {
    final int id = await _database.db.insert(
      _table,
      analysis.toRow()..remove('id'),
    );
    return (await getById(id))!;
  }

  Future<void> delete(Analysis analysis) async {
    await _database.db.delete(
      _table,
      where: 'id = ?',
      whereArgs: <Object>[analysis.id!],
    );
    await _images.deleteImage(analysis.imagePath);
  }

  Future<void> deleteAll() async {
    final List<Analysis> all = await getAll();
    await _database.db.delete(_table);
    for (final Analysis a in all) {
      await _images.deleteImage(a.imagePath);
    }
  }

  /// Removes photos left behind by analyses that were never saved (e.g. the
  /// app was closed on the result screen).
  Future<void> deleteOrphanImages() async {
    final Set<String> referenced = (await getAll())
        .map((Analysis a) => p.normalize(a.imagePath))
        .toSet();
    final Directory dir = await _images.folderPath(ImageFolder.analyses);
    if (!dir.existsSync()) return;
    await for (final FileSystemEntity entity in dir.list()) {
      if (entity is File && !referenced.contains(p.normalize(entity.path))) {
        await _images.deleteImage(entity.path);
      }
    }
  }
}
