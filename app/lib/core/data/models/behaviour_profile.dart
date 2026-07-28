class BehaviourProfile {
  final int id;
  final int rollingWindowSize;
  final String modelVersion;
  final DateTime lastTrainedAt;
  final int trainingSampleCount;

  BehaviourProfile({
    this.id = 1,
    required this.rollingWindowSize,
    required this.modelVersion,
    required this.lastTrainedAt,
    required this.trainingSampleCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rolling_window_size': rollingWindowSize,
      'model_version': modelVersion,
      'last_trained_at': lastTrainedAt.toIso8601String(),
      'training_sample_count': trainingSampleCount,
    };
  }

  factory BehaviourProfile.fromMap(Map<String, dynamic> map) {
    return BehaviourProfile(
      id: map['id'] ?? 1,
      rollingWindowSize: map['rolling_window_size'] ?? 200,
      modelVersion: map['model_version'] ?? '1.0',
      lastTrainedAt: DateTime.parse(map['last_trained_at']),
      trainingSampleCount: map['training_sample_count'] ?? 0,
    );
  }
}
