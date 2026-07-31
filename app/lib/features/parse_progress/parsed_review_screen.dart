// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/data/models/parsed_transaction.dart';
import '../../core/data/database/transaction_dao.dart';
import 'package:intl/intl.dart';

class ParsedReviewScreen extends StatefulWidget {
  const ParsedReviewScreen({super.key});

  @override
  State<ParsedReviewScreen> createState() => _ParsedReviewScreenState();
}

class _ParsedReviewScreenState extends State<ParsedReviewScreen> {
  List<ParsedTransaction> _sampleTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealTransactions();
  }

  Future<void> _loadRealTransactions() async {
    final dao = TransactionDao();
    final allTx = await dao.getAllTransactions();
    
    // Get up to 3 most recent transactions
    allTx.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _sampleTransactions = allTx.take(3).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Data Extracted', style: AppTypography.titleMd),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transparency First',
                style: AppTypography.headlineLg,
              ),
              const SizedBox(height: 16),
              Text(
                'We successfully parsed your transaction history to train your local AI. Here is a sample of what SentinelPay "sees".',
                style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _sampleTransactions.isEmpty
                    ? Center(child: Text('No transactions found.', style: AppTypography.bodyLg))
                    : ListView.separated(
                        itemCount: _sampleTransactions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = _sampleTransactions[index];
                          return GlassPanel(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, color: AppColors.primary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tx.payeeName ?? tx.payeeIdentifier ?? 'Unknown', style: AppTypography.titleMd),
                                      Text(
                                        DateFormat('MMM dd • ').format(tx.timestamp) + tx.method.name.toUpperCase(),
                                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                Text('₹${tx.amount.toInt()}', style: AppTypography.titleMd),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This extracted data is stored securely on your device. Raw SMS messages have already been discarded.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/mode_choice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text('Looks Good', style: AppTypography.titleMd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
