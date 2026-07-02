import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

/// 鑑賞画面上部のロゴ。スクロールに合わせて縮小しながら上へ消える。
class HomeLogoHeaderSliver extends SliverPersistentHeaderDelegate {
  static const height = 96.0;
  static const logoHeight = 80.0;

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final scale = 1.0 - progress;
    final visibleHeight = maxExtent - shrinkOffset;

    return ColoredBox(
      color: AppColors.base,
      child: ClipRect(
        child: SizedBox(
          height: visibleHeight,
          width: double.infinity,
          child: OverflowBox(
            maxHeight: maxExtent,
            alignment: Alignment.center,
            child: Transform.translate(
              offset: Offset(0, -shrinkOffset),
              child: Transform.scale(
                scale: scale,
                child: Image.asset(
                  'assets/branding/pinpin/logo.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeLogoHeaderSliver oldDelegate) => false;
}
