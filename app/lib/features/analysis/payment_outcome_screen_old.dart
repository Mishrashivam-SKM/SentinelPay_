// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/utils/upi_parser.dart';
import '../../core/data/database/transaction_dao.dart';
import '../../core/data/models/parsed_transaction.dart';

class PaymentOutcomeScreen extends StatelessWidget {
  final String? upiUri;
  
  const PaymentOutcomeScreen({super.key, this.upiUri});

  Future<void> _recordTransaction(bool success) async {
    if (upiUri == null) return;
    final parser = UpiParser(upiUri!);
    if (!parser.isValidUpiUri) return;
    
    if (success) {
      final tx = ParsedTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        direction: TransactionDirection.debit,
        amount: parser.amount ?? 0.0,
        payeeIdentifier: parser.payeeVpa ?? 'unknown@upi',
        payeeName: parser.payeeName ?? 'Unknown Entity',
        timestamp: DateTime.now(),
        method: PaymentMethod.upi,
        sourceBank: "Sentinel_Logged",
        source: 'live',
      );
      await TransactionDao().insertTransaction(tx);
    }
  }

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
                onTap: () async {
                  await _recordTransaction(true);
                  if (context.mounted) context.go('/dashboard');
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
                onTap: () async {
                  await _recordTransaction(false);
                  if (context.mounted) context.go('/dashboard');
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
