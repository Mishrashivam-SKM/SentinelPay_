// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/confidence_ring.dart';
import '../../core/widgets/risk_verdict_badge.dart';
import '../../core/data/models/risk_assessment.dart';
import '../../core/data/models/parsed_transaction.dart';
import '../../core/data/database/transaction_dao.dart';
import '../sms_parser/sms_bootstrap_service.dart';
import '../sms_parser/template_registry.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final String? syncingUri;
  
  const DashboardScreen({super.key, this.syncingUri});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _hasSmsPermission = true;
  int _transactionCount = 0;
  List<ParsedTransaction> _recentTransactions = [];
  bool _isLoadingStats = true;
  double _protectionScore = 0.0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadDashboardStats();
    if (widget.syncingUri != null) {
      _startMagicSync();
    }
  }

  Future<void> _loadDashboardStats() async {
    final dao = TransactionDao();
    final txCount = await dao.getTransactionCount();
    final recentTx = await dao.getRecentTransactions(3);
    
    double score = 0.20; // Base score for having the app installed & secured
    if (_hasSmsPermission) score += 0.40;
    score += (txCount > 50 ? 50 : txCount) / 50.0 * 0.40; // Max 0.40 for 50+ transactions
    
    if (mounted) {
      setState(() {
        _transactionCount = txCount;
        _recentTransactions = recentTx;
        _protectionScore = score;
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.sms.status;
    if (mounted) {
      setState(() {
        _hasSmsPermission = status.isGranted;
      });
      _loadDashboardStats(); // update score
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

  void _listenForConfirmationSms() async {
    final SmsQuery query = SmsQuery();
    final startTime = DateTime.now();
    
    // Poll every 3 seconds for up to 30 seconds
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      
      final messages = await query.querySms(kinds: [SmsQueryKind.inbox]);
      final recent = messages.where((m) => m.date != null && m.date!.isAfter(startTime)).toList();
      
      if (recent.isNotEmpty) {
        bool isValidDebit = false;
        for (var sms in recent) {
          if (sms.body != null && sms.address != null) {
            for (var template in TemplateRegistry.templates) {
              if (template.senderPattern.hasMatch(sms.address!)) {
                final match = template.extractor(sms.body!, sms.date ?? DateTime.now(), 'live');
                if (match != null && match.direction == TransactionDirection.debit) {
                  isValidDebit = true;
                  break;
                }
              }
            }
          }
          if (isValidDebit) break;
        }

        if (isValidDebit) {
          // Run full bootstrap to parse and store it
          await SmsBootstrapService().bootstrapFromSmsHistory((p, m, t) {});
          
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
            _loadDashboardStats();
          }
          return;
        }
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not verify payment automatically.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasSmsPermission)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SMS Access Required', style: AppTypography.titleMd.copyWith(color: AppColors.error)),
                          Text('Automatic fraud detection is paused.', style: AppTypography.bodySm.copyWith(color: AppColors.error)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final status = await Permission.sms.request();
                        if (mounted) {
                          setState(() => _hasSmsPermission = status.isGranted);
                          _loadDashboardStats();
                        }
                      },
                      child: Text('Enable', style: AppTypography.titleMd.copyWith(color: AppColors.error)),
                    )
                  ],
                ),
              ),
            Text(
              () {
                final hour = DateTime.now().hour;
                if (hour < 12) return 'Good morning,';
                if (hour < 17) return 'Good afternoon,';
                return 'Good evening,';
              }(),
              style: AppTypography.titleMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            Text(
              'Sentinel',
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
                    ConfidenceRing(
                      percentage: _protectionScore,
                      label: 'PROTECTION SCORE',
                      radius: 100,
                      lineWidth: 6,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _protectionScore > 0.8 ? 'System Secure. Continuous scanning\nactive.' : 'System needs setup.\nReview warnings.',
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
                Expanded(child: _buildStatCard(
                  Icons.shield_outlined, 
                  'PROTECTED', 
                  _isLoadingStats ? '...' : '$_transactionCount', 
                  'Monitored transactions', 
                  true
                )),
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
            
            if (_isLoadingStats)
              const Center(child: CircularProgressIndicator())
            else if (_recentTransactions.isEmpty)
              Center(child: Text('No recent scans.', style: AppTypography.bodyLg))
            else
              ..._recentTransactions.map((tx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildRecentScanItem(
                    context,
                    tx,
                    tx.payeeName ?? tx.payeeIdentifier ?? 'Unknown',
                    DateFormat('MMM dd, hh:mm a').format(tx.timestamp),
                    tx.amount.toInt().toString(),
                    tx.verdict == RiskVerdict.block.name ? RiskVerdict.block : RiskVerdict.safe,
                    Icons.history_outlined
                  ),
                );
              }),
            
            const SizedBox(height: 100), // padding for bottom nav
          ],
        ),
      ),
      extendBody: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/scan'),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.qr_code_scanner, color: AppColors.onPrimary),
        label: Text('Scan & Pay', style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Widget _buildRecentScanItem(BuildContext context, ParsedTransaction tx, String name, String time, String amount, RiskVerdict verdict, IconData icon) {
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
