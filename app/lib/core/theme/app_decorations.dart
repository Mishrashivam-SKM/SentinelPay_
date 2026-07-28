import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const glassmorphism = BoxDecoration(
    color: Color(0x0AFFFFFF), // ~4% opacity white
    border: Border.fromBorderSide(BorderSide(color: Color(0x1AFFFFFF))), // ~10% opacity white
  );

  static const aiGlow = [
    BoxShadow(
      color: Color(0x336366F1), // ~20% opacity indigo
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  static const aiGlowEmerald = [
    BoxShadow(
      color: Color(0x264EDEA3), // ~15% primary
      blurRadius: 40,
      spreadRadius: 10,
    ),
  ];

  static const aiGradient = LinearGradient(
    colors: [Color(0xFF6366F1), AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const aiGradientReverse = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
