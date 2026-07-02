import 'package:kikikaikai/core/models/content_comment.dart';
import 'package:kikikaikai/data/local/app_database.dart';
import 'package:kikikaikai/data/local/comment_mappers.dart';
import 'package:kikikaikai/data/local/dummy_database_seed.dart';
import 'package:kikikaikai/data/repositories/content_comments_repository.dart';

class LocalContentCommentsRepository implements ContentCommentsRepository {
  LocalContentCommentsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<ContentComment>> load(String contentId) async {
    await DummyDatabaseSeed.syncCatalog(_database.raw);
    final rows = await _database.raw.query(
      'content_comments',
      where: 'content_id = ?',
      whereArgs: [contentId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CommentMappers.fromRow).toList();
  }

  @override
  Future<void> add(
    String contentId,
    String body, {
    String authorName = '匿名',
    String? authorAvatarAsset,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;

    await _database.raw.insert(
      'content_comments',
      CommentMappers.userCommentToRow(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        contentId: contentId,
        body: trimmed,
        createdAt: DateTime.now(),
        authorName: authorName,
        authorAvatarAsset: authorAvatarAsset,
      ),
    );
  }
}
