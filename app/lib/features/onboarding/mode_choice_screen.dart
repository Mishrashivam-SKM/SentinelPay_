import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';

class ModeChoiceScreen extends StatelessWidget {
  const ModeChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              
              Text(
                'How would you like to start?',
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: 16),
              Text(
                'Choose a mode to proceed. You can change this later in settings.',
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
              
              const SizedBox(height: 48),
              
              // Protect My Payments
              _buildChoiceCard(
                context,
                title: 'Protect My Payments',
                description: 'Use SentinelPay as your daily security layer for real UPI transactions.',
                icon: Icons.security_rounded,
                isPrimary: true,
                onTap: () => context.go('/pin_setup'),
              ),
              
              const SizedBox(height: 24),
              
              // Experience Demo Mode
              _buildChoiceCard(
                context,
                title: 'Experience Sentinel AI',
                description: 'Demo mode. Scan simulated fraud QR codes to see how the AI works without real payments.',
                icon: Icons.science_outlined,
                isPrimary: false,
                onTap: () => context.go('/pin_setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPrimary ? AppColors.primary.withOpacity(0.5) : AppColors.outlineVariant,
            width: isPrimary ? 2 : 1,
          ),
          boxShadow: isPrimary ? AppDecorations.aiGlow : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.primaryContainer.withOpacity(0.3) : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isPrimary ? AppColors.primary : AppColors.onSurface, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMd.copyWith(color: isPrimary ? AppColors.primary : AppColors.onSurface)),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
