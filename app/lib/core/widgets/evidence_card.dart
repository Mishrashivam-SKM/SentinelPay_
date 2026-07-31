// coverage:ignore-file
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../core/data/models/risk_assessment.dart';

class EvidenceCard extends StatelessWidget {
  final EvidenceItem item;

  const EvidenceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isPositive ? AppColors.primary : AppColors.tertiary;
    final icon = item.isPositive ? Icons.check_circle_outline : Icons.info_outline;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            item.detail,
            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
