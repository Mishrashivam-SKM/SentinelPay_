// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/risk_verdict_badge.dart';
import '../../core/data/models/risk_assessment.dart';
import '../../core/data/models/parsed_transaction.dart';
import '../../core/data/database/transaction_dao.dart';
import '../../core/widgets/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TransactionDao _dao = TransactionDao();
  final ScrollController _scrollController = ScrollController();
  final List<ParsedTransaction> _transactions = [];
  bool _isLoading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchTransactions();
    }
  }

  Future<void> _fetchTransactions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    DateTime? lastTimestamp;
    String? lastId;
    if (_transactions.isNotEmpty) {
      final lastTx = _transactions.last;
      lastTimestamp = lastTx.timestamp;
      lastId = lastTx.id;
    }

    final newTxs = await _dao.getTransactionsCursor(lastTimestamp, lastId, 20);
    if (!mounted) return;
    
    setState(() {
      _transactions.addAll(newTxs);
      _isLoading = false;
      if (newTxs.length < 20) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Transaction History', style: AppTypography.titleMd),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: AppColors.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filtering coming in V2')));
            },
          ),
        ],
      ),
      body: _transactions.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const EmptyState(
                  title: 'No Transactions',
                  message: 'Your payment history will appear here once you make your first secure payment.',
                  icon: Icons.history_rounded,
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0),
                  itemCount: _transactions.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == _transactions.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final tx = _transactions[index];
                    final time = '${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}';
                    
                    // Map the saved string verdict back to the enum, default to safe if null
                    RiskVerdict parsedVerdict = RiskVerdict.safe;
                    if (tx.verdict != null) {
                      try {
                        parsedVerdict = RiskVerdict.values.byName(tx.verdict!);
                      } catch (_) {
                        // Fallback to safe if parsing fails
                      }
                    }
                    
                    return _buildHistoryItem(
                      context, 
                      tx,
                      tx.payeeName ?? 'Unknown', 
                      time, 
                      tx.amount.toStringAsFixed(0), 
                      parsedVerdict, 
                      Icons.swap_horiz_rounded
                    );
                  },
                ),
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ParsedTransaction tx, String name, String time, String amount, RiskVerdict verdict, IconData icon) {
    return GestureDetector(
      onTap: () => context.push('/transaction_detail', extra: tx),
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
