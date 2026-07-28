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
      await forceRetrain();
    }
  }

  Future<void> forceRetrain() async {
    // Fetch rolling window (most recent 200)
    final history = await _transactionDao.getRecentTransactions(200);
    _behaviourIntelligence.train(history);
    
    _newTransactionsSinceLastTrain = 0;
    _lastTrainTime = DateTime.now();
    print('Model retrained on ${history.length} samples.');
  }
}
