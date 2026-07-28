import '../../../core/data/models/parsed_transaction.dart';
import '../ml/behaviour_intelligence.dart';
import 'deterministic_intelligence.dart';
import 'statistical_intelligence.dart';
import 'confidence_engine.dart';
import 'explainability_engine.dart';
import '../../../core/data/models/risk_assessment.dart';

class RiskFusionEngine {
  final BehaviourIntelligence _behaviourIntelligence;
  final DeterministicIntelligence _deterministic = DeterministicIntelligence();
  final StatisticalIntelligence _statistical = StatisticalIntelligence();
  final ConfidenceEngine _confidence = ConfidenceEngine();
  final ExplainabilityEngine _explainability = ExplainabilityEngine();

  RiskFusionEngine(this._behaviourIntelligence);

  RiskAssessment assessTransaction(ParsedTransaction current, List<ParsedTransaction> history) {
    // Gather scores
    double behaviourScore = _behaviourIntelligence.scoreBehaviour(current, history);
    double deterministicScore = _deterministic.scoreDeterministic(current);
    double statisticalScore = _statistical.scoreStatistical(current, history);
    
    // Simple Fusion Logic
    // Deterministic takes precedence if it's very high
    double finalScore = 0.0;
    if (deterministicScore > 0.8) {
      finalScore = deterministicScore;
    } else {
      // Weighted average otherwise (ML gets highest weight)
      finalScore = (behaviourScore * 0.7) + (statisticalScore * 0.3);
    }
    
    // Map to verdict
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
    
    // Generate evidence keys internally based on rules
    List<String> evidenceKeys = [];
    if (deterministicScore > 0.8) evidenceKeys.add('known_scammer');
    if (current.amount > 50000) evidenceKeys.add('high_value');
    if (behaviourScore < 0.3) evidenceKeys.add('typical_behaviour');
    if (history.any((t) => t.payeeName == current.payeeName)) evidenceKeys.add('known_merchant');
    
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
