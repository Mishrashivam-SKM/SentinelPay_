// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';

class ConfidenceRing extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final String label;
  final double radius;
  final double lineWidth;
  final bool isSafe;

  const ConfidenceRing({
    super.key,
    required this.percentage,
    required this.label,
    this.radius = 80.0,
    this.lineWidth = 4.0,
    this.isSafe = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSafe ? AppColors.primary : AppColors.error;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: CircularPercentIndicator(
        radius: radius,
        lineWidth: lineWidth,
        percent: percentage,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: AppColors.surfaceContainerHigh,
        linearGradient: isSafe ? AppDecorations.aiGradientReverse : null,
        progressColor: isSafe ? null : color,
        animation: true,
        animationDuration: 1500,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSafe ? Icons.shield_outlined : Icons.warning_amber_rounded,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              '${(percentage * 100).toInt()}%',
              style: AppTypography.displayLg.copyWith(color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
