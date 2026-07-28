import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/risk_verdict_badge.dart';
import '../../core/data/models/risk_assessment.dart';
import '../../core/data/models/parsed_transaction.dart';
import '../../core/data/database/transaction_dao.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TransactionDao _dao = TransactionDao();

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
      body: FutureBuilder<List<ParsedTransaction>>(
        future: _dao.getAllTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No transactions found.', style: AppTypography.bodyLg),
            );
          }

          final transactions = snapshot.data!.reversed.toList(); // Newest first

          return ListView.separated(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final time = '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}';
              
              // Simplistic mapping for now since historical SMS doesn't have an exact risk verdict.
              // In production we would save the risk assessment along with the transaction.
              RiskVerdict dummyVerdict = RiskVerdict.safe;
              if (tx.amount > 50000) dummyVerdict = RiskVerdict.caution; // Example threshold
              
              return _buildHistoryItem(
                context, 
                tx.payeeName ?? 'Unknown', 
                time, 
                tx.amount.toStringAsFixed(0), 
                dummyVerdict, 
                Icons.swap_horiz_rounded
              );
            },
          );
        },
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
                  Text(name, style: AppTypography.bodyLg, maxLines: 1, overflow: TextOverflow.ellipsis),
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
