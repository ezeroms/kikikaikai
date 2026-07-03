import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

/// 背景画像のある画面向けのガラスカード。
///
/// 背面をガウスぼかしし、白 4% のフラット塗りを重ねる（角丸 16・枠線なし）。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma,
  });

  /// 通常時の白塗り不透明度。
  static const kFillAlpha = 0.04;

  /// 背面ガウスぼかしの強さ（論理 px）。
  static const kBlurSigma = 12.0;

  static const kBorderRadius = 16.0;

  static const kDefaultPadding = EdgeInsets.all(20);

  /// コメントカード用の内側余白。
  static const kCommentPadding = EdgeInsets.all(16);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? kBorderRadius;
    final sigma = blurSigma ?? kBlurSigma;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: GlassCardSurface(
        borderRadius: radius,
        blurSigma: sigma,
        child: Padding(
          padding: padding ?? kDefaultPadding,
          child: child,
        ),
      ),
    );
  }
}

/// ガラスカードの背景（ぼかし + 白 4%）。子のレイアウト・余白は呼び出し側で付ける。
class GlassCardSurface extends StatelessWidget {
  const GlassCardSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma,
  });

  final Widget child;
  final double? borderRadius;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? GlassCard.kBorderRadius);
    final sigma = blurSigma ?? GlassCard.kBlurSigma;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(
          color: AppColors.onBase.withValues(alpha: GlassCard.kFillAlpha),
          child: child,
        ),
      ),
    );
  }
}
