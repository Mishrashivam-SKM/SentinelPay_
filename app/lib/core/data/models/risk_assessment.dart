enum RiskVerdict { safe, caution, block }

class EvidenceItem {
  final String key;
  final String label;
  final String detail;
  final bool isPositive;

  EvidenceItem({
    required this.key,
    required this.label,
    required this.detail,
    required this.isPositive,
  });
  
  Map<String, dynamic> toMap() => {
    'key': key,
    'label': label,
    'detail': detail,
    'isPositive': isPositive,
  };
  
  factory EvidenceItem.fromMap(Map<String, dynamic> map) => EvidenceItem(
    key: map['key'],
    label: map['label'],
    detail: map['detail'],
    isPositive: map['isPositive'] ?? false,
  );
}

class RiskAssessment {
  final String transactionId;
  final RiskVerdict verdict;
  final double confidenceScore; // 0.0 to 1.0
  final List<EvidenceItem> evidence;
  final String explanationTitle;
  final String explanationBody;
  
  RiskAssessment({
    required this.transactionId,
    required this.verdict,
    required this.confidenceScore,
    required this.evidence,
    required this.explanationTitle,
    required this.explanationBody,
  });
}
