import 'package:flutter_test/flutter_test.dart';
import 'package:kikikaikai/features/home/widgets/category_tab_layout.dart';
import 'package:kikikaikai/features/home/widgets/home_logo_header_sliver.dart';
import 'package:kikikaikai/features/home/widgets/home_pill_tab_bar.dart';

void main() {
  group('categoryTabBackgroundTopInset', () {
    test('stays zero while logo is collapsing', () {
      expect(categoryTabBackgroundTopInset(0), 0);
      expect(categoryTabBackgroundTopInset(HomeLogoHeader.height / 2), 0);
      expect(categoryTabBackgroundTopInset(HomeLogoHeader.height), 0);
    });

    test('ramps while body catches up to pinned tab', () {
      expect(
        categoryTabBackgroundTopInset(HomeLogoHeader.height + 2),
        2,
      );
      expect(
        categoryTabBackgroundTopInset(categoryTabHeaderCollapseExtent),
        HomePillTabBar.height,
      );
    });

    test('stays capped after header collapse completes', () {
      expect(
        categoryTabBackgroundTopInset(categoryTabHeaderCollapseExtent + 120),
        HomePillTabBar.height,
      );
    });
  });
}
