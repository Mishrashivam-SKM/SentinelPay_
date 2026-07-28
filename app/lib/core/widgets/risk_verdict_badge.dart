import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../core/data/models/risk_assessment.dart';

class RiskVerdictBadge extends StatelessWidget {
  final RiskVerdict verdict;
  final bool compact;

  const RiskVerdictBadge({
    super.key,
    required this.verdict,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    String text;
    IconData icon;

    switch (verdict) {
      case RiskVerdict.safe:
        bgColor = AppColors.primaryContainer.withOpacity(0.2);
        fgColor = AppColors.primary;
        text = 'SAFE';
        icon = Icons.check_circle_outline_rounded;
        break;
      case RiskVerdict.caution:
        bgColor = AppColors.tertiaryContainer.withOpacity(0.2);
        fgColor = AppColors.tertiary;
        text = 'CAUTION';
        icon = Icons.error_outline_rounded;
        break;
      case RiskVerdict.block:
        bgColor = AppColors.errorContainer.withOpacity(0.3);
        fgColor = AppColors.error;
        text = 'HIGH RISK';
        icon = Icons.block_flipped;
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: fgColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fgColor),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTypography.labelCaps.copyWith(color: fgColor, fontSize: 10),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fgColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fgColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.labelCaps.copyWith(color: fgColor),
          ),
        ],
      ),
    );
  }
}
