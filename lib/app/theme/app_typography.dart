import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';

abstract final class AppTypography {
  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.notoSansJp(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.onBase,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: display(size: 32),
        displayMedium: display(size: 28),
        displaySmall: display(size: 24),
        headlineLarge: title(size: 22),
        headlineMedium: title(size: 20),
        headlineSmall: title(size: 18),
        titleLarge: title(size: 17),
        titleMedium: titleSmall(size: 15),
        titleSmall: titleSmall(size: 13),
        bodyLarge: body(size: 16),
        bodyMedium: body(size: 15),
        bodySmall: body(size: 13),
        labelLarge: label(size: 14),
        labelMedium: label(size: 12),
        labelSmall: caption(size: 11),
      );

  /// 大見出し（ウェルカム画面など）
  static TextStyle display({double size = 32, Color? color}) => _sans(
        size: size,
        weight: FontWeight.w700,
        color: color,
        height: 1.15,
        letterSpacing: -0.6,
      );

  /// 見出し・セクションタイトル
  static TextStyle heading({double size = 18, Color? color}) =>
      title(size: size, color: color);

  static TextStyle title({
    double size = 18,
    Color? color,
    FontWeight? weight,
  }) =>
      _sans(
        size: size,
        weight: weight ?? FontWeight.w600,
        color: color,
        height: 1.3,
        letterSpacing: -0.25,
      );

  /// カードタイトルなどの小見出し
  static TextStyle titleSmall({double size = 15, Color? color}) => _sans(
        size: size,
        weight: FontWeight.w600,
        color: color,
        height: 1.35,
        letterSpacing: -0.15,
      );

  /// 本文
  static TextStyle body({
    double size = 15,
    Color? color,
    FontWeight? weight,
  }) =>
      _sans(
        size: size,
        weight: weight ?? FontWeight.w400,
        color: color,
        height: 1.55,
      );

  /// ラベル・メタ情報
  static TextStyle label({
    double size = 12,
    Color? color,
    FontWeight? weight,
  }) =>
      _sans(
        size: size,
        weight: weight ?? FontWeight.w500,
        color: color ?? AppColors.muted,
        height: 1.35,
        letterSpacing: 0.1,
      );

  /// 補足テキスト・日付など
  static TextStyle caption({double size = 11, Color? color}) => _sans(
        size: size,
        weight: FontWeight.w400,
        color: color ?? AppColors.muted,
        height: 1.3,
        letterSpacing: 0.05,
      );

  /// カテゴリバッジなど
  static TextStyle overline({Color? color}) => _sans(
        size: 10,
        weight: FontWeight.w600,
        color: color ?? AppColors.primary,
        height: 1.2,
        letterSpacing: 0.6,
      );
}
