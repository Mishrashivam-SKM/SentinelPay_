import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/features/analysis/analysis_screen.dart';
import 'package:sentinelpay_ai/core/data/models/risk_assessment.dart';
import 'package:sentinelpay_ai/core/widgets/evidence_card.dart';

void main() {
  group('AnalysisScreen Widget Tests', () {

    Widget createWidgetUnderTest(RiskAssessment assessment) {
      return MaterialApp(
        home: Scaffold(
          body: AnalysisScreen(
            mockAssessment: assessment,
            skipDelay: true,
          ),
        ),
      );
    }

    testWidgets('Displays Safe verdict correctly', (WidgetTester tester) async {
      final safeAssessment = RiskAssessment(
        transactionId: 'txn_123',
        verdict: RiskVerdict.safe,
        confidenceScore: 0.95,
        explanationTitle: 'Payment looks safe',
        explanationBody: 'No unusual patterns detected.',
        evidence: [
          EvidenceItem(key: 'known_payee', label: 'Known Payee', detail: 'You have paid them 5 times before.', isPositive: true),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(safeAssessment));
      await tester.pumpAndSettle();

      // Find text
      expect(find.text('Payment looks safe'), findsOneWidget);
      expect(find.text('No unusual patterns detected.'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      
      // Find evidence card
      expect(find.byType(EvidenceCard), findsOneWidget);
      expect(find.text('Known Payee'), findsOneWidget);
      
      // Find the 'Pay Securely' button
      expect(find.text('Pay Securely'), findsOneWidget);
    });

    testWidgets('Displays High Risk verdict correctly', (WidgetTester tester) async {
      final riskAssessment = RiskAssessment(
        transactionId: 'txn_999',
        verdict: RiskVerdict.block,
        confidenceScore: 0.88,
        explanationTitle: 'Scam Detected',
        explanationBody: 'This VPA is associated with known refund scams.',
        evidence: [
          EvidenceItem(key: 'deterministic_block', label: 'Known Scam', detail: 'This VPA is blocked.', isPositive: false),
          EvidenceItem(key: 'unusual_amount', label: 'Anomalous Amount', detail: 'This amount is 10x your average.', isPositive: false),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(riskAssessment));
      await tester.pumpAndSettle();

      expect(find.text('Scam Detected'), findsOneWidget);
      expect(find.text('This VPA is associated with known refund scams.'), findsOneWidget);
      
      // Should find 2 evidence cards
      expect(find.byType(EvidenceCard), findsNWidgets(2));
      expect(find.text('Known Scam'), findsOneWidget);
      expect(find.text('Anomalous Amount'), findsOneWidget);

      // Should have a Cancel button
      expect(find.text('Cancel Payment'), findsOneWidget);
    });
  });
}
