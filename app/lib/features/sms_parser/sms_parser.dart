import '../../../core/data/models/parsed_transaction.dart';
import 'template_registry.dart';
import 'sms_template.dart';

class SmsParser {
  ParsedTransaction? tryParseSms(String sender, String body, DateTime timestamp, {String source = 'sms_historical'}) {
    // 1. Skip non-transactional messages quickly (heuristics)
    final lowerBody = body.toLowerCase();
    if (!lowerBody.contains('rs') && 
        !lowerBody.contains('inr') && 
        !lowerBody.contains('debited') && 
        !lowerBody.contains('credited') &&
        !lowerBody.contains('sent') &&
        !lowerBody.contains('received')) {
      return null;
    }

    // 2. Try templates in registry
    for (SmsTemplate template in TemplateRegistry.templates) {
      if (template.matches(sender, body)) {
        try {
          return template.extractor(body, timestamp, source);
        } catch (e) {
          // Soft fail: log error internally, try next template
          print('Error extracting with template ${template.id}: $e');
        }
      }
    }

    return null; // No match found
  }
}
