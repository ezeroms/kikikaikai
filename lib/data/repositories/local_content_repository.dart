import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/data/local/app_database.dart';
import 'package:kikikaikai/data/local/catalog_mappers.dart';
import 'package:kikikaikai/data/local/dummy_database_seed.dart';
import 'package:kikikaikai/data/repositories/content_repository.dart';
import 'package:sqflite/sqflite.dart';

class LocalContentRepository implements ContentRepository {
  LocalContentRepository(this._database);

  final AppDatabase _database;

  Database get _db => _database.raw;

  Future<void> _ensureCatalogSynced() {
    return DummyDatabaseSeed.syncCatalog(_db);
  }

  static const _contentSelect = '''
    SELECT
      c.id,
      c.type,
      c.access_level,
      c.title,
      c.description,
      c.published_at,
      c.thumbnail_asset,
      c.media_url,
      c.body_markdown,
      c.preview_duration_ms,
      c.media_duration_ms,
      c.external_url,
      c.card_subtitle
    FROM contents c
  ''';

  @override
  Future<List<Content>> getAll() async {
    await _ensureCatalogSynced();
    final rows = await _db.rawQuery(
      '$_contentSelect ORDER BY c.published_at DESC',
    );
    return _rowsToContents(rows);
  }

  @override
  Future<List<Content>> getByType(ContentType type) async {
    await _ensureCatalogSynced();
    final rows = await _db.rawQuery(
      '$_contentSelect WHERE c.type = ? ORDER BY c.published_at DESC',
      [type.name],
    );
    return _rowsToContents(rows);
  }

  @override
  Future<Content?> getById(String id) async {
    await _ensureCatalogSynced();
    final rows = await _db.rawQuery(
      '$_contentSelect WHERE c.id = ? LIMIT 1',
      [id],
    );
    if (rows.isEmpty) {
      return null;
    }
    final figureIds = await _figureIdsForContent(id);
    return CatalogMappers.contentFromRow(rows.first, figureIds: figureIds);
  }

  @override
  Future<List<Content>> getByFigure(String figureId) async {
    await _ensureCatalogSynced();
    final rows = await _db.rawQuery(
      '''
      SELECT DISTINCT
        c.id,
        c.type,
        c.access_level,
        c.title,
        c.description,
        c.published_at,
        c.thumbnail_asset,
        c.media_url,
        c.body_markdown,
        c.preview_duration_ms,
        c.media_duration_ms,
        c.external_url,
        c.card_subtitle
      FROM contents c
      INNER JOIN content_figures cf ON cf.content_id = c.id
      WHERE cf.figure_id = ?
      ORDER BY c.published_at DESC
      ''',
      [figureId],
    );
    return _rowsToContents(rows);
  }

  Future<List<Content>> _rowsToContents(List<Map<String, Object?>> rows) async {
    if (rows.isEmpty) {
      return const [];
    }

    final ids = rows.map((row) => row['id']! as String).toList();
    final figureIdsByContent = await _figureIdsByContentIds(ids);

    return rows
        .map(
          (row) => CatalogMappers.contentFromRow(
            row,
            figureIds: figureIdsByContent[row['id']! as String] ?? const [],
          ),
        )
        .toList();
  }

  Future<List<String>> _figureIdsForContent(String contentId) async {
    final rows = await _db.query(
      'content_figures',
      columns: ['figure_id'],
      where: 'content_id = ?',
      whereArgs: [contentId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((row) => row['figure_id']! as String).toList();
  }

  Future<Map<String, List<String>>> _figureIdsByContentIds(
    List<String> contentIds,
  ) async {
    if (contentIds.isEmpty) {
      return const {};
    }

    final placeholders = List.filled(contentIds.length, '?').join(', ');
    final rows = await _db.rawQuery(
      '''
      SELECT content_id, figure_id
      FROM content_figures
      WHERE content_id IN ($placeholders)
      ORDER BY content_id ASC, sort_order ASC
      ''',
      contentIds,
    );

    final result = <String, List<String>>{};
    for (final row in rows) {
      final contentId = row['content_id']! as String;
      result.putIfAbsent(contentId, () => []).add(row['figure_id']! as String);
    }
    return result;
  }
}
