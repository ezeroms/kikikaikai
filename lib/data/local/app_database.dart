import 'package:kikikaikai/data/local/dummy_database_seed.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// ローカルカタログ DB（将来 API 同期先の下地）。
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  Database get raw => _db;

  static const _dbName = 'kikikaikai.db';
  static const _schemaVersion = 2;

  static Future<AppDatabase> open({bool inMemory = false}) async {
    final db = await openDatabase(
      inMemory ? inMemoryDatabasePath : join(await getDatabasesPath(), _dbName),
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await DummyDatabaseSeed.syncCatalog(db);
    return AppDatabase._(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE figures (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sort_key TEXT NOT NULL,
        bio TEXT NOT NULL,
        avatar_asset TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE contents (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        access_level TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        published_at INTEGER NOT NULL,
        thumbnail_asset TEXT,
        media_url TEXT,
        body_markdown TEXT,
        preview_duration_ms INTEGER NOT NULL DEFAULT 30000,
        media_duration_ms INTEGER,
        external_url TEXT,
        card_subtitle TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE content_figures (
        content_id TEXT NOT NULL,
        figure_id TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (content_id, figure_id),
        FOREIGN KEY (content_id) REFERENCES contents(id),
        FOREIGN KEY (figure_id) REFERENCES figures(id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_contents_type ON contents(type)',
    );
    await db.execute(
      'CREATE INDEX idx_contents_published_at ON contents(published_at DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_content_figures_figure ON content_figures(figure_id)',
    );

    await _createMetaTable(db);
  }

  static Future<void> _createMetaTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createMetaTable(db);
    }
  }

  Future<void> close() => _db.close();
}
