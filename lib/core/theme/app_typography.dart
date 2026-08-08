import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme build() {
    return GoogleFonts.interTextTheme().copyWith(
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.32,
        fontWeight: FontWeight.w600,
      ),
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        height: 64 / 57,
        letterSpacing: -1.14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
