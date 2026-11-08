import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:agrokaf/core/models/diagnosis_status.dart';
import 'package:agrokaf/core/services/database_service.dart';
import 'package:agrokaf/core/services/image_service.dart';
import 'package:agrokaf/features/analysis/data/analysis_repository.dart';
import 'package:agrokaf/features/analysis/domain/analysis.dart';

/// Schema 1 -> 2: analyses saved with the 2-class model must survive the
/// upgrade and still display (other_prob stays NULL).
void main() {
  test(
    'upgrading from schema 1 keeps old analyses and adds other_prob',
    () async {
      sqfliteFfiInit();
      final Directory root = await Directory.systemTemp.createTemp(
        'agrokaf_migration_',
      );
      final String dbPath = p.join(root.path, DatabaseService.fileName);

      // 1. A database created by the previous app version (schema 1).
      final Database v1 = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int _) => db.execute('''
          CREATE TABLE analyses (
            id INTEGER PRIMARY KEY AUTOINCREMENT, image_path TEXT NOT NULL,
            status TEXT NOT NULL, healthy_prob REAL NOT NULL, phoma_prob REAL NOT NULL,
            confidence REAL NOT NULL, inference_ms INTEGER NOT NULL, model_version TEXT,
            note TEXT, lot_name TEXT, created_at INTEGER NOT NULL)'''),
        ),
      );
      await v1.insert('analyses', <String, Object?>{
        'image_path': '/old.jpg',
        'status': 'phoma',
        'healthy_prob': 0.1,
        'phoma_prob': 0.9,
        'confidence': 0.9,
        'inference_ms': 50,
        'model_version': 'v1',
        'created_at': 1,
      });
      await v1.close();

      // 2. The new app version opens it.
      final DatabaseService database = DatabaseService(
        databasesPath: () async => root.path,
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
      await database.open('key');
      final AnalysisRepository repo = AnalysisRepository(
        database,
        ImageService(
          privateDirectory: () async => root,
          temporaryDirectory: () async => root,
        ),
      );

      final Analysis old = (await repo.getAll()).single;
      expect(old.status, DiagnosisStatus.phoma);
      expect(old.otherProbability, isNull);

      final Analysis saved = await repo.insert(
        Analysis(
          imagePath: '/new.jpg',
          status: DiagnosisStatus.other,
          healthyProbability: 0.05,
          phomaProbability: 0.05,
          otherProbability: 0.9,
          confidence: 0.9,
          inferenceMs: 40,
          createdAt: DateTime(2026, 11, 8),
        ),
      );
      expect(saved.otherProbability, closeTo(0.9, 1e-9));
      expect(saved.status, DiagnosisStatus.other);

      await database.close();
      try {
        await root.delete(recursive: true);
      } on FileSystemException {
        // Windows may keep the file locked briefly.
      }
    },
  );
}
