import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/features/risk_engine/risk_fusion_engine.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/core/data/models/risk_assessment.dart';
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

  group('RiskFusionEngine Tests', () {
    late RiskFusionEngine engine;
    late BehaviourIntelligence behaviourIntelligence;

    setUp(() {
      behaviourIntelligence = BehaviourIntelligence();
      engine = RiskFusionEngine(behaviourIntelligence);
    });

    test('Should return Safe for normal low-amount transaction', () async {
      final history = <ParsedTransaction>[];
      final candidate = ParsedTransaction(
        amount: 200,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        payeeIdentifier: 'friend@okicici',
        timestamp: DateTime.now(),
        sourceBank: 'HDFC',
        source: 'live',
      );
      
      final assessment = await engine.assessTransaction(current: candidate, history: history);
      expect(assessment.verdict, RiskVerdict.safe);
    });

    test('Should return Block for known scam pattern', () async {
      final history = <ParsedTransaction>[];
      final assessment = await engine.assessLiveIntent(
        payeeVpa: "fraud@icici", 
        payeeName: "Fraudulent Account",
        amount: 50000.0,
        history: history,
      );

      expect(assessment.verdict, RiskVerdict.block);
    });
  });
}
