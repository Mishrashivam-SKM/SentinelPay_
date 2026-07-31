// coverage:ignore-file
import '../../core/data/database/transaction_dao.dart';
import 'behaviour_intelligence.dart';
import 'package:flutter/foundation.dart';
import 'dart:isolate';

class MlPipelineService {
  final BehaviourIntelligence _behaviourIntelligence;
  final TransactionDao _transactionDao = TransactionDao();

  MlPipelineService(this._behaviourIntelligence);

  /// Retrains the Isolation Forest model using a rolling window of 
  /// the most recent 200 transactions.
  Future<void> retrainOnLatest() async {
    try {
      final allTransactions = await _transactionDao.getRecentTransactions(200); // Optimization: Use DB limit instead of Dart take()
      
      // Pass the heavy lifting to a background isolate to prevent UI frame drops
      final serializedModel = await Isolate.run(() {
         final tempBI = BehaviourIntelligence();
         tempBI.train(allTransactions);
         return tempBI.toMap();
      });
      
      _behaviourIntelligence.loadFromMap(serializedModel);
      
      debugPrint('ML Pipeline: Retrained model on \${allTransactions.length} recent transactions.');
    } catch (e) {
      debugPrint('ML Pipeline: Failed to retrain model - \$e');
    }
  }
}
