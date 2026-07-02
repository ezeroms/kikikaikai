import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';

abstract class ContentRepository {
  Future<List<Content>> getAll();
  Future<List<Content>> getByType(ContentType type);
  Future<Content?> getById(String id);
  Future<List<Content>> getByFigure(String figureId);
}
