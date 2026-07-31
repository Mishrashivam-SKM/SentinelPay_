import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/transaction_dao.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';
import 'package:sentinelpay_ai/features/ml/ml_pipeline_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  tearDown(() async {
    final db = await DatabaseHelper().database;
    await db.delete('transactions');
  });

  test('MlPipelineService retrainOnLatest', () async {
    final dao = TransactionDao();
    final bi = BehaviourIntelligence();
    final service = MlPipelineService(bi);

    // Insert dummy tx
    for (int i = 0; i < 5; i++) {
      await dao.insertTransaction(ParsedTransaction(
        amount: 100.0 * (i + 1),
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        timestamp: DateTime.now(),
        sourceBank: 'Bank',
        source: 'SMS',
      ));
    }

    // Retrain
    await service.retrainOnLatest();

    // Verify BI trained
    expect(bi.isTrained, true);
  });

  test('MlPipelineService retrainOnLatest handles empty db gracefully', () async {
    final bi = BehaviourIntelligence();
    final service = MlPipelineService(bi);

    await service.retrainOnLatest();

    // Should not be trained if empty DB
    expect(bi.isTrained, false);
  });
}
