// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';

class SmsPermissionScreen extends StatelessWidget {
  const SmsPermissionScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    final status = await Permission.sms.request();
    if (context.mounted) {
      if (status.isGranted) {
        context.go('/parse_progress');
      } else {
        // Permission denied, cleanly fallback to demo mode
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS access denied. Running in Demo Mode.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/mode_choice');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sms_rounded, color: AppColors.primary, size: 48),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                Text(
                  'Sentinel needs SMS access\nto protect you.',
                  style: AppTypography.headlineLg,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 16),
                
                Text(
                  'To build your personalized AI fraud model, we need to analyze your past payment messages.',
                  style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 48),
                
                GlassPanel(
                  child: Column(
                    children: [
                      _buildFeatureRow(
                        Icons.check_circle_rounded,
                        AppColors.primary,
                        'We only read bank & payment SMS',
                      ),
                      const Divider(height: 32, color: AppColors.outlineVariant),
                      _buildFeatureRow(
                        Icons.lock_rounded,
                        AppColors.primary,
                        'Analysis happens entirely on your phone',
                      ),
                      const Divider(height: 32, color: AppColors.outlineVariant),
                      _buildFeatureRow(
                        Icons.cancel_rounded,
                        AppColors.error,
                        'We NEVER read personal chats',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _requestPermission(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text('Allow Access', style: AppTypography.titleMd),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 16),
                
                Center(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Running in Demo Mode.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                      context.go('/mode_choice');
                    },
                    child: Text(
                      'Not now (Use Demo Mode)',
                      style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
