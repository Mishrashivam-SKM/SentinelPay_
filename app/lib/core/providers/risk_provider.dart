import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/risk_engine/risk_fusion_engine.dart';
import '../../features/ml/behaviour_intelligence.dart';
import '../../features/ml/isolation_forest.dart';

final isolationForestProvider = Provider<IsolationForest>((ref) {
  return IsolationForest();
});

final behaviourIntelligenceProvider = Provider<BehaviourIntelligence>((ref) {
  return BehaviourIntelligence();
});

final riskFusionEngineProvider = Provider<RiskFusionEngine>((ref) {
  final bi = ref.watch(behaviourIntelligenceProvider);
  return RiskFusionEngine(bi);
});
