import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/widgets/glass_panel.dart';
import '../../core/widgets/confidence_ring.dart';
import '../../core/widgets/evidence_card.dart';
import '../../core/data/models/risk_assessment.dart';

class AnalysisScreen extends StatefulWidget {
  final RiskAssessment? mockAssessment;
  final bool skipDelay;

  const AnalysisScreen({super.key, this.mockAssessment, this.skipDelay = false});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late final RiskAssessment _assessment;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    
    // Use injected assessment or fallback to mock
    _assessment = widget.mockAssessment ?? RiskAssessment(
    transactionId: 'mock_123',
    verdict: RiskVerdict.safe,
    confidenceScore: 0.98,
    evidence: [
      EvidenceItem(key: 'known', label: 'Known Merchant', detail: 'Transacted 12 times', isPositive: true),
      EvidenceItem(key: 'vpa', label: 'Verified VPA', detail: 'Bank authenticated', isPositive: true),
      EvidenceItem(key: 'loc', label: 'Typical Location', detail: 'Matches device GPS', isPositive: true),
      EvidenceItem(key: 'vel', label: 'Normal Velocity', detail: 'No rapid attempts', isPositive: true),
    ],
    explanationTitle: 'Transaction Cleared',
    explanationBody: 'This payment looks safe based on your history and merchant behavior.',
    );

    if (widget.skipDelay) {
      _isAnalyzing = false;
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isAnalyzing = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return _buildAnalyzingState();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('SentinelPay', style: AppTypography.titleMd.copyWith(color: AppColors.primary)),
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
                percentage: _assessment.confidenceScore,
                label: _assessment.verdict.name,
                isSafe: _assessment.verdict == RiskVerdict.safe,
                radius: 110,
                lineWidth: 8,
              ),
            ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            // Explanation Card
            GlassPanel(
              child: Column(
                children: [
                  Text(_assessment.explanationTitle, style: AppTypography.headlineLgMobile, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    _assessment.explanationBody, 
                    style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
            
            Text('AI VERDICT BREAKDOWN', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant))
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
              children: _assessment.evidence.map((item) => 
                EvidenceCard(item: item).animate().fadeIn(delay: 600.ms).scale(curve: Curves.easeOutBack)
              ).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/handoff'),
                icon: Icon(Icons.check_circle_outline, color: AppColors.onPrimary),
                label: Text(
                  _assessment.verdict == RiskVerdict.safe ? 'Pay Securely' : 'Cancel Payment', 
                  style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _assessment.verdict == RiskVerdict.safe ? AppColors.primary : AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
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
