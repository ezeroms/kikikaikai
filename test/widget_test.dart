import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/app/app.dart';

void main() {
  testWidgets('App launches welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KikikaikaiApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('奇奇怪怪'), findsOneWidget);
  });
}
