import '../../../core/data/models/parsed_transaction.dart';

typedef TransactionExtractor = ParsedTransaction? Function(String body, DateTime timestamp, String source);

class SmsTemplate {
  final String id;
  final String bankName;
  final RegExp senderPattern;
  final RegExp bodyPattern;
  final TransactionExtractor extractor;

  SmsTemplate({
    required this.id,
    required this.bankName,
    required this.senderPattern,
    required this.bodyPattern,
    required this.extractor,
  });

  bool matches(String sender, String body) {
    return senderPattern.hasMatch(sender) && bodyPattern.hasMatch(body);
  }
}
