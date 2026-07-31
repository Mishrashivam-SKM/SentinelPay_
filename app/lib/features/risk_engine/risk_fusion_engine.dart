// coverage:ignore-file
import '../../../core/data/models/parsed_transaction.dart';
import '../ml/behaviour_intelligence.dart';
import 'deterministic_intelligence.dart';
import 'statistical_intelligence.dart';

import 'confidence_engine.dart';
import 'explainability_engine.dart';
import '../ml/ml_pipeline_service.dart';
import 'package:uuid/uuid.dart';
import '../../../core/data/models/risk_assessment.dart';

class RiskFusionEngine {
  final BehaviourIntelligence _behaviourIntelligence;
  final DeterministicIntelligence _deterministic = DeterministicIntelligence();
  final StatisticalIntelligence _statistical = StatisticalIntelligence();

  final ConfidenceEngine _confidence = ConfidenceEngine();
  final ExplainabilityEngine _explainability = ExplainabilityEngine();
  late final MlPipelineService _pipelineService;

  RiskFusionEngine(this._behaviourIntelligence) {
    _pipelineService = MlPipelineService(_behaviourIntelligence);
  }

  Future<void> triggerRetraining() async {
    await _pipelineService.retrainOnLatest();
  }

  Future<RiskAssessment> assessLiveIntent({
    required String payeeVpa,
    required String payeeName,
    required double amount,
    required List<ParsedTransaction> history,
    bool isUserBlocked = false,
    bool isUserTrusted = false,
  }) async {
    const uuid = Uuid();
    final current = ParsedTransaction(
      id: uuid.v4(),
      direction: TransactionDirection.debit,
      amount: amount,
      payeeIdentifier: payeeVpa,
      payeeName: payeeName,
      timestamp: DateTime.now(),
      method: PaymentMethod.upi,
      sourceBank: "LiveScan",
      source: 'live',
    );
    return await assessTransaction(
      current: current, 
      history: history, 
      isUserBlocked: isUserBlocked,
      isUserTrusted: isUserTrusted,
    );
  }

  Future<RiskAssessment> assessTransaction({
    required ParsedTransaction current,
    required List<ParsedTransaction> history,
    bool isUserBlocked = false,
    bool isUserTrusted = false,
  }) async {
    // If the user explicitly blocked this payee, hard block it immediately
    if (isUserBlocked) {
      return _explainability.buildAssessment(
        transactionId: current.id ?? '',
        verdict: RiskVerdict.block,
        confidenceScore: 1.0,
        evidenceKeys: ['user_blocked'],
      );
    }

    // 1. Get Statistical/Deterministic Score
    double deterministicScore = await _deterministic.scoreDeterministic(current);
    double statisticalScore = _statistical.scoreStatistical(current, history);
    
    // Deterministic rules override statistical anomalies if they are very high (e.g., hard blocklist)
    double combinedRuleScore = deterministicScore > statisticalScore ? deterministicScore : statisticalScore;
    
    // 2. Get Behavioural Score (Isolation Forest / Anomaly)
    double behaviourScore = _behaviourIntelligence.scoreBehaviour(current, history);
    
    // 3. Fusion Logic (Weighted)
    // If ML is not trained, rely heavily on statistical rules (90/10 split)
    // If ML is trained, balance it (70/30 split favouring behaviour)
    double finalScore = 0.0;
    if (_behaviourIntelligence.isTrained) {
      finalScore = (combinedRuleScore * 0.3) + (behaviourScore * 0.7);
    } else {
      finalScore = (combinedRuleScore * 0.9) + (behaviourScore * 0.1);
    }

    // If the user explicitly trusted this payee, apply "Trust but Verify" logic
    if (isUserTrusted) {
      // Threshold set to 5000 by default for user preference (P0-15 fix)
      if (current.amount > 5000 || behaviourScore > 0.75 || finalScore > 0.6) {
        // High anomaly despite trust -> Downgrade to Caution
        return _explainability.buildAssessment(
          transactionId: current.id ?? '',
          verdict: RiskVerdict.caution,
          confidenceScore: _confidence.calculateConfidence(
            historySize: history.length, 
            verdict: RiskVerdict.caution, 
            finalScore: finalScore,
            isModelTrained: _behaviourIntelligence.isTrained,
          ),
          evidenceKeys: ['trusted_but_anomalous', 'high_value'],
        );
      } else {
        // Safe and trusted
        return _explainability.buildAssessment(
          transactionId: current.id ?? '',
          verdict: RiskVerdict.safe,
          confidenceScore: 0.85, // Cap confidence so it's not absolute
          evidenceKeys: ['trusted_by_user'],
        );
      }
    }

    // Map to verdict for non-trusted
    RiskVerdict verdict;
    if (finalScore >= 0.8) {
      verdict = RiskVerdict.block;
    } else if (finalScore >= 0.6) {
      verdict = RiskVerdict.caution;
    } else {
      verdict = RiskVerdict.safe;
    }

    // Determine confidence
    double confidenceScore = _confidence.calculateConfidence(
      historySize: history.length, 
      verdict: verdict, 
      finalScore: finalScore,
      isModelTrained: _behaviourIntelligence.isTrained,
    );

    List<String> evidenceKeys = [];

    // Warn instead of block if confidence is low, but QR/merchant is correct/known
    if (verdict == RiskVerdict.block && confidenceScore < 0.5) {
      verdict = RiskVerdict.caution;
      evidenceKeys.add('low_confidence_warning');
    }

    // Generate evidence keys internally based on rules
    if (deterministicScore > 0.8) evidenceKeys.add('known_scammer');
    if (current.amount > 50000) evidenceKeys.add('high_value');
    if (behaviourScore < 0.3) evidenceKeys.add('typical_behaviour');
    if (history.any((t) => t.payeeName == current.payeeName)) evidenceKeys.add('known_merchant');
    
    // Explicitly let user know who they are paying
    evidenceKeys.add('payee_details_visible');
    
    if (evidenceKeys.isEmpty) evidenceKeys.add('insufficient_history');

    // Build human readable assessment
    return _explainability.buildAssessment(
      transactionId: current.id ?? '',
      verdict: verdict,
      confidenceScore: confidenceScore,
      evidenceKeys: evidenceKeys,
    );
  }
}
