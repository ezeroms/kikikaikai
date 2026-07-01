import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kikikaikai/app/theme/app_colors.dart';
import 'package:kikikaikai/app/theme/app_typography.dart';

abstract final class AppTheme {
  static const _radius = 10.0;

  static ThemeData get dark {
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.mangoTango,
        secondary: AppColors.summerWood,
        surface: AppColors.cardSurface,
        onPrimary: AppColors.white,
        onSurface: AppColors.white,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.title(size: 17),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.thunderbird,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: AppTypography.title(size: 15, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.summerWood,
          side: const BorderSide(color: AppColors.summerWood),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
          textStyle: AppTypography.title(size: 15, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.shuttleGray,
          textStyle: AppTypography.body(size: 14, weight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppTypography.label(size: 13),
        hintStyle: AppTypography.body(size: 14, color: AppColors.shuttleGray),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.riverRoad),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.riverRoad),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.mangoTango, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.mangoTango,
        unselectedItemColor: AppColors.shuttleGray,
        selectedLabelStyle: AppTypography.label(size: 11, weight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.label(size: 11, weight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTypography.label(size: 14, weight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.label(size: 14, weight: FontWeight.w400),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.riverRoad.withValues(alpha: 0.25),
      ),
      dividerColor: AppColors.riverRoad.withValues(alpha: 0.25),
      sliderTheme: const SliderThemeData(
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
    );
  }
}
