import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/data/dummy/dummy_contents.dart';
import 'package:kikikaikai/data/repositories/content_repository.dart';

/// テストやオフライン検証用。本番経路は [LocalContentRepository]。
class MockContentRepository implements ContentRepository {
  @override
  Future<List<Content>> getAll() async => dummyContents;

  @override
  Future<List<Content>> getByType(ContentType type) async =>
      dummyContents.where((c) => c.type == type).toList();

  @override
  Future<Content?> getById(String id) async =>
      dummyContents.where((c) => c.id == id).firstOrNull;

  @override
  Future<List<Content>> getByFigure(String figureId) async =>
      dummyContents
          .where((c) => c.figureIds.contains(figureId))
          .toList();
}
