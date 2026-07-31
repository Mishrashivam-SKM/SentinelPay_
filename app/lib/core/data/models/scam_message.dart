class ScamMessage {
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final String scamType; // e.g., 'phishing', 'otp_trap'
  final double confidenceScore;
  final bool isSyncedToCommunity;

  ScamMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.scamType,
    required this.confidenceScore,
    this.isSyncedToCommunity = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'scamType': scamType,
      'confidenceScore': confidenceScore,
      'is_synced': isSyncedToCommunity ? 1 : 0,
    };
  }

  factory ScamMessage.fromMap(Map<String, dynamic> map) {
    return ScamMessage(
      id: map['id'],
      sender: map['sender'],
      body: map['body'],
      timestamp: DateTime.parse(map['timestamp']),
      scamType: map['scamType'],
      confidenceScore: map['confidenceScore'],
      isSyncedToCommunity: map['is_synced'] == 1,
    );
  }
}
