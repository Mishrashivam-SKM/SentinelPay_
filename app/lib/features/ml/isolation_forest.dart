// coverage:ignore-file
import 'dart:math';
import 'isolation_tree.dart';

class IsolationForest {
  final int numTrees;
  final int subSampleSize;
  List<IsolationTree> trees = [];

  IsolationForest({this.numTrees = 100, this.subSampleSize = 256});

  void fit(List<List<double>> X) {
    trees.clear();
    int n = X.length;
    int maxDepth = (log(subSampleSize) / log(2)).ceil();
    final random = Random();

    for (int i = 0; i < numTrees; i++) {
      // Subsampling
      int sampleSize = n < subSampleSize ? n : subSampleSize;
      List<List<double>> xSub = [];
      List<int> indices = List.generate(n, (index) => index)..shuffle(random);
      
      for (int j = 0; j < sampleSize; j++) {
        xSub.add(X[indices[j]]);
      }

      IsolationTree tree = IsolationTree(currentDepth: 0, maxDepth: maxDepth);
      tree.build(xSub);
      trees.add(tree);
    }
  }

  void incrementalFit(List<List<double>> newSamples, {double replacementRatio = 0.1}) {
    if (trees.isEmpty) {
      fit(newSamples);
      return;
    }

    int n = newSamples.length;
    int maxDepth = (log(subSampleSize) / log(2)).ceil();
    final random = Random();

    int numTreesToReplace = (numTrees * replacementRatio).ceil();
    
    for (int i = 0; i < numTreesToReplace; i++) {
      if (trees.isNotEmpty) {
         trees.removeAt(random.nextInt(trees.length)); // Replace random existing trees
      }
    }

    for (int i = 0; i < numTreesToReplace; i++) {
      int sampleSize = n < subSampleSize ? n : subSampleSize;
      List<List<double>> xSub = [];
      List<int> indices = List.generate(n, (index) => index)..shuffle(random);
      
      for (int j = 0; j < sampleSize; j++) {
        xSub.add(newSamples[indices[j]]);
      }

      IsolationTree tree = IsolationTree(currentDepth: 0, maxDepth: maxDepth);
      tree.build(xSub);
      trees.add(tree);
    }
  }

  double anomalyScore(List<double> x, int totalSamples) {
    if (trees.isEmpty) return 0.5; // Neutral score if not trained
    
    double pathSum = 0;
    for (var tree in trees) {
      pathSum += tree.pathLength(x);
    }
    
    double expectedPath = pathSum / numTrees;
    int n = totalSamples < subSampleSize ? totalSamples : subSampleSize;
    double c = IsolationTree.c(n);

    // If c is 0 (n=1), we can't really compute a score
    if (c == 0) return 0.5;

    // Score is between 0 and 1. Values closer to 1 are more anomalous.
    return pow(2, -expectedPath / c).toDouble();
  }

  Map<String, dynamic> toMap() {
    return {
      'numTrees': numTrees,
      'subSampleSize': subSampleSize,
      'trees': trees.map((t) => t.toMap()).toList(),
    };
  }

  factory IsolationForest.fromMap(Map<String, dynamic> map) {
    final forest = IsolationForest(
      numTrees: map['numTrees'] as int,
      subSampleSize: map['subSampleSize'] as int,
    );
    final treeMaps = map['trees'] as List<dynamic>;
    forest.trees = treeMaps.map((t) => IsolationTree.fromMap(t as Map<String, dynamic>)).toList();
    return forest;
  }
}
