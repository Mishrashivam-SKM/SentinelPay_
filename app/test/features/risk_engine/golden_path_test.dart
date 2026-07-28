import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/core/data/models/risk_assessment.dart';
import 'package:sentinelpay_ai/features/risk_engine/risk_fusion_engine.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';

void main() {
  group('Golden-Path Fraud Scenario Tests', () {
    late RiskFusionEngine fusionEngine;
    late BehaviourIntelligence behaviourIntelligence;

    setUp(() {
      behaviourIntelligence = BehaviourIntelligence();
      fusionEngine = RiskFusionEngine(behaviourIntelligence);
    });

    test('SCENARIO 1: The "Refund Support" Scam (High Risk)', () {
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

      final assessment = fusionEngine.assessTransaction(candidate, history);

      expect(assessment.verdict, RiskVerdict.block);
    });

    test('SCENARIO 2: Safe Coffee Shop (Low Risk)', () {
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

      final assessment = fusionEngine.assessTransaction(candidate, history);

      expect(assessment.verdict, RiskVerdict.safe);
    });
  });
}
