// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/confidence_ring.dart';
import '../../core/widgets/evidence_card.dart';
import '../../core/data/models/risk_assessment.dart';
import '../../l10n/app_localizations.dart';
import '../../core/data/database/blocklist_dao.dart';
import '../../core/data/database/trustlist_dao.dart';
import 'package:flutter/services.dart';
import '../../core/data/models/blocked_entity.dart';
import '../../core/providers/risk_provider.dart';
import '../../core/data/database/transaction_dao.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final RiskAssessment? mockAssessment;
  final String? upiUri;
  final bool skipDelay;

  const AnalysisScreen({super.key, this.mockAssessment, this.upiUri, this.skipDelay = false});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  RiskAssessment? _assessment;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    
    if (widget.mockAssessment != null) {
      _assessment = widget.mockAssessment;
      if (widget.skipDelay) {
        _isAnalyzing = false;
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isAnalyzing = false);
        });
      }
    } else {
      _runRealAnalysis();
    }
  }

  Future<void> _runRealAnalysis() async {
    final engine = ref.read(riskFusionEngineProvider);
    // Use recent transactions window to prevent OOM and UI thread starvation
    final history = await TransactionDao().getRecentTransactions(200);
    
    // Parse URI
    String payee = '';
    String name = 'Unknown Merchant';
    double amount = 0.0;
    
    if (widget.upiUri != null) {
      try {
        final uri = Uri.parse(widget.upiUri!);
        payee = uri.queryParameters['pa'] ?? '';
        name = uri.queryParameters['pn'] ?? name;
        amount = double.tryParse(uri.queryParameters['am'] ?? '0') ?? 0.0;
      } catch (_) {}
    }

    final assessment = await engine.assessLiveIntent(
      payeeVpa: payee,
      payeeName: name,
      amount: amount,
      history: history,
    );

    if (mounted) {
      setState(() {
        _assessment = assessment;
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing || _assessment == null) {
      return _buildAnalyzingState();
    }

    final assessment = _assessment!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.paymentAnalysis, style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline progress
            Row(
              children: [
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(width: 4),
                Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
              ],
            ).animate().fadeIn(duration: 400.ms),
            
            const SizedBox(height: 40),
            
            // Confidence Ring
            Center(
              child: ConfidenceRing(
                percentage: assessment.confidenceScore,
                label: assessment.verdict.name,
                isSafe: assessment.verdict == RiskVerdict.safe,
                radius: 110,
                lineWidth: 8,
              ),
            ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            // Explanation Card
            GlassPanel(
              child: Column(
                children: [
                  Text(assessment.explanationTitle, style: AppTypography.headlineLgMobile),
                  const SizedBox(height: 12),
                  Text(
                    assessment.explanationBody, 
                    style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
            
            Text(l10n.aiVerdictBreakdown, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant))
              .animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 16),
            
            // 2x2 Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: assessment.evidence.map((item) => 
                EvidenceCard(item: item).animate().fadeIn(delay: 600.ms).scale(curve: Curves.easeOutBack)
              ).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Action Buttons
            _buildActionButtons(context, assessment, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RiskAssessment assessment, AppLocalizations l10n) {
    if (assessment.verdict == RiskVerdict.safe) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.go('/handoff', extra: {'upiUri': widget.upiUri, 'verdict': assessment.verdict.name});
          },
          icon: Icon(Icons.check_circle_outline, color: AppColors.onPrimary),
          label: Text(l10n.paySecurely, style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0);
    }

    final isUserBlocked = assessment.evidence.any((e) => e.key == 'user_blocked');

    if (isUserBlocked) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => context.go('/dashboard'),
          icon: Icon(Icons.shield_rounded, color: AppColors.onPrimary),
          label: Text(l10n.returnToDashboard, style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0);
    }

    // AI Warned/Blocked, give user choice
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              // Block Payee
              if (widget.upiUri != null) {
                // Extract payee VPA from URI or use a mock logic
                final uri = Uri.parse(widget.upiUri!);
                final pa = uri.queryParameters['pa'] ?? 'unknown_vpa';
                
                final dao = BlocklistDao();
                await dao.blockEntity(BlockedEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  entityValue: pa,
                  entityType: EntityType.upi,
                  timestamp: DateTime.now(),
                ));
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.payeeBlockedSuccess)));
                  context.go('/dashboard');
                }
              } else {
                context.go('/dashboard');
              }
            },
            icon: Icon(Icons.block_rounded, color: AppColors.onPrimary),
            label: Text(l10n.blockPayee, style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              String extractPayee(String? uri) {
                if (uri == null) return '';
                try { return Uri.parse(uri).queryParameters['pa'] ?? ''; } catch(_) { return ''; }
              }
              final payee = extractPayee(widget.upiUri);
              if (widget.upiUri != null && payee.isNotEmpty) {
                await TrustlistDao().trustEntity(BlockedEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  entityValue: payee,
                  entityType: EntityType.upi,
                  timestamp: DateTime.now(),
                ));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.addedToTrustlist(payee))),
                  );
                }
              }
              if (context.mounted) {
                context.go('/handoff', extra: {'upiUri': widget.upiUri, 'verdict': assessment.verdict.name});
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.proceedAnyway, style: AppTypography.titleMd),
          ),
        ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.5, end: 0),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/dashboard');
          },
          child: Text(l10n.cancelPayment, style: AppTypography.titleMd.copyWith(color: AppColors.error)),
        ).animate().fadeIn(delay: 1000.ms),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppDecorations.aiGlowEmerald,
              ),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 32),
            Text('Analyzing Risk Patterns...', style: AppTypography.titleMd)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fade(begin: 0.5, end: 1.0, duration: 1.seconds),
          ],
        ),
      ),
    );
  }
}
