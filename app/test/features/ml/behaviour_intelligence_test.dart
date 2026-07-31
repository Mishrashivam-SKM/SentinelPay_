import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';

void main() {
  test('BehaviourIntelligence incrementalTrain when not trained falls back to train', () {
    final bi = BehaviourIntelligence();
    
    final txs = [
      ParsedTransaction(
        amount: 100,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        timestamp: DateTime.now(),
        sourceBank: 'Bank',
        source: 'SMS',
      )
    ];

    bi.incrementalTrain(txs, txs);
    expect(bi.isTrained, true);
  });

  test('BehaviourIntelligence scoreBehaviour when not trained', () {
    final bi = BehaviourIntelligence();
    
    final current = ParsedTransaction(
      amount: 100,
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: 'known@upi',
      timestamp: DateTime.now(),
      sourceBank: 'Bank',
      source: 'SMS',
    );

    final historyKnown = [current];
    expect(bi.scoreBehaviour(current, historyKnown), 0.3);

    final historyUnknown = <ParsedTransaction>[];
    expect(bi.scoreBehaviour(current, historyUnknown), 0.7);
  });

  test('BehaviourIntelligence scoreBehaviour when trained', () {
    final bi = BehaviourIntelligence();
    
    final current = ParsedTransaction(
      amount: 100,
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: 'known@upi',
      timestamp: DateTime.now(),
      sourceBank: 'Bank',
      source: 'SMS',
    );

    bi.train([current, current, current]);
    final score = bi.scoreBehaviour(current, [current]);
    
    // Anomaly score should be calculated successfully
    expect(score, isNotNull);
    expect(score >= 0.0 && score <= 1.0, true);
  });
  
  test('BehaviourIntelligence toMap and loadFromMap', () {
    final bi = BehaviourIntelligence();
    
    final current = ParsedTransaction(
      amount: 100,
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: 'known@upi',
      timestamp: DateTime.now(),
      sourceBank: 'Bank',
      source: 'SMS',
    );
    
    bi.train([current]);
    
    final map = bi.toMap();
    final bi2 = BehaviourIntelligence();
    bi2.loadFromMap(map);
    
    expect(bi2.isTrained, true);
    final score1 = bi.scoreBehaviour(current, [current]);
    final score2 = bi2.scoreBehaviour(current, [current]);
    expect(score1, score2); // The loaded model should yield identical scores
  });
}
