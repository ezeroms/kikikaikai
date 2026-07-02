import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/data/repositories/mock_content_repository.dart';
import 'package:kikikaikai/features/home/widgets/category_profile_header.dart';
import 'package:kikikaikai/shared/widgets/compact_category_content_card.dart';

void main() {
  testWidgets('category stack layout keeps compact cards visible height', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final contents = await MockContentRepository().getByType(
      ContentType.kikikaikai,
    );
    expect(contents, isNotEmpty);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.base,
            body: _CategoryStackHarness(contents: contents),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final cardFinder = find.byType(CompactCategoryContentCard).first;
    expect(cardFinder, findsOneWidget);

    final box = tester.renderObject<RenderBox>(cardFinder);
    expect(
      box.size.height,
      greaterThan(80),
      reason: 'card collapsed in category stack layout',
    );
  });
}

class _CategoryStackHarness extends StatelessWidget {
  const _CategoryStackHarness({required this.contents});

  final List<Content> contents;

  @override
  Widget build(BuildContext context) {
    const overlap = CategoryProfileHeader.contentOverlap;
    final headerHeight = MediaQuery.sizeOf(context).width;

    final listContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < contents.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          CompactCategoryContentCard(content: contents[i]),
        ],
      ],
    );

    return CustomScrollView(
      clipBehavior: Clip.none,
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CategoryProfileHeader(
                title: '奇奇怪怪',
                description: 'テスト',
                imageAsset: 'assets/bg/kikikaikai.png',
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: headerHeight - overlap,
                  left: 24,
                  right: 24,
                  bottom: 32,
                ),
                child: listContent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
