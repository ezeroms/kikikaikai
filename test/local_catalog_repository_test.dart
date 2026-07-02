import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/data/dummy/dummy_contents.dart';
import 'package:kikikaikai/data/local/app_database.dart';
import 'package:kikikaikai/data/local/dummy_database_seed.dart';
import 'package:kikikaikai/data/repositories/local_content_repository.dart';
import 'package:kikikaikai/data/repositories/local_figure_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('local catalog repositories read seeded dummy data', () async {
    final database = await AppDatabase.open(inMemory: true);
    addTearDown(database.close);

    final contentRepository = LocalContentRepository(database);
    final figureRepository = LocalFigureRepository(database);

    final allContents = await contentRepository.getAll();
    expect(allContents, isNotEmpty);

    final bulletin = await contentRepository.getByType(ContentType.bulletin);
    expect(bulletin.every((c) => c.type == ContentType.bulletin), isTrue);

    final first = allContents.first;
    final byId = await contentRepository.getById(first.id);
    expect(byId?.title, first.title);

    final figures = await figureRepository.getAll();
    expect(figures, isNotEmpty);

    if (first.figureIds.isNotEmpty) {
      final byFigure = await contentRepository.getByFigure(first.figureIds.first);
      expect(byFigure.any((c) => c.id == first.id), isTrue);
    }
  });

  test('syncCatalog updates existing content titles from dummy data', () async {
    final database = await AppDatabase.open(inMemory: true);
    addTearDown(database.close);

    final contentRepository = LocalContentRepository(database);
    final staleTitle = '古いタイトル';

    await database.raw.update(
      'contents',
      {'title': staleTitle},
      where: 'id = ?',
      whereArgs: ['c006'],
    );

    final staleRow = await database.raw.query(
      'contents',
      where: 'id = ?',
      whereArgs: ['c006'],
    );
    expect(staleRow.first['title'], staleTitle);

    await DummyDatabaseSeed.syncCatalog(database.raw);

    final expectedTitle = dummyContents
        .firstWhere((content) => content.id == 'c006')
        .title;
    expect(
      (await contentRepository.getById('c006'))?.title,
      expectedTitle,
    );
    expect(expectedTitle, '本当の話をしよう。（札幌編）');
  });

  test('syncCatalog keeps video titles aligned with dummy contents', () async {
    final database = await AppDatabase.open(inMemory: true);
    addTearDown(database.close);

    final contentRepository = LocalContentRepository(database);
    final expectedById = {
      for (final content in dummyContents.where(
        (content) => content.type == ContentType.video,
      ))
        content.id: content.title,
    };

    final videos = await contentRepository.getByType(ContentType.video);
    expect(videos.length, expectedById.length);

    for (final video in videos) {
      expect(video.title, expectedById[video.id]);
    }
  });

  test('repository read resyncs stale titles from dummy contents', () async {
    final database = await AppDatabase.open(inMemory: true);
    addTearDown(database.close);

    final contentRepository = LocalContentRepository(database);
    const staleTitle = '古いタイトル';

    await database.raw.update(
      'contents',
      {'title': staleTitle},
      where: 'id = ?',
      whereArgs: ['c024'],
    );

    final video = await contentRepository.getById('c024');
    expect(video?.title, 'これから人を殺めるときの口笛');
    expect(video?.title, isNot(staleTitle));
  });
}
