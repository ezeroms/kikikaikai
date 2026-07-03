import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/features/home/widgets/home_logo_header_sliver.dart';
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
    final maskHeaderScroll = overlapsContent || shrinkOffset > 0;

    return Material(
      color: AppColors.base,
      surfaceTintColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          if (maskHeaderScroll)
            Positioned(
              left: 0,
              right: 0,
              bottom: HomePillTabBar.height,
              height: HomeLogoHeader.height,
              child: const ColoredBox(color: AppColors.base),
            ),
          SizedBox(
            height: HomePillTabBar.height,
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeTabBarSliver oldDelegate) {
    return child != oldDelegate.child;
  }
}
