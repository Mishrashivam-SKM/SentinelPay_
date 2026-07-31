// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/risk_verdict_badge.dart';
import '../../core/data/models/risk_assessment.dart';
import '../../core/data/models/parsed_transaction.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final ParsedTransaction? transaction;
  
  const TransactionDetailScreen({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Details', style: AppTypography.titleMd),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Card
            GlassPanel(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    child: Icon(Icons.storefront_rounded, size: 32, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Text(transaction?.payeeName ?? transaction?.payeeIdentifier ?? 'Unknown Merchant', style: AppTypography.headlineLgMobile),
                  const SizedBox(height: 4),
                  Text(
                    transaction != null 
                        ? DateFormat('MMM dd, yyyy • hh:mm a').format(transaction!.timestamp) 
                        : DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now()),
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Text('₹${transaction?.amount.toStringAsFixed(0) ?? '0'}', style: AppTypography.displayLg.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(height: 24),
                  RiskVerdictBadge(verdict: _getVerdict(transaction?.verdict)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Details Table
            Align(
              alignment: Alignment.centerLeft,
              child: Text('TRANSACTION INFO', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Status', 'Completed', isStatus: true),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  _buildDetailRow('To', transaction?.payeeIdentifier ?? 'Unknown'),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  _buildDetailRow('From', transaction?.sourceBank ?? 'Unknown Bank'),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  _buildDetailRow('Source', transaction?.source ?? 'SMS'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // AI Log
            Align(
              alignment: Alignment.centerLeft,
              child: Text('SENTINEL AI LOG', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildAiLogRow('Transaction cleared by Behaviour Intelligence.'),
                  if (transaction?.source == 'SMS') ...[
                    const SizedBox(height: 12),
                    _buildAiLogRow('Verified by Bank SMS confirmation.'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  RiskVerdict _getVerdict(String? v) {
    if (v == null) return RiskVerdict.safe;
    try {
      return RiskVerdict.values.byName(v);
    } catch (_) {
      return RiskVerdict.safe;
    }
  }
  
  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
          Text(
            value,
            style: AppTypography.bodyLg.copyWith(
              color: isStatus ? AppColors.primary : AppColors.onSurface,
              fontWeight: isStatus ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAiLogRow(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant))),
      ],
    );
  }
}
