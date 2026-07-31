// coverage:ignore-file
import '../../../core/data/models/risk_assessment.dart';

class ExplainabilityEngine {
  RiskAssessment buildAssessment({
    required String transactionId,
    required RiskVerdict verdict,
    required double confidenceScore,
    required List<String> evidenceKeys,
  }) {
    String title = '';
    String body = '';
    
    switch (verdict) {
      case RiskVerdict.safe:
        title = 'Transaction Cleared';
        body = 'This payment looks safe based on your history and merchant behavior.';
        break;
      case RiskVerdict.caution:
        title = 'Unusual Pattern Detected';
        body = 'This transaction deviates from your typical spending behavior.';
        break;
      case RiskVerdict.block:
        title = 'High Risk Payment Blocked';
        body = 'We strongly advise against this transaction due to severe security flags.';
        break;
    }
    
    List<EvidenceItem> evidence = evidenceKeys.map((key) => _mapToEvidence(key)).toList();
    
    return RiskAssessment(
      transactionId: transactionId,
      verdict: verdict,
      confidenceScore: confidenceScore,
      evidence: evidence,
      explanationTitle: title,
      explanationBody: body,
    );
  }
  
  EvidenceItem _mapToEvidence(String key) {
    switch (key) {
      case 'known_merchant':
        return EvidenceItem(
          key: key,
          label: 'Known Merchant',
          detail: 'Matches past transactions',
          isPositive: true,
        );
      case 'typical_behaviour':
        return EvidenceItem(
          key: key,
          label: 'Typical Behaviour',
          detail: 'Matches your spending patterns',
          isPositive: true,
        );
      case 'known_scammer':
        return EvidenceItem(
          key: key,
          label: 'Known Scammer',
          detail: 'VPA is on global blocklist',
          isPositive: false,
        );
      case 'high_value':
        return EvidenceItem(
          key: key,
          label: 'Unusual Amount',
          detail: 'Significantly higher than average',
          isPositive: false,
        );
      case 'low_confidence_warning':
        return EvidenceItem(
          key: key,
          label: 'Low Model Confidence',
          detail: 'Insufficient history to guarantee safety.',
          isPositive: false,
        );
      case 'payee_details_visible':
        return EvidenceItem(
          key: key,
          label: 'Verify Payee',
          detail: 'Please confirm the merchant details carefully.',
          isPositive: true,
        );
      case 'user_blocked':
        return EvidenceItem(
          key: key,
          label: 'Blocked by You',
          detail: 'You have previously blocked this payee.',
          isPositive: false,
        );
      case 'trusted_by_user':
        return EvidenceItem(
          key: key,
          label: 'Trusted Payee',
          detail: 'You have marked this payee as trusted.',
          isPositive: true,
        );
      case 'trusted_but_anomalous':
        return EvidenceItem(
          key: key,
          label: 'Trusted, but Unusual',
          detail: 'This is a trusted payee, but the transaction amount or frequency is highly unusual.',
          isPositive: false,
        );
      case 'insufficient_history':
      default:
        return EvidenceItem(
          key: key,
          label: 'New Assessment',
          detail: 'Building your behaviour profile',
          isPositive: true,
        );
    }
  }
}
