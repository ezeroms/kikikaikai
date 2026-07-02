import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/models/access_level.dart';
import 'package:kikikaikai/shared/widgets/compact_category_content_card.dart';

void main() {
  final content = Content(
    id: 'test-kikikaikai',
    type: ContentType.kikikaikai,
    accessLevel: AccessLevel.public,
    title: 'なぜ自分の言葉で話せなくなってゆくのか',
    description: 'テスト説明',
    cardSubtitle: '第150号',
    figureIds: ['figure_taitan'],
    publishedAt: DateTime(2026, 6, 30),
    thumbnailAsset: 'assets/banner/sample-banner_1.png',
    mediaUrl: 'assets/audio/radio_03.mp3',
  );

  testWidgets('CompactCategoryContentCard renders with non-zero height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: CompactCategoryContentCard(content: content),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(content.title), findsOneWidget);

    final cardFinder = find.byType(CompactCategoryContentCard);
    expect(cardFinder, findsOneWidget);

    final box = tester.renderObject<RenderBox>(cardFinder);
    expect(box.size.height, greaterThan(80));
  });
}
