import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/core/data/models/risk_assessment.dart';
import 'package:sentinelpay_ai/features/risk_engine/risk_fusion_engine.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';
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

  group('Golden-Path Fraud Scenario Tests', () {
    late RiskFusionEngine fusionEngine;
    late BehaviourIntelligence behaviourIntelligence;

    setUp(() {
      behaviourIntelligence = BehaviourIntelligence();
      fusionEngine = RiskFusionEngine(behaviourIntelligence);
    });

    test('SCENARIO 1: The "Refund Support" Scam (High Risk)', () async {
      final candidate = ParsedTransaction(
        amount: 25000,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        payeeIdentifier: 'scammer@ybl', 
        payeeName: 'Customer Support',
        timestamp: DateTime.now(),
        sourceBank: 'HDFC',
        source: 'live',
      );

      final history = <ParsedTransaction>[
        ParsedTransaction(
          amount: 200,
          direction: TransactionDirection.debit,
          method: PaymentMethod.upi,
          payeeIdentifier: 'coffee@okicici',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          sourceBank: 'HDFC',
          source: 'historical',
        )
      ];

      final assessment = await fusionEngine.assessTransaction(current: candidate, history: history);

      expect(assessment.verdict, RiskVerdict.block);
    });

    test('SCENARIO 2: Safe Coffee Shop (Low Risk)', () async {
      final candidate = ParsedTransaction(
        amount: 350,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        payeeIdentifier: 'coffee@okicici',
        payeeName: 'Coffee Shop',
        timestamp: DateTime.now(),
        sourceBank: 'HDFC',
        source: 'live',
      );

      final history = List.generate(20, (index) => ParsedTransaction(
        amount: 300.0 + (index * 10),
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        payeeIdentifier: 'coffee@okicici',
        payeeName: 'Coffee Shop',
        timestamp: DateTime.now().subtract(Duration(days: index + 1)),
        sourceBank: 'HDFC',
        source: 'historical',
      ));
      
      behaviourIntelligence.train(history);

      final assessment = await fusionEngine.assessTransaction(current: candidate, history: history);

      expect(assessment.verdict, RiskVerdict.safe);
    });
  });
}
