import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';

/// カテゴリタブ上部 — 正方形ヒーロー背景（固定）
class CategoryProfileBackground extends StatelessWidget {
  const CategoryProfileBackground({
    super.key,
    required this.imageAsset,
  });

  final String imageAsset;

  static const _imageOpacity = 0.72;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.base),
        Opacity(
          opacity: _imageOpacity,
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        ColoredBox(
          color: Colors.black.withValues(alpha: 0.38),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 0.78, 1.0],
              colors: [
                AppColors.base.withValues(alpha: 0.35),
                Colors.transparent,
                AppColors.base.withValues(alpha: 0.55),
                AppColors.base,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// カテゴリタブ上部 — スクロールするタイトル・説明
class CategoryProfileScrollHeader extends StatelessWidget {
  const CategoryProfileScrollHeader({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  static const blockVerticalMargin = 64.0;
  static const blockHorizontalPadding = 40.0;
  static const titleDescriptionGap = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        blockHorizontalPadding,
        blockVerticalMargin,
        blockHorizontalPadding,
        blockVerticalMargin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.title(
              size: 28,
              weight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: titleDescriptionGap),
          Text(
            description,
            style: AppTypography.body(
              size: 16,
              color: AppColors.muted,
              weight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
