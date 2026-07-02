import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/core/models/content_type.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/features/home/home_screen.dart';
import 'package:kikikaikai/shared/widgets/compact_category_content_card.dart';
import 'test_database.dart';

void main() {
  testWidgets('kikikaikai provider resolves in HomeScreen tab', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = await createTestProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('奇奇怪怪'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    while (tester.takeException() != null) {}

    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }

    expect(
      find.textContaining('ポップカルチャーと団地の夜を'),
      findsOneWidget,
    );

    final asyncValue =
        container.read(contentsByTypeProvider(ContentType.kikikaikai));

    expect(asyncValue.hasValue, isTrue, reason: '$asyncValue');
    expect(asyncValue.value!.length, greaterThan(0));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('コンテンツがありません'), findsNothing);

    expect(find.byType(CompactCategoryContentCard), findsWidgets);
    final box = tester.renderObject<RenderBox>(
      find.byType(CompactCategoryContentCard).first,
    );
    expect(box.size.height, greaterThan(80));
  });
}
