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
      // history is sorted DESC (newest at index 0).
      // pastContext must only contain transactions strictly OLDER than history[i].
      List<ParsedTransaction> pastContext = (i + 1 < history.length) ? history.sublist(i + 1) : [];
      TransactionFeatureVector vec = FeatureComputation.computeFeatures(history[i], pastContext);
      trainingData.add(vec.toVector());
    }

    _forest.fit(trainingData);
    _isTrained = true;
    _trainingSampleCount = history.length;
  }

  void incrementalTrain(List<ParsedTransaction> newTransactions, List<ParsedTransaction> history) {
    if (newTransactions.isEmpty) return;
    
    List<List<double>> newTrainingData = [];
    for (int i = 0; i < newTransactions.length; i++) {
      // For each new transaction, its "pastContext" is the transactions older than it.
      // Since newTransactions is sorted DESC, the past context for newTransactions[i] is 
      // newTransactions.sublist(i + 1) + history
      List<ParsedTransaction> pastContext = [
        ...newTransactions.sublist(i + 1),
        ...history
      ];
      TransactionFeatureVector vec = FeatureComputation.computeFeatures(newTransactions[i], pastContext);
      newTrainingData.add(vec.toVector());
    }

    _forest.incrementalFit(newTrainingData);
    _trainingSampleCount += newTransactions.length;
    _isTrained = true;
  }

  double scoreBehaviour(ParsedTransaction current, List<ParsedTransaction> history) {
    if (!_isTrained) {
      // If we literally have 0 history to train the model, we can't trust the score.
      // But we CAN check if the payee exists in whatever limited history we have.
      bool payeeExists = history.any((tx) => tx.payeeIdentifier == current.payeeIdentifier);
      return payeeExists ? 0.3 : 0.7; // 0.7 = Warning zone for unknown payees
    }

    // Removed the strict Unknown Payee Penalty.
    // We let the ML model natively score it based on the extracted features.

    TransactionFeatureVector vec = FeatureComputation.computeFeatures(current, history);
    return _forest.anomalyScore(vec.toVector(), _trainingSampleCount);
  }
  
  bool get isTrained => _isTrained;

  Map<String, dynamic> toMap() {
    return {
      'forest': _forest.toMap(),
      'isTrained': _isTrained,
      'trainingSampleCount': _trainingSampleCount,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    if (map['isTrained'] == true) {
      final forestMap = map['forest'] as Map<String, dynamic>;
      final newForest = IsolationForest.fromMap(forestMap);
      _forest.trees = newForest.trees; // Copy the trees over
      _isTrained = true;
      _trainingSampleCount = map['trainingSampleCount'] as int;
    }
  }
}
