import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/features/sms_parser/sms_parser.dart';

void main() {
  group('SmsParser Tests (Implementation Spec Templates)', () {
    final parser = SmsParser();

    test('Parses HDFC UPI debit correctly', () {
      const sender = 'JD-HDFCBK';
      const body = 'Rs.500.00 debited from account XX1234 to VPA merchant@okaxis on 12-06-26';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());

      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.direction, TransactionDirection.debit);
      expect(result.payeeName, 'merchant@okaxis');
      expect(result.method, PaymentMethod.upi);
      expect(result.sourceBank, 'HDFC');
    });

    test('Parses SBI UPI debit correctly', () {
      const sender = 'VM-SBIUPI';
      const body = 'Dear UPI customer, debited by Rs.1,200.50 trf to FreshMart on 12-06-26';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());

      expect(result, isNotNull);
      expect(result!.amount, 1200.50);
      expect(result.direction, TransactionDirection.debit);
      expect(result.payeeName, 'FreshMart');
      expect(result.sourceBank, 'SBI');
    });

    test('Parses ICICI UPI debit correctly', () {
      const sender = 'ICICIB';
      const body = 'ICICI Bank Acct XX123 debited with Rs. 2,000 on 12-06-26; CoffeeHouse credited';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());

      expect(result, isNotNull);
      expect(result!.amount, 2000.0);
      expect(result.direction, TransactionDirection.debit);
      expect(result.payeeName, 'CoffeeHouse');
      expect(result.sourceBank, 'ICICI');
    });

    test('Parses Axis UPI debit correctly', () {
      const sender = 'AXISBK';
      const body = 'INR 550.0 debited from A/c no X123 to UPI/Ramesh on 12-06-26';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());

      expect(result, isNotNull);
      expect(result!.amount, 550.0);
      expect(result.direction, TransactionDirection.debit);
      expect(result.payeeName, 'Ramesh');
      expect(result.sourceBank, 'Axis');
    });

    test('Parses generic UPI credit correctly', () {
      const sender = 'HDFCBK';
      const body = 'Account credited with Rs. 15,000 from EmployerCorp on 12-06-26';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());

      expect(result, isNotNull);
      expect(result!.amount, 15000.0);
      expect(result.direction, TransactionDirection.credit);
      expect(result.payeeName, 'EmployerCorp');
      expect(result.method, PaymentMethod.upi);
    });

    test('Parses generic card debit correctly', () {
      const sender = 'ANYBNK';
      const body = 'Card ending X123 used for Rs. 4,500.00 at Apple Store on 12-06-26';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());

      expect(result, isNotNull);
      expect(result!.amount, 4500.0);
      expect(result.direction, TransactionDirection.debit);
      expect(result.payeeName, 'Apple Store');
      expect(result.method, PaymentMethod.card);
    });

    test('Ignores non-transactional SMS', () {
      const sender = 'HDFCBK';
      const body = "Your OTP for login is 123456. Do not share this with anyone.";
      
      final result = parser.tryParseSms(sender, body, DateTime.now());
      expect(result, isNull);
    });

    test('Ignores promotional messages (ads)', () {
      const sender = 'AD-OFFER';
      const body = "Get 50% off on your next purchase at Coffee House! Use code SAVE50.";
      
      final result = parser.tryParseSms(sender, body, DateTime.now());
      expect(result, isNull);
    });
    
    test('Ignores spam claiming fake credits without real sender context', () {
      // Fake spam from random sender
      const sender = 'BW-SPAMMR';
      const body = 'Account credited with Rs. 50,000 from Lottery. Claim here.';
      
      final result = parser.tryParseSms(sender, body, DateTime.now());
      expect(result, isNull); // Fails because BW-SPAMMR doesn't match .*BK$ or .*UPI$
    });
  });
}
