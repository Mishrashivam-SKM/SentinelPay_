import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';

class HandoffScreen extends StatelessWidget {
  final String? upiUri;
  
  const HandoffScreen({super.key, this.upiUri});

  @override
  Widget build(BuildContext context) {
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
            
            _buildAppRow(context, 'Launch Any UPI App (Default)', Icons.mobile_friendly_rounded, Colors.green),
            const SizedBox(height: 16),
            _buildAppRow(context, 'Google Pay', Icons.g_mobiledata_rounded, Colors.blue),
            const SizedBox(height: 16),
            _buildAppRow(context, 'PhonePe', Icons.mobile_friendly_rounded, Colors.purple),
            const SizedBox(height: 16),
            _buildAppRow(context, 'Paytm', Icons.payment_rounded, Colors.lightBlue),
            const SizedBox(height: 16),
            _buildAppRow(context, 'BHIM', Icons.account_balance_wallet_rounded, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildAppRow(BuildContext context, String appName, IconData icon, Color brandColor) {
    return GlassPanel(
      onTap: () async {
        if (upiUri != null) {
          final uri = Uri.parse(upiUri!);
          if (await canLaunchUrl(uri)) {
             await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
             // In emulator without UPI apps, fallback to just going to outcome screen to mock success
             debugPrint("Cannot launch UPI intent, probably on emulator with no apps installed.");
          }
        }
        
        // After returning from the external app (or immediately if it failed), go to dashboard for magic sync
        if (context.mounted) {
           context.go('/dashboard', extra: {'syncingUri': upiUri});
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: brandColor.withOpacity(0.2),
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
