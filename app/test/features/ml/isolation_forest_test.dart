import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/features/ml/isolation_forest.dart';

void main() {
  group('Isolation Forest Tests', () {
    test('Identifies extreme outliers correctly', () {
      final forest = IsolationForest(numTrees: 50, subSampleSize: 20);

      // Create a dataset of "normal" transactions (amounts clustered around 200-500)
      final List<List<double>> trainingData = List.generate(100, (i) {
        return [
          200.0 + (i % 300), // amount
          (i % 24).toDouble(), // hour
          1.0, // velocity
        ];
      });

      forest.fit(trainingData);

      final normalVector = [350.0, 14.0, 1.0];
      final outlierVector = [50000.0, 3.0, 5.0]; // Huge amount, 3 AM, high velocity

      final normalScore = forest.anomalyScore(normalVector, trainingData.length);
      final outlierScore = forest.anomalyScore(outlierVector, trainingData.length);

      // The anomaly score for the outlier should be significantly higher
      expect(outlierScore > normalScore, isTrue);
      // Typically, IF scores > 0.5 indicate anomalies
      expect(outlierScore > 0.5, isTrue);
    });
    
    test('Handles cold start gracefully', () {
      final forest = IsolationForest(numTrees: 10, subSampleSize: 5);
      
      // Too few samples
      final List<List<double>> trainingData = [
        [100.0, 12.0, 1.0],
        [200.0, 14.0, 1.0],
      ];
      
      forest.fit(trainingData);
      
      final score = forest.anomalyScore([500.0, 10.0, 1.0], trainingData.length);
      
      // When data is insufficient, anomaly score should not confidently flag
      expect(score < 0.6, isTrue);
    });
  });
}
