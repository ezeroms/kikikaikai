import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

/// 詳細画面の TabBar をスクロール時に上部へ固定する Sliver
class ContentDetailTabBarSliver extends SliverPersistentHeaderDelegate {
  ContentDetailTabBarSliver({
    required this.tabBar,
    this.backgroundColor = AppColors.base,
  });

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox.expand(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ContentDetailTabBarSliver oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
