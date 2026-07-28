import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';

class HandoffScreen extends StatelessWidget {
  const HandoffScreen({super.key});

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
      onTap: () {
        // Simulate Android Intent routing, then immediately return to outcome screen
        context.go('/payment_outcome');
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
