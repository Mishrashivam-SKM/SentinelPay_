import '../../../core/data/models/parsed_transaction.dart';
import 'feature_vector.dart';
import 'feature_computation.dart';
import 'isolation_forest.dart';

class BehaviourIntelligence {
  final IsolationForest _forest = IsolationForest(numTrees: 100, subSampleSize: 256);
  bool _isTrained = false;
  int _trainingSampleCount = 0;

  void train(List<ParsedTransaction> history) {
    if (history.isEmpty) return;

    List<List<double>> trainingData = [];
    for (int i = 0; i < history.length; i++) {
      // Compute features for history[i] using the context of history up to that point
      // For simplicity in this implementation, we compute relative to the whole window
      // A more strictly correct way is to only use past data.
      List<ParsedTransaction> pastContext = history.sublist(i); // Assuming sorted DESC
      TransactionFeatureVector vec = FeatureComputation.computeFeatures(history[i], pastContext);
      trainingData.add(vec.toVector());
    }

    _forest.fit(trainingData);
    _isTrained = true;
    _trainingSampleCount = history.length;
  }

  double scoreBehaviour(ParsedTransaction current, List<ParsedTransaction> history) {
    if (!_isTrained || _trainingSampleCount < 15) {
      return 0.5; // Cold start fallback
    }

    TransactionFeatureVector vec = FeatureComputation.computeFeatures(current, history);
    return _forest.anomalyScore(vec.toVector(), _trainingSampleCount);
  }
  
  bool get isTrained => _isTrained;
}
