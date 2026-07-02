import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/data/dummy/dummy_comments.dart';
import 'package:kikikaikai/data/dummy/dummy_contents.dart';
import 'package:kikikaikai/data/dummy/dummy_figures.dart';
import 'package:kikikaikai/data/dummy/dummy_transcripts.dart';
import 'package:kikikaikai/data/local/catalog_mappers.dart';
import 'package:kikikaikai/data/local/comment_mappers.dart';
import 'package:sqflite/sqflite.dart';

/// ダミーカタログを SQLite へ投入・同期する。
abstract final class DummyDatabaseSeed {
  /// `dummy_contents.dart` / `dummy_figures.dart` を更新したら increment する。
  static const catalogRevision = 7;

  /// 起動時および [LocalContentRepository] 読み取り前に upsert する。
  static Future<void> syncCatalog(Database db) async {
    await db.transaction((txn) async {
      for (final figure in dummyFigures) {
        await txn.insert(
          'figures',
          CatalogMappers.figureToRow(figure),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      for (final content in dummyContents) {
        await _upsertContent(txn, content);
      }

      await _pruneOrphanedContents(txn);
      await _syncSeedComments(txn);
    });

    await _writeCatalogRevision(db);
  }

  static Future<void> _pruneOrphanedContents(DatabaseExecutor txn) async {
    final ids = dummyContents.map((content) => content.id).toList();
    if (ids.isEmpty) return;

    final placeholders = List.filled(ids.length, '?').join(', ');
    await txn.rawDelete(
      'DELETE FROM content_figures WHERE content_id NOT IN ($placeholders)',
      ids,
    );
    await txn.rawDelete(
      'DELETE FROM contents WHERE id NOT IN ($placeholders)',
      ids,
    );
    await txn.rawDelete(
      'DELETE FROM content_comments WHERE content_id NOT IN ($placeholders)',
      ids,
    );
  }

  static Future<void> _syncSeedComments(DatabaseExecutor txn) async {
    await txn.delete(
      'content_comments',
      where: 'is_seed = ?',
      whereArgs: [1],
    );

    for (final seed in dummyCommentSeeds) {
      await txn.insert(
        'content_comments',
        CommentMappers.seedToRow(seed),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<void> _writeCatalogRevision(Database db) async {
    await db.insert(
      'app_meta',
      {
        'key': 'catalog_revision',
        'value': catalogRevision.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> _upsertContent(
    DatabaseExecutor txn,
    Content content,
  ) async {
    final row = CatalogMappers.contentToRow(content);
    row['transcript'] = dummyTranscriptsByContentId[content.id];

    await txn.insert(
      'contents',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await txn.delete(
      'content_figures',
      where: 'content_id = ?',
      whereArgs: [content.id],
    );

    for (var i = 0; i < content.figureIds.length; i++) {
      await txn.insert(
        'content_figures',
        {
          'content_id': content.id,
          'figure_id': content.figureIds[i],
          'sort_order': i,
        },
      );
    }
  }
}
