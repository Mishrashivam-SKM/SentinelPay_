import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/confidence_ring.dart';
import '../../core/widgets/risk_verdict_badge.dart';
import '../../core/data/models/risk_assessment.dart';

class DashboardScreen extends StatefulWidget {
  final String? syncingUri;
  
  const DashboardScreen({super.key, this.syncingUri});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.syncingUri != null) {
      _startMagicSync();
    }
  }

  void _startMagicSync() {
    // We will show a dialog or snackbar indicating sync is active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text('Waiting for bank confirmation SMS...', style: AppTypography.bodyLg),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(minutes: 5), // Keep active until SMS arrives
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Start SMS Listener here using telephony
      _listenForConfirmationSms();
    });
  }

  void _listenForConfirmationSms() {
    // Mocking the listener behavior for now
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 16),
                Text('Payment confirmed securely!', style: AppTypography.bodyLg),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
          ),
        ),
        title: Text(
          'SentinelPay',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening,',
              style: AppTypography.titleMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            Text(
              'Ananya',
              style: AppTypography.headlineLg,
            ),
            
            const SizedBox(height: 32),
            
            // Protection Score Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Center(
                child: Column(
                  children: [
                    const ConfidenceRing(
                      percentage: 0.98,
                      label: 'PROTECTION SCORE',
                      radius: 100,
                      lineWidth: 6,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'System Secure. Continuous scanning\nactive.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.shield_outlined, 'PROTECTED', '1,248', '+ 12 this week', true)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.psychology_outlined, 'BEHAVIOUR', 'High', 'Biometrics match', false)),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Quick Scan Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () => context.go('/scan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, // Important for gradient background
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppDecorations.aiGradientReverse,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: AppColors.onPrimary),
                        const SizedBox(width: 12),
                        Text('Quick Scan & Pay', style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Scans', style: AppTypography.titleMd),
                TextButton(
                  onPressed: () => context.go('/history'),
                  child: Text('View All', style: AppTypography.bodySm.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildRecentScanItem('Coffee House', 'Today, 09:41 AM', '450', RiskVerdict.safe, Icons.storefront_outlined),
            const SizedBox(height: 12),
            _buildRecentScanItem('Fresh Mart', 'Yesterday, 18:20', '1,200', RiskVerdict.safe, Icons.shopping_bag_outlined),
            const SizedBox(height: 12),
            _buildRecentScanItem('Unknown Vendor', 'Oct 12, 14:30', '5,500', RiskVerdict.caution, Icons.help_outline),
            
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, String subtitle, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.headlineLg),
          const SizedBox(height: 4),
          Text(
            subtitle, 
            style: AppTypography.bodySm.copyWith(
              color: isPositive ? AppColors.primary : AppColors.onSurfaceVariant
            )
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanItem(String name, String time, String amount, RiskVerdict verdict, IconData icon) {
    return Container(
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
    );
  }
}
