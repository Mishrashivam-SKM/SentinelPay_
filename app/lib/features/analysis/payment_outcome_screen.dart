import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';

class PaymentOutcomeScreen extends StatelessWidget {
  const PaymentOutcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text('Welcome Back', style: AppTypography.headlineLg),
              const SizedBox(height: 16),
              Text(
                'Did this payment go through successfully? This helps the AI learn your behavior.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
              
              const SizedBox(height: 48),
              
              GlassPanel(
                onTap: () {
                  // Updates database as successful
                  context.go('/dashboard');
                },
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.primary, size: 28),
                    const SizedBox(width: 16),
                    Text('Yes, payment successful', style: AppTypography.titleMd),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              GlassPanel(
                onTap: () {
                  // Updates database as failed/cancelled
                  context.go('/dashboard');
                },
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: AppColors.error, size: 28),
                    const SizedBox(width: 16),
                    Text('No, I cancelled / it failed', style: AppTypography.titleMd),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
