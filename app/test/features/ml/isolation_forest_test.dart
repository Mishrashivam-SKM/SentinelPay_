import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/features/ml/isolation_forest.dart';

void main() {
  test('IsolationForest fit and anomalyScore', () {
    final forest = IsolationForest(numTrees: 10, subSampleSize: 2);
    final data = [
      [1.0, 2.0],
      [1.1, 2.1],
      [1.2, 2.2],
      [10.0, 20.0], // anomaly
    ];
    
    forest.fit(data);
    
    final normalScore = forest.anomalyScore([1.05, 2.05], data.length);
    final anomalyScore = forest.anomalyScore([15.0, 25.0], data.length);
    
    expect(normalScore >= 0.0 && normalScore <= 1.0, true);
    expect(anomalyScore >= 0.0 && anomalyScore <= 1.0, true);
  });

  test('IsolationForest incrementalFit', () {
    final forest = IsolationForest(numTrees: 10, subSampleSize: 2);
    final data = [
      [1.0, 2.0],
      [1.1, 2.1],
    ];
    forest.fit(data);
    
    final oldTrees = List.from(forest.trees);
    
    final newData = [
      [3.0, 4.0],
      [3.1, 4.1],
    ];
    forest.incrementalFit(newData, replacementRatio: 0.5); // replace 5 trees
    
    expect(forest.trees.length, 10);
    
    // Some trees should be different from oldTrees
    int matches = 0;
    for (int i = 0; i < 10; i++) {
      if (identical(forest.trees[i], oldTrees[i])) {
        matches++;
      }
    }
    expect(matches < 10, true);
  });

  test('IsolationForest toMap and fromMap', () {
    final forest = IsolationForest(numTrees: 5, subSampleSize: 2);
    final data = [
      [1.0],
      [2.0],
    ];
    forest.fit(data);
    
    final map = forest.toMap();
    final forest2 = IsolationForest.fromMap(map);
    
    expect(forest2.trees.length, 5);
    final score1 = forest.anomalyScore([1.5], data.length);
    final score2 = forest2.anomalyScore([1.5], data.length);
    expect(score1, score2);
  });
}
