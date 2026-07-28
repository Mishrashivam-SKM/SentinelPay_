class TransactionFeatureVector {
  final double amountNormalized;
  final double amountZScore;
  final double hourOfDay; // 0.0 to 1.0 (24h)
  final double dayOfWeek; // 0.0 to 1.0 (7 days)
  final double payeeFrequency; // Normalized count
  final double daysSinceLastToPayee; // Normalized (max 30)
  final double isKnownPayee; // 1.0 or 0.0
  final double velocityLastHour; // Count normalized
  final double velocityLast24h; // Count normalized
  final double methodEncoded; // UPI=0.25, Card=0.5, etc.

  TransactionFeatureVector({
    required this.amountNormalized,
    required this.amountZScore,
    required this.hourOfDay,
    required this.dayOfWeek,
    required this.payeeFrequency,
    required this.daysSinceLastToPayee,
    required this.isKnownPayee,
    required this.velocityLastHour,
    required this.velocityLast24h,
    required this.methodEncoded,
  });

  List<double> toVector() {
    return [
      amountNormalized,
      amountZScore,
      hourOfDay,
      dayOfWeek,
      payeeFrequency,
      daysSinceLastToPayee,
      isKnownPayee,
      velocityLastHour,
      velocityLast24h,
      methodEncoded,
    ];
  }
}
