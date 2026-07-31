import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentinelpay_ai/core/providers/risk_provider.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';
import 'package:sentinelpay_ai/features/ml/isolation_forest.dart';
import 'package:sentinelpay_ai/features/risk_engine/risk_fusion_engine.dart';

void main() {
  test('Providers supply correct instances', () {
    final container = ProviderContainer();

    final isolationForest = container.read(isolationForestProvider);
    expect(isolationForest, isA<IsolationForest>());

    final behaviourIntelligence = container.read(behaviourIntelligenceProvider);
    expect(behaviourIntelligence, isA<BehaviourIntelligence>());

    final riskFusionEngine = container.read(riskFusionEngineProvider);
    expect(riskFusionEngine, isA<RiskFusionEngine>());
  });
}
