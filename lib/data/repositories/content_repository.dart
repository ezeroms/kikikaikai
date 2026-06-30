import 'package:kikikaikai/core/models/author.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';

abstract class ContentRepository {
  Future<List<Content>> getAll();
  Future<List<Content>> getByType(ContentType type);
  Future<Content?> getById(String id);
  Future<List<Content>> getByAuthor(String authorId);
}

abstract class AuthorRepository {
  Future<List<Author>> getAll();
  Future<Author?> getById(String id);
}
