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
      List<List<double>> XSub = [];
      List<int> indices = List.generate(n, (index) => index)..shuffle(random);
      
      for (int j = 0; j < sampleSize; j++) {
        XSub.add(X[indices[j]]);
      }

      IsolationTree tree = IsolationTree(currentDepth: 0, maxDepth: maxDepth);
      tree.build(XSub);
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
}
