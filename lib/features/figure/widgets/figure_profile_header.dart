import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';
import 'package:kikikaikai/core/models/figure.dart';

/// Figure コンテンツエリア — 固定背景画像
class FigureContentBackground extends StatelessWidget {
  const FigureContentBackground({super.key, required this.figure});

  final Figure figure;

  static const _imageOpacity = 0.72;
  static const _uniformTintOpacity = 0.28;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.base),
        Opacity(
          opacity: _imageOpacity,
          child: Image.asset(
            figure.avatarAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        ColoredBox(
          color: Colors.black.withValues(alpha: _uniformTintOpacity),
        ),
        // AppBar 直下から自然につなぐ — 上方向へ黒くフェード
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.14, 0.32, 0.52],
              colors: [
                AppColors.base,
                AppColors.base,
                AppColors.base.withValues(alpha: 0.72),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // 下端はコンテンツスクロールに合わせて黒へ
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.62, 0.88, 1.0],
              colors: [
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

/// Figure コンテンツエリア — スクロールするプロフィール（円形アイコン＋名前）
class FigureScrollProfile extends StatelessWidget {
  const FigureScrollProfile({super.key, required this.figure});

  final Figure figure;

  static const _avatarRadius = 48.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: _avatarRadius,
            backgroundColor: AppColors.surfaceElevated,
            backgroundImage: AssetImage(figure.avatarAsset),
          ),
          const SizedBox(height: 16),
          Text(
            figure.name,
            style: AppTypography.title(
              size: 28,
              weight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
