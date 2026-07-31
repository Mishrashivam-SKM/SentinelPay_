import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/core/data/models/blocked_entity.dart';
import 'package:sentinelpay_ai/core/data/models/risk_assessment.dart';

void main() {
  test('ParsedTransaction toMap and fromMap', () {
    final tx = ParsedTransaction(
      id: 'tx1',
      amount: 1500,
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: 'merchant@upi',
      payeeName: 'Merchant',
      timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
      sourceBank: 'HDFC',
      matchedTemplateId: 'tpl_1',
      source: 'SMS',
      verdict: 'HIGH_RISK',
    );

    final map = tx.toMap();
    expect(map['id'], 'tx1');
    expect(map['direction'], 'debit');
    expect(map['method'], 'upi');
    expect(map['verdict'], 'HIGH_RISK');

    final tx2 = ParsedTransaction.fromMap(map);
    expect(tx2.id, tx.id);
    expect(tx2.amount, tx.amount);
    expect(tx2.direction, tx.direction);
    expect(tx2.method, tx.method);
    expect(tx2.payeeIdentifier, tx.payeeIdentifier);
    expect(tx2.payeeName, tx.payeeName);
    expect(tx2.timestamp, tx.timestamp);
    expect(tx2.sourceBank, tx.sourceBank);
    expect(tx2.matchedTemplateId, tx.matchedTemplateId);
    expect(tx2.source, tx.source);
    expect(tx2.verdict, tx.verdict);
  });

  test('BlockedEntity toMap and fromMap', () {
    final entity = BlockedEntity(
      id: 'e1',
      entityValue: 'test@upi',
      entityType: EntityType.upi,
      timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
    );

    final map = entity.toMap();
    final e2 = BlockedEntity.fromMap(map);
    
    expect(e2.id, entity.id);
    expect(e2.entityValue, entity.entityValue);
    expect(e2.entityType, entity.entityType);
    expect(e2.timestamp, entity.timestamp);
  });

  test('RiskAssessment basic test', () {
    final assessment = RiskAssessment(
      transactionId: 'tx1',
      verdict: RiskVerdict.safe,
      confidenceScore: 0.8,
      evidence: [
        EvidenceItem(
          key: 'time',
          label: 'Time',
          detail: 'Normal',
          isPositive: true,
        )
      ],
      explanationTitle: 'Safe',
      explanationBody: 'Looks good',
    );
    expect(assessment.verdict, RiskVerdict.safe);
    expect(assessment.confidenceScore, 0.8);
    expect(assessment.evidence.first.label, 'Time');
    
    final map = assessment.evidence.first.toMap();
    expect(map['key'], 'time');
    
    final e2 = EvidenceItem.fromMap(map);
    expect(e2.key, 'time');
    expect(e2.isPositive, true);
  });
}
