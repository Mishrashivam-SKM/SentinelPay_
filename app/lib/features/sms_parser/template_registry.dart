import '../../../core/data/models/parsed_transaction.dart';
import 'sms_template.dart';

double _parseAmount(String raw) {
  // Strip commas, currency symbols, stray whitespace
  final cleaned = raw.replaceAll(',', '').replaceAll(RegExp(r'[^\d.]'), '');
  return double.tryParse(cleaned) ?? 0.0;
}

class TemplateRegistry {
  static final List<SmsTemplate> templates = [
    // --- HDFC Bank — UPI debit ---
    SmsTemplate(
      id: 'hdfc_upi_debit_v1',
      bankName: 'HDFC',
      senderPattern: RegExp(r'^(HD|VM|VK|JD)-HDFCBK$|^HDFCBK$', caseSensitive: false),
      bodyPattern: RegExp(
        r'Rs\.?\s?([\d,]+\.?\d*)\s?(?:has been)?\s?debited from account\s?[\*Xx\d]+\s?(?:to|towards)\s?(?:VPA\s?)?([\w.\-@]+)?.*?on\s?([\d\-\/]+)',
        caseSensitive: false,
      ),
      extractor: (body, timestamp, source) {
        final match = RegExp(
          r'Rs\.?\s?([\d,]+\.?\d*)\s?(?:has been)?\s?debited from account\s?[\*Xx\d]+\s?(?:to|towards)\s?(?:VPA\s?)?([\w.\-@]+)?.*?on\s?([\d\-\/]+)',
          caseSensitive: false,
        ).firstMatch(body);
        if (match == null) return null;
        
        return ParsedTransaction(
          amount: _parseAmount(match.group(1)!),
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeName: match.group(2)?.trim(),
          timestamp: timestamp,
          sourceBank: 'HDFC',
          matchedTemplateId: 'hdfc_upi_debit_v1',
          source: source,
        );
      },
    ),

    // --- SBI — UPI debit ---
    SmsTemplate(
      id: 'sbi_upi_debit_v1',
      bankName: 'SBI',
      senderPattern: RegExp(r'^(SB|CP|VM|VK)-SBIUPI$|^SBIUPI$|^SBIINB$', caseSensitive: false),
      bodyPattern: RegExp(
        r'(?:Dear\s?(?:UPI\s?)?[Cc]ustomer,?\s?)?(?:Ac\s?[Xx\*\d]+\s?)?debited (?:by|for)?\s?(?:Rs\.?)?\s?([\d,]+\.?\d*)\s?.*?(?:trf to|to)\s?([\w.\-@ ]+?)(?:\s?on|\s?Ref)',
        caseSensitive: false,
      ),
      extractor: (body, timestamp, source) {
        final match = RegExp(
          r'(?:Dear\s?(?:UPI\s?)?[Cc]ustomer,?\s?)?(?:Ac\s?[Xx\*\d]+\s?)?debited (?:by|for)?\s?(?:Rs\.?)?\s?([\d,]+\.?\d*)\s?.*?(?:trf to|to)\s?([\w.\-@ ]+?)(?:\s?on|\s?Ref)',
          caseSensitive: false,
        ).firstMatch(body);
        if (match == null) return null;
        
        return ParsedTransaction(
          amount: _parseAmount(match.group(1)!),
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeName: match.group(2)?.trim(),
          timestamp: timestamp,
          sourceBank: 'SBI',
          matchedTemplateId: 'sbi_upi_debit_v1',
          source: source,
        );
      },
    ),

    // --- ICICI Bank — UPI debit ---
    SmsTemplate(
      id: 'icici_upi_debit_v1',
      bankName: 'ICICI',
      senderPattern: RegExp(r'^(IC|AD|VM|VK)-ICICIB$|^ICICIB$|^ICICIT$', caseSensitive: false),
      bodyPattern: RegExp(
        r'ICICI Bank Acct\s?[Xx\d]+\s?debited with\s?Rs\.?\s?([\d,]+\.?\d*)\s?on\s?[\d\-]+;\s?([\w.\-@ ]+?)\s?credited',
        caseSensitive: false,
      ),
      extractor: (body, timestamp, source) {
        final match = RegExp(
          r'ICICI Bank Acct\s?[Xx\d]+\s?debited with\s?Rs\.?\s?([\d,]+\.?\d*)\s?on\s?[\d\-]+;\s?([\w.\-@ ]+?)\s?credited',
          caseSensitive: false,
        ).firstMatch(body);
        if (match == null) return null;
        
        return ParsedTransaction(
          amount: _parseAmount(match.group(1)!),
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeName: match.group(2)?.trim(),
          timestamp: timestamp,
          sourceBank: 'ICICI',
          matchedTemplateId: 'icici_upi_debit_v1',
          source: source,
        );
      },
    ),

    // --- Axis Bank — UPI debit ---
    SmsTemplate(
      id: 'axis_upi_debit_v1',
      bankName: 'Axis',
      senderPattern: RegExp(r'^(AD|AX|VM|VK)-AXISBK$|^AXISBK$', caseSensitive: false),
      bodyPattern: RegExp(
        r'INR\s?([\d,]+\.?\d*)\s?debited.*?A/c no\.?\s?[Xx\d]+.*?(?:to|towards|UPI/)([\w.\-@ ]+?)(?:\s?on|\.)',
        caseSensitive: false,
      ),
      extractor: (body, timestamp, source) {
        final match = RegExp(
          r'INR\s?([\d,]+\.?\d*)\s?debited.*?A/c no\.?\s?[Xx\d]+.*?(?:to|towards|UPI/)([\w.\-@ ]+?)(?:\s?on|\.)',
          caseSensitive: false,
        ).firstMatch(body);
        if (match == null) return null;
        
        return ParsedTransaction(
          amount: _parseAmount(match.group(1)!),
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeName: match.group(2)?.trim(),
          timestamp: timestamp,
          sourceBank: 'Axis',
          matchedTemplateId: 'axis_upi_debit_v1',
          source: source,
        );
      },
    ),

    // --- Generic UPI credit (money received — any bank) ---
    SmsTemplate(
      id: 'generic_upi_credit_v1',
      bankName: 'Generic',
      senderPattern: RegExp(r'.*BK$|.*UPI$', caseSensitive: false), 
      bodyPattern: RegExp(
        r'(?:credited with|credited)\s?(?:Rs\.?|INR)\s?([\d,]+\.?\d*).*?(?:from|by)\s?([\w.\-@ ]+?)(?:\s?on|\.)',
        caseSensitive: false,
      ),
      extractor: (body, timestamp, source) {
        final match = RegExp(
          r'(?:credited with|credited)\s?(?:Rs\.?|INR)\s?([\d,]+\.?\d*).*?(?:from|by)\s?([\w.\-@ ]+?)(?:\s?on|\.)',
          caseSensitive: false,
        ).firstMatch(body);
        if (match == null) return null;
        
        return ParsedTransaction(
          amount: _parseAmount(match.group(1)!),
          direction: TransactionDirection.credit,
          method: PaymentMethod.upi,
          payeeName: match.group(2)?.trim(),
          timestamp: timestamp,
          sourceBank: 'Generic',
          matchedTemplateId: 'generic_upi_credit_v1',
          source: source,
        );
      },
    ),

    // --- Generic card transaction (debit/credit card spend) ---
    SmsTemplate(
      id: 'generic_card_debit_v1',
      bankName: 'Generic',
      senderPattern: RegExp(r'.*BK$|.*BNK$', caseSensitive: false),
      bodyPattern: RegExp(
        r'(?:card|Card)\s?(?:ending|no\.?)?\s?[Xx\d]+\s?.*?(?:used for|spent|debited)\s?(?:Rs\.?|INR)\s?([\d,]+\.?\d*)\s?at\s?([\w.\-@ ]+?)(?:\s?on|\.)',
        caseSensitive: false,
      ),
      extractor: (body, timestamp, source) {
        final match = RegExp(
          r'(?:card|Card)\s?(?:ending|no\.?)?\s?[Xx\d]+\s?.*?(?:used for|spent|debited)\s?(?:Rs\.?|INR)\s?([\d,]+\.?\d*)\s?at\s?([\w.\-@ ]+?)(?:\s?on|\.)',
          caseSensitive: false,
        ).firstMatch(body);
        if (match == null) return null;
        
        return ParsedTransaction(
          amount: _parseAmount(match.group(1)!),
          direction: TransactionDirection.debit,
          method: PaymentMethod.card,
          payeeName: match.group(2)?.trim(),
          timestamp: timestamp,
          sourceBank: 'Generic',
          matchedTemplateId: 'generic_card_debit_v1',
          source: source,
        );
      },
    ),
  ];
}
