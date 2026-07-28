import 'dart:math';
import '../../../core/data/models/parsed_transaction.dart';
import 'feature_vector.dart';

class FeatureComputation {
  static TransactionFeatureVector computeFeatures(
      ParsedTransaction current, List<ParsedTransaction> history) {
    
    // Calculate global stats for this user
    double sumAmount = 0;
    for (var t in history) {
      sumAmount += t.amount;
    }
    double meanAmount = history.isEmpty ? current.amount : sumAmount / history.length;
    
    double varianceAmount = 0;
    for (var t in history) {
      varianceAmount += pow(t.amount - meanAmount, 2);
    }
    double stdDevAmount = history.length > 1 ? sqrt(varianceAmount / (history.length - 1)) : 1.0;
    if (stdDevAmount == 0) stdDevAmount = 1.0; // avoid div by zero

    double maxAmount = history.fold<double>(current.amount, (max, t) => t.amount > max ? t.amount : max);
    if (maxAmount == 0) maxAmount = 1.0;

    // Time-based features
    double hourOfDay = current.timestamp.hour / 24.0;
    double dayOfWeek = current.timestamp.weekday / 7.0;

    // Payee features
    int payeeFreq = 0;
    DateTime? lastToPayee;
    int vel1h = 0;
    int vel24h = 0;

    final oneHourAgo = current.timestamp.subtract(const Duration(hours: 1));
    final twentyFourHoursAgo = current.timestamp.subtract(const Duration(hours: 24));

    for (var t in history) {
      if (t.timestamp.isAfter(oneHourAgo)) vel1h++;
      if (t.timestamp.isAfter(twentyFourHoursAgo)) vel24h++;
      
      if (t.payeeName == current.payeeName) {
        payeeFreq++;
        if (lastToPayee == null || t.timestamp.isAfter(lastToPayee)) {
          lastToPayee = t.timestamp;
        }
      }
    }

    double daysSinceLastToPayee = 30.0; // Default max
    if (lastToPayee != null) {
      daysSinceLastToPayee = current.timestamp.difference(lastToPayee).inDays.toDouble();
      if (daysSinceLastToPayee > 30) daysSinceLastToPayee = 30;
    }
    daysSinceLastToPayee /= 30.0; // normalize

    double methodEncoded = 0.0;
    switch (current.method) {
      case PaymentMethod.upi: methodEncoded = 0.25; break;
      case PaymentMethod.card: methodEncoded = 0.50; break;
      case PaymentMethod.netbanking: methodEncoded = 0.75; break;
      default: methodEncoded = 1.0;
    }

    return TransactionFeatureVector(
      amountNormalized: current.amount / maxAmount,
      amountZScore: (current.amount - meanAmount) / stdDevAmount,
      hourOfDay: hourOfDay,
      dayOfWeek: dayOfWeek,
      payeeFrequency: payeeFreq / 100.0, // Arbitrary normalization factor
      daysSinceLastToPayee: daysSinceLastToPayee,
      isKnownPayee: payeeFreq > 0 ? 1.0 : 0.0,
      velocityLastHour: vel1h / 10.0,
      velocityLast24h: vel24h / 50.0,
      methodEncoded: methodEncoded,
    );
  }
}
