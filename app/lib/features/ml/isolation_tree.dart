import 'dart:math';

class IsolationTree {
  final int currentDepth;
  final int maxDepth;
  
  IsolationTree? left;
  IsolationTree? right;
  
  int splitAttribute = -1;
  double splitValue = 0.0;
  int size = 0; // Data points in this node

  IsolationTree({required this.currentDepth, required this.maxDepth});

  void build(List<List<double>> data) {
    size = data.length;
    
    if (currentDepth >= maxDepth || data.length <= 1) {
      return;
    }

    final random = Random();
    int dimensions = data[0].length;
    splitAttribute = random.nextInt(dimensions);

    // Find min and max for the chosen attribute
    double minVal = data[0][splitAttribute];
    double maxVal = minVal;
    
    for (var point in data) {
      if (point[splitAttribute] < minVal) minVal = point[splitAttribute];
      if (point[splitAttribute] > maxVal) maxVal = point[splitAttribute];
    }

    if (minVal == maxVal) {
      return; // Can't split if all values are the same
    }

    splitValue = minVal + random.nextDouble() * (maxVal - minVal);

    List<List<double>> leftData = [];
    List<List<double>> rightData = [];

    for (var point in data) {
      if (point[splitAttribute] < splitValue) {
        leftData.add(point);
      } else {
        rightData.add(point);
      }
    }

    if (leftData.isNotEmpty && rightData.isNotEmpty) {
      left = IsolationTree(currentDepth: currentDepth + 1, maxDepth: maxDepth)..build(leftData);
      right = IsolationTree(currentDepth: currentDepth + 1, maxDepth: maxDepth)..build(rightData);
    }
  }

  double pathLength(List<double> point) {
    if (left == null && right == null) {
      return currentDepth + c(size);
    }

    if (point[splitAttribute] < splitValue) {
      return left?.pathLength(point) ?? (currentDepth + c(size));
    } else {
      return right?.pathLength(point) ?? (currentDepth + c(size));
    }
  }

  // Cost function for unbuilt parts of the tree
  static double c(int n) {
    if (n <= 1) return 0;
    // Using Euler's constant ~0.5772156649
    return 2.0 * (log(n - 1.0) + 0.5772156649) - (2.0 * (n - 1.0) / n);
  }

  Map<String, dynamic> toMap() {
    return {
      'currentDepth': currentDepth,
      'maxDepth': maxDepth,
      'splitAttribute': splitAttribute,
      'splitValue': splitValue,
      'size': size,
      'left': left?.toMap(),
      'right': right?.toMap(),
    };
  }

  factory IsolationTree.fromMap(Map<String, dynamic> map) {
    final tree = IsolationTree(
      currentDepth: map['currentDepth'] as int,
      maxDepth: map['maxDepth'] as int,
    );
    tree.splitAttribute = map['splitAttribute'] as int;
    tree.splitValue = map['splitValue'] as double;
    tree.size = map['size'] as int;
    if (map['left'] != null) {
      tree.left = IsolationTree.fromMap(map['left'] as Map<String, dynamic>);
    }
    if (map['right'] != null) {
      tree.right = IsolationTree.fromMap(map['right'] as Map<String, dynamic>);
    }
    return tree;
  }
}
