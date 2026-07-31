import 'package:flutter/foundation.dart';
import 'dart:isolate';
import '../../core/data/database/transaction_dao.dart';
import 'behaviour_intelligence.dart';

class RetrainService {
  final TransactionDao _transactionDao = TransactionDao();
  final BehaviourIntelligence _behaviourIntelligence;
  
  int _newTransactionsSinceLastTrain = 0;
  DateTime _lastTrainTime = DateTime.now();

  RetrainService(this._behaviourIntelligence);

  Future<void> maybeRetrainModel() async {
    _newTransactionsSinceLastTrain++;
    final timeSinceLast = DateTime.now().difference(_lastTrainTime);
    
    // Retrain trigger: Every 10 new transactions OR every 24 hours
    if (_newTransactionsSinceLastTrain >= 10 || timeSinceLast.inHours >= 24) {
      if (_behaviourIntelligence.isTrained) {
        await incrementalRetrain();
      } else {
        await forceRetrain();
      }
    }
  }

  Future<void> forceRetrain() async {
    // Fetch rolling window (most recent 200)
    final history = await _transactionDao.getRecentTransactions(200);
    
    final serializedModel = await Isolate.run(() {
       final tempBI = BehaviourIntelligence();
       tempBI.train(history);
       return tempBI.toMap();
    });
    
    _behaviourIntelligence.loadFromMap(serializedModel);
    
    _newTransactionsSinceLastTrain = 0;
    _lastTrainTime = DateTime.now();
    debugPrint('Model retrained on ${history.length} samples.');
  }
  Future<void> incrementalRetrain() async {
    // Fetch recent new transactions to incrementally train
    final newTx = await _transactionDao.getRecentTransactions(_newTransactionsSinceLastTrain);
    final history = await _transactionDao.getRecentTransactions(200);
    
    final serializedModel = await Isolate.run(() {
      final tempBI = BehaviourIntelligence();
      // Load current state
      tempBI.loadFromMap(_behaviourIntelligence.toMap());
      tempBI.incrementalTrain(newTx, history);
      return tempBI.toMap();
    });
    
    _behaviourIntelligence.loadFromMap(serializedModel);
    
    _newTransactionsSinceLastTrain = 0;
    _lastTrainTime = DateTime.now();
  }
}
