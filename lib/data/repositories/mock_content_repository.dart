import 'package:kikikaikai/core/models/author.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/data/dummy/dummy_authors.dart';
import 'package:kikikaikai/data/dummy/dummy_contents.dart';
import 'package:kikikaikai/data/repositories/content_repository.dart';

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
  Future<List<Content>> getByAuthor(String authorId) async =>
      dummyContents.where((c) => c.authorId == authorId).toList();
}

class MockAuthorRepository implements AuthorRepository {
  @override
  Future<List<Author>> getAll() async => dummyAuthors;

  @override
  Future<Author?> getById(String id) async =>
      dummyAuthors.where((a) => a.id == id).firstOrNull;
}
