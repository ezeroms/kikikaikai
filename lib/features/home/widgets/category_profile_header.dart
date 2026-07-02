import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';

/// カテゴリタブ上部 — 正方形ヒーロー＋下方向グラデーション＋タイトル・説明
class CategoryProfileHeader extends StatelessWidget {
  const CategoryProfileHeader({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final String imageAsset;

  static const _imageOpacity = 0.72;
  static const textTopPadding = 80.0;

  /// コンテンツリストをプロフィール上に重ねる量
  static const contentOverlap = 160.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SizedBox(
      width: width,
      height: width,
      child: Stack(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(40, textTopPadding, 40, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
                const SizedBox(height: 16),
                Text(
                  description,
                  style: AppTypography.body(
                    size: 16,
                    color: AppColors.muted,
                    weight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
