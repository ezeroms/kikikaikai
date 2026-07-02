import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/content_providers.dart';
import 'package:kikikaikai/core/providers/database_providers.dart';
import 'package:kikikaikai/core/providers/repository_providers.dart';
import 'package:kikikaikai/data/dummy/dummy_contents.dart';
import 'test_database.dart';

void main() {
  test('contentsByTypeProvider reads synced video titles from local DB', () async {
    final container = await createTestProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(contentRepositoryProvider);
    await repository.getAll();

    await container.read(appDatabaseProvider).raw.update(
          'contents',
          {'title': '古いタイトル'},
          where: 'id = ?',
          whereArgs: ['c006'],
        );

    container.invalidate(contentsByTypeProvider);

    final videos = await container.read(
      contentsByTypeProvider(ContentType.video).future,
    );
    final c006 = videos.firstWhere((content) => content.id == 'c006');
    final expectedTitle = dummyContents
        .firstWhere((content) => content.id == 'c006')
        .title;

    expect(c006.title, expectedTitle);
    expect(c006.title, '本当の話をしよう。（札幌編）');
  });
}
