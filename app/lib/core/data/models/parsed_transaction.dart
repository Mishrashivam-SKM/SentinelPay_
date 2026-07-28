enum TransactionDirection { debit, credit }
enum PaymentMethod { upi, card, netbanking, unknown }

class ParsedTransaction {
  final String? id;
  final double amount;
  final TransactionDirection direction;
  final PaymentMethod method;
  final String? payeeIdentifier;
  final String? payeeName;
  final DateTime timestamp;
  final String sourceBank;
  final String? matchedTemplateId;
  final String source; // 'sms_historical' or 'live'

  ParsedTransaction({
    this.id,
    required this.amount,
    required this.direction,
    required this.method,
    this.payeeIdentifier,
    this.payeeName,
    required this.timestamp,
    required this.sourceBank,
    this.matchedTemplateId,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'direction': direction.name,
      'method': method.name,
      'payee_identifier': payeeIdentifier,
      'payee_name': payeeName,
      'timestamp': timestamp.toIso8601String(),
      'source_bank': sourceBank,
      'matched_template_id': matchedTemplateId,
      'source': source,
    };
  }

  factory ParsedTransaction.fromMap(Map<String, dynamic> map) {
    return ParsedTransaction(
      id: map['id']?.toString(),
      amount: map['amount']?.toDouble() ?? 0.0,
      direction: TransactionDirection.values.byName(map['direction']),
      method: PaymentMethod.values.byName(map['method']),
      payeeIdentifier: map['payee_identifier'],
      payeeName: map['payee_name'],
      timestamp: DateTime.parse(map['timestamp']),
      sourceBank: map['source_bank'] ?? 'Unknown',
      matchedTemplateId: map['matched_template_id'],
      source: map['source'] ?? 'sms_historical',
    );
  }
}
