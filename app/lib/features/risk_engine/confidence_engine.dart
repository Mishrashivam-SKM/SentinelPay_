import '../../../core/data/models/risk_assessment.dart';

class ConfidenceEngine {
  double calculateConfidence({
    required int historySize,
    required RiskVerdict verdict,
    required double finalScore,
    required bool isModelTrained,
  }) {
    // Base confidence starts at 0.5 (neutral)
    double confidence = 0.5;
    
    if (!isModelTrained || historySize < 15) {
      return 0.5; // We have low confidence if model lacks data
    }
    
    // Confidence grows with history size up to 200
    double dataFactor = (historySize > 200 ? 200 : historySize) / 200.0; // 0.0 to 1.0
    
    // Adjust confidence based on how extreme the score is
    // A score of 0.1 (very safe) or 0.9 (very risky) implies high confidence
    // A score of 0.5 (neutral) implies low confidence
    double scoreExtremity = (finalScore - 0.5).abs() * 2.0; // 0.0 to 1.0
    
    confidence = 0.5 + (0.5 * dataFactor * scoreExtremity);
    
    // Clamp to 0.0 - 1.0 just in case
    if (confidence > 1.0) confidence = 1.0;
    if (confidence < 0.0) confidence = 0.0;
    
    return confidence;
  }
}
