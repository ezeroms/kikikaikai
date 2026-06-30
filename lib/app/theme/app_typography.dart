import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextStyle heading({double size = 24, Color? color}) =>
      GoogleFonts.zenMaruGothic(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? Colors.white,
        height: 1.2,
      );

  static TextStyle body({double size = 16, Color? color}) =>
      GoogleFonts.notoSerifJp(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? Colors.white,
        height: 1.6,
      );

  static TextStyle label({double size = 14, Color? color}) =>
      GoogleFonts.courierPrime(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? Colors.white70,
        height: 1.4,
      );
}
