import 'package:flutter/material.dart';

/// アプリ全体の色トークン（単一管理源）
abstract final class AppColors {
  AppColors._();

  // ── ブランド ──
  static const primary = Color(0xFFBB261D);
  static const base = Color(0xFF000000);
  static const onBase = Color(0xFFFFFFFF);

  // ── テキスト・アクセント ──
  static const secondary = Color(0xFFD5B28F);
  static const tertiary = Color(0xFFAE8E6D);
  static const muted = Color(0xFFAEAEB6);
  static const accent = Color(0xFFE77002);
  static const blue = Color(0xFF403F9A);

  // ── サーフェス ──
  static const surface = Color(0xFF1C1C1E);
  static const surfaceElevated = Color(0xFF111111);
  static const border = Color(0xFF2C2C2E);

  // ── 互換エイリアス（段階的移行用） ──
  static const white = onBase;
  static const black = base;
  static const summerWood = secondary;
  static const riverRoad = tertiary;
  static const shuttleGray = muted;
  static const moderateBlue = blue;
  static const mangoTango = accent;
  static const thunderbird = primary;
  static const darkSurface = surfaceElevated;
  static const cardSurface = surface;
  static const cardBorder = border;
}
