// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final TextStyle displayLg = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.02,
  );

  static final TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: -0.01,
  );

  static final TextStyle headlineLgMobile = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static final TextStyle titleMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static final TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static final TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static final TextStyle numberData = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static final TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.05,
  );
}
