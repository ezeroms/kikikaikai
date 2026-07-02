import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/features/home/widgets/home_pill_tab_bar.dart';

/// 鑑賞画面の横スクロールタブを上部に固定する Sliver
class HomeTabBarSliver extends SliverPersistentHeaderDelegate {
  HomeTabBarSliver({required this.child});

  final Widget child;

  @override
  double get minExtent => HomePillTabBar.height;

  @override
  double get maxExtent => HomePillTabBar.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.base,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant HomeTabBarSliver oldDelegate) {
    return child != oldDelegate.child;
  }
}
