import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Opens a database file. Production uses SQLCipher; tests can inject an
/// in-memory/FFI opener.
typedef DatabaseOpener =
    Future<Database> Function(
      String path, {
      required String password,
      required int version,
      required OnDatabaseCreateFn onCreate,
      required OnDatabaseVersionChangeFn onUpgrade,
      required OnDatabaseConfigureFn onConfigure,
    });

Future<Database> _openSqlCipher(
  String path, {
  required String password,
  required int version,
  required OnDatabaseCreateFn onCreate,
  required OnDatabaseVersionChangeFn onUpgrade,
  required OnDatabaseConfigureFn onConfigure,
}) {
  return openDatabase(
    path,
    password: password,
    version: version,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    onConfigure: onConfigure,
  );
}

/// Local, encrypted (SQLCipher) SQLite database. All personal data lives
/// here and nowhere else.
class DatabaseService {
  DatabaseService({
    DatabaseOpener? opener,
    Future<String> Function()? databasesPath,
  }) : _opener = opener ?? _openSqlCipher,
       _databasesPath = databasesPath ?? getDatabasesPath;

  static const String fileName = 'agrokaf.db';

  /// 1: initial schema. 2: `analyses.other_prob` (3-class model v2.0.0).
  static const int schemaVersion = 2;

  static const String tableSettings = 'app_settings';
  static const String tableProfile = 'user_profile';
  static const String tableAnalyses = 'analyses';

  final DatabaseOpener _opener;
  final Future<String> Function() _databasesPath;
  Database? _db;

  bool get isOpen => _db?.isOpen ?? false;

  Database get db {
    final Database? database = _db;
    if (database == null || !database.isOpen) {
      throw StateError('DatabaseService.open() must be called first.');
    }
    return database;
  }

  Future<String> _path() async => p.join(await _databasesPath(), fileName);

  Future<void> open(String encryptionKey) async {
    if (isOpen) return;
    _db = await _opener(
      await _path(),
      password: encryptionKey,
      version: schemaVersion,
      onConfigure: (Database db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    );
  }

  static Future<void> _createSchema(Database db, int version) async {
    final Batch batch = db.batch()
      ..execute('''
        CREATE TABLE $tableSettings (
          key   TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )''')
      ..execute('''
        CREATE TABLE $tableProfile (
          id             INTEGER PRIMARY KEY CHECK (id = 1),
          user_name      TEXT    NOT NULL,
          farm_name      TEXT,
          municipality   TEXT    NOT NULL,
          coffee_variety TEXT,
          photo_path     TEXT,
          created_at     INTEGER NOT NULL,
          updated_at     INTEGER NOT NULL
        )''')
      // Filled in Phase 3 (analysis history).
      ..execute('''
        CREATE TABLE $tableAnalyses (
          id               INTEGER PRIMARY KEY AUTOINCREMENT,
          image_path       TEXT    NOT NULL,
          status           TEXT    NOT NULL,
          healthy_prob     REAL    NOT NULL,
          phoma_prob       REAL    NOT NULL,
          other_prob       REAL,
          confidence       REAL    NOT NULL,
          inference_ms     INTEGER NOT NULL,
          model_version    TEXT,
          note             TEXT,
          lot_name         TEXT,
          created_at       INTEGER NOT NULL
        )''')
      ..execute(
        'CREATE INDEX idx_analyses_created_at ON $tableAnalyses (created_at DESC)',
      );
    await batch.commit(noResult: true);
  }

  static Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Analyses saved with the 2-class model keep other_prob = NULL.
      await db.execute('ALTER TABLE $tableAnalyses ADD COLUMN other_prob REAL');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  /// Closes and permanently deletes the database file.
  Future<void> deleteDatabaseFile() async {
    await close();
    await deleteDatabase(await _path());
  }
}
