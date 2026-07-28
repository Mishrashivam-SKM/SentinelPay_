import '../../../core/data/models/parsed_transaction.dart';

class StatisticalIntelligence {
  double scoreStatistical(ParsedTransaction current, List<ParsedTransaction> history) {
    if (history.isEmpty) return 0.5; // neutral
    
    // Very basic statistical checks
    double maxHistorical = 0;
    for (var t in history) {
      if (t.amount > maxHistorical) maxHistorical = t.amount;
    }
    
    // If amount is 5x the highest historical amount, highly anomalous
    if (maxHistorical > 0 && current.amount > (maxHistorical * 5)) {
      return 0.85;
    }
    
    // Late night velocity check (midnight to 5 AM)
    if (current.timestamp.hour >= 0 && current.timestamp.hour <= 5) {
      int lateNightTxns = 0;
      final oneHourAgo = current.timestamp.subtract(const Duration(hours: 1));
      
      for (var t in history) {
        if (t.timestamp.isAfter(oneHourAgo)) lateNightTxns++;
      }
      
      if (lateNightTxns >= 3) {
        return 0.8; // High risk for rapid late night transactions
      }
    }
    
    return 0.1; // Low statistical risk
  }
}
