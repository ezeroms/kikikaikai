import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

/// カテゴリ詳細の固定背景（一覧タブの正方形ヒーローと同じ画像・トーン）
class CategoryDetailBackground extends StatelessWidget {
  const CategoryDetailBackground({super.key, required this.imageAsset});

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
          color: Colors.black.withValues(alpha: 0.62),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 0.78, 1.0],
              colors: [
                AppColors.base.withValues(alpha: 0.55),
                Colors.transparent,
                AppColors.base.withValues(alpha: 0.78),
                AppColors.base,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 奇奇怪怪詳細の固定背景
class KikikaikaiDetailBackground extends StatelessWidget {
  const KikikaikaiDetailBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryDetailBackground(
      imageAsset: 'assets/bg/kikikaikai.png',
    );
  }
}
