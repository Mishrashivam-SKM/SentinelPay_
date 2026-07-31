// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HandoffScreen extends ConsumerWidget {
  final String? upiUri;
  final String? verdict;
  
  const HandoffScreen({super.key, this.upiUri, this.verdict});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Complete Payment', style: AppTypography.titleMd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sentinel has cleared this transaction.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your UPI app to complete the payment.',
              style: AppTypography.headlineLgMobile,
            ),
            
            const SizedBox(height: 48),
            
            _buildAppRow(context, ref, 'Complete Payment with UPI', Icons.mobile_friendly_rounded, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAppRow(BuildContext context, WidgetRef ref, String appName, IconData icon, Color brandColor) {
    return GlassPanel(
      onTap: () async {
        if (upiUri != null) {
          final uri = Uri.parse(upiUri!);
          
          if (uri.scheme != 'upi') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid payment link blocked.')),
            );
            return;
          }

          // Show security warning dialog
          final bool? proceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Security Verification'),
              content: const Text(
                'You are about to be redirected to complete this payment.\n\n'
                'WARNING: To prevent hijacking, please ensure you select a trusted, verified UPI app (like Google Pay, PhonePe, or BHIM) from the chooser menu on the next screen.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Proceed Safely'),
                ),
              ],
            ),
          );

          if (proceed == true) {
            if (await canLaunchUrl(uri)) {
               final prefs = await SharedPreferences.getInstance();
               await prefs.setString('pending_verdict', verdict ?? 'safe');
               
               await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
               debugPrint("Cannot launch UPI intent, probably on emulator with no apps installed.");
            }
            
            if (context.mounted) {
               context.go('/dashboard', extra: {'syncingUri': upiUri});
            }
          }
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: brandColor.withValues(alpha: 0.2),
            child: Icon(icon, color: brandColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(appName, style: AppTypography.titleMd),
          ),
          Icon(Icons.open_in_new_rounded, color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}
