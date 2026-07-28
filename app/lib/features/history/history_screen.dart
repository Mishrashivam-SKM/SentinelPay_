import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/risk_verdict_badge.dart';
import '../../core/data/models/risk_assessment.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Transaction History', style: AppTypography.titleMd),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Today', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          _buildHistoryItem(context, 'Coffee House', '09:41 AM', '450', RiskVerdict.safe, Icons.storefront_outlined),
          const SizedBox(height: 12),
          _buildHistoryItem(context, 'Fresh Mart', '08:20 AM', '1,200', RiskVerdict.safe, Icons.shopping_bag_outlined),
          
          const SizedBox(height: 32),
          Text('Yesterday', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          
          _buildHistoryItem(context, 'Unknown Vendor', '14:30', '5,500', RiskVerdict.caution, Icons.help_outline),
          const SizedBox(height: 12),
          _buildHistoryItem(context, 'Electric Bill', '10:00', '2,400', RiskVerdict.safe, Icons.bolt_outlined),
          
          const SizedBox(height: 100), // Bottom nav padding
        ],
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String name, String time, String amount, RiskVerdict verdict, IconData icon) {
    return GestureDetector(
      onTap: () => context.go('/transaction_detail'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.bodyLg),
                  Text(time, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹$amount', style: AppTypography.numberData),
                const SizedBox(height: 4),
                RiskVerdictBadge(verdict: verdict, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
