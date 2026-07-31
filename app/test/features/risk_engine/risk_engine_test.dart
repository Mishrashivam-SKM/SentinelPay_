import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/core/data/models/risk_assessment.dart';
import 'package:sentinelpay_ai/features/risk_engine/deterministic_intelligence.dart';
import 'package:sentinelpay_ai/features/risk_engine/statistical_intelligence.dart';
import 'package:sentinelpay_ai/features/risk_engine/confidence_engine.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: DatabaseHelper.onCreate,
        onUpgrade: DatabaseHelper.onUpgrade,
      ),
    );
    DatabaseHelper.setDatabaseForTest(db);
  });

  group('Fraud Intelligence Engine Tests', () {

    group('Deterministic Intelligence', () {
      final engine = DeterministicIntelligence();

      test('Flags known scam patterns', () async {
        final tx = ParsedTransaction(
          amount: 5000,
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeIdentifier: 'scammer@ybl',
          timestamp: DateTime.now(),
          sourceBank: 'HDFC',
          source: 'live',
        );
        final score = await engine.scoreDeterministic(tx);
        expect(score, 1.0);
      });

      test('Passes normal transactions', () async {
        final tx = ParsedTransaction(
          amount: 450,
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeIdentifier: 'coffee@okicici',
          timestamp: DateTime.now(),
          sourceBank: 'HDFC',
          source: 'live',
        );
        final score = await engine.scoreDeterministic(tx);
        expect(score, 0.0);
      });
    });

    group('Statistical Intelligence', () {
      final engine = StatisticalIntelligence();

      test('Flags highly anomalous amounts', () {
        final current = ParsedTransaction(
          amount: 50000,
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          timestamp: DateTime.now(),
          sourceBank: 'HDFC',
          source: 'live',
        );
        final history = [
          ParsedTransaction(amount: 1000, direction: TransactionDirection.debit, method: PaymentMethod.upi, timestamp: DateTime.now(), sourceBank: 'HDFC', source: 'sms'),
          ParsedTransaction(amount: 2000, direction: TransactionDirection.debit, method: PaymentMethod.upi, timestamp: DateTime.now(), sourceBank: 'HDFC', source: 'sms'),
        ];
        
        final score = engine.scoreStatistical(current, history);
        expect(score > 0.5, isTrue);
      });
    });

    group('Confidence Engine', () {
      final engine = ConfidenceEngine();

      test('Calculates low confidence for new users', () {
        final confidence = engine.calculateConfidence(
          historySize: 2,
          verdict: RiskVerdict.caution,
          finalScore: 0.5,
          isModelTrained: false,
        );
        expect(confidence <= 0.5, isTrue); 
      });

      test('Calculates high confidence for established users with extreme scores', () {
        final confidence = engine.calculateConfidence(
          historySize: 150,
          verdict: RiskVerdict.safe,
          finalScore: 0.1,
          isModelTrained: true,
        );
        expect(confidence >= 0.8, isTrue); 
      });
    });
  });
}
