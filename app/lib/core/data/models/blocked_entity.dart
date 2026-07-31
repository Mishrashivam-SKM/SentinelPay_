enum EntityType {
  upi,
  sms,
  phone,
  unknown
}

class BlockedEntity {
  final String id;
  final String entityValue; // e.g. upi id or phone number
  final EntityType entityType; // e.g. EntityType.sms or EntityType.upi
  final DateTime timestamp;

  BlockedEntity({
    required this.id,
    required this.entityValue,
    required this.entityType,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_value': entityValue,
      'entity_type': entityType.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory BlockedEntity.fromMap(Map<String, dynamic> map) {
    return BlockedEntity(
      id: map['id'],
      entityValue: map['entity_value'],
      entityType: EntityType.values.firstWhere((e) => e.name == map['entity_type'], orElse: () => EntityType.unknown),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
