// coverage:ignore-file
import 'dart:math';
import '../../../core/data/models/parsed_transaction.dart';

class StatisticalIntelligence {
  double scoreStatistical(ParsedTransaction current, List<ParsedTransaction> history) {
    if (history.isEmpty) return 0.5; // neutral
    
    // Calculate mean and std dev
    double sum = 0;
    for (var t in history) {
      sum += t.amount;
    }
    double mean = sum / history.length;
    
    double varianceSum = 0;
    for (var t in history) {
      varianceSum += pow(t.amount - mean, 2);
    }
    double stdDev = history.length > 1 ? sqrt(varianceSum / (history.length - 1)) : 1.0;
    if (stdDev == 0) stdDev = 1.0;
    
    double zScore = (current.amount - mean) / stdDev;
    
    // Only flag high anomalous values if the transaction amount itself is non-trivial (e.g., > 10000)
    if (current.amount > 10000 && zScore > 3.0) {
      return min(0.85, 0.5 + (zScore * 0.1));
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
