import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/core/markdown/body_markdown_normalizer.dart';
import 'package:kikikaikai/data/dummy/bulletin_bodies.dart';
import 'package:kikikaikai/shared/widgets/rich_markdown_body.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  group('BodyMarkdownNormalizer', () {
    test('removes blank lines between consecutive middle-dot lines', () {
      const input = '''・一行目

・二行目

https://example.com

・三行目
''';

      expect(
        BodyMarkdownNormalizer.normalize(input),
        '''・一行目
・二行目

https://example.com

・三行目
''',
      );
    });

    test('escapes markdown hyphen list markers', () {
      const input = '- list item\n\nplain';
      expect(
        BodyMarkdownNormalizer.normalize(input),
        r'\- list item' '\n\nplain',
      );
    });

    test('bulletin bodies do not produce markdown lists', () {
      final doc = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored)
          .parse(BodyMarkdownNormalizer.normalize(BulletinBodies.backrooms));

      int ul = 0;
      void walk(md.Node n) {
        if (n is md.Element && n.tag == 'ul') {
          ul++;
        }
        if (n is md.Element) {
          for (final c in n.children ?? const <md.Node>[]) {
            walk(c);
          }
        }
      }

      for (final n in doc) {
        walk(n);
      }
      expect(ul, 0);
    });
  });

  testWidgets('renders middle-dot lines as paragraphs without list bullets', (
    WidgetTester tester,
  ) async {
    const data = '''・一行目

・二行目

- markdown list
''';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RichMarkdownBody(data: data),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('•'), findsNothing);
    expect(find.textContaining('・一行目'), findsOneWidget);
    expect(find.textContaining('- markdown list'), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });
}
