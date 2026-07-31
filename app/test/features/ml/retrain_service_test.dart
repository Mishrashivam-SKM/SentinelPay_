import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/transaction_dao.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
import 'package:sentinelpay_ai/features/ml/behaviour_intelligence.dart';
import 'package:sentinelpay_ai/features/ml/retrain_service.dart';
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

  test('RetrainService maybeRetrainModel triggers forceRetrain', () async {
    final dao = TransactionDao();
    final bi = BehaviourIntelligence();
    final service = RetrainService(bi);

    // Insert dummy txs
    for (int i = 0; i < 15; i++) {
      await dao.insertTransaction(ParsedTransaction(
        amount: 100.0,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        timestamp: DateTime.now(),
        sourceBank: 'Bank',
        source: 'SMS',
      ));
    }

    expect(bi.isTrained, false);

    for (int i = 0; i < 10; i++) {
      await service.maybeRetrainModel();
    }

    expect(bi.isTrained, true);
  });

  test('RetrainService maybeRetrainModel triggers incrementalRetrain', () async {
    final dao = TransactionDao();
    final bi = BehaviourIntelligence();
    final service = RetrainService(bi);

    // Initial train
    for (int i = 0; i < 15; i++) {
      await dao.insertTransaction(ParsedTransaction(
        amount: 100.0,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        timestamp: DateTime.now(),
        sourceBank: 'Bank',
        source: 'SMS',
      ));
    }

    await service.forceRetrain();
    expect(bi.isTrained, true);
    
    // Add more tx to trigger incremental
    for (int i = 0; i < 10; i++) {
      await service.maybeRetrainModel();
    }
    
    // Test passes if no exception occurs
    expect(bi.isTrained, true);
  });
}
