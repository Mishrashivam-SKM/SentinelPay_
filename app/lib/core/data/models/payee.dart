class Payee {
  final String vpa;
  final String? displayName;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final int frequencyCount;
  final bool isKnown;

  Payee({
    required this.vpa,
    this.displayName,
    required this.firstSeen,
    required this.lastSeen,
    required this.frequencyCount,
    required this.isKnown,
  });

  Map<String, dynamic> toMap() {
    return {
      'vpa': vpa,
      'display_name': displayName,
      'first_seen': firstSeen.toIso8601String(),
      'last_seen': lastSeen.toIso8601String(),
      'frequency_count': frequencyCount,
      'is_known': isKnown ? 1 : 0,
    };
  }

  factory Payee.fromMap(Map<String, dynamic> map) {
    return Payee(
      vpa: map['vpa'],
      displayName: map['display_name'],
      firstSeen: DateTime.parse(map['first_seen']),
      lastSeen: DateTime.parse(map['last_seen']),
      frequencyCount: map['frequency_count'] ?? 0,
      isKnown: (map['is_known'] ?? 0) == 1,
    );
  }
}
