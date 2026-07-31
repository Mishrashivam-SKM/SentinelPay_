import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/transaction_dao.dart';
import 'package:sentinelpay_ai/core/data/models/parsed_transaction.dart';
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

  test('TransactionDao insert and getAll', () async {
    final dao = TransactionDao();
    final tx = ParsedTransaction(
      amount: 100,
      direction: TransactionDirection.debit,
      method: PaymentMethod.upi,
      payeeIdentifier: 'test@upi',
      timestamp: DateTime.now(),
      sourceBank: 'Bank',
      matchedTemplateId: '1',
      source: 'SMS',
    );

    final id = await dao.insertTransaction(tx);
    expect(id, isNotEmpty);

    final all = await dao.getAllTransactions();
    expect(all.length, 1);
    expect(all.first.amount, 100);
  });

  test('TransactionDao getRecentTransactions with limit and offset', () async {
    final dao = TransactionDao();
    for (int i = 0; i < 5; i++) {
      await dao.insertTransaction(ParsedTransaction(
        amount: (i + 1) * 100,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        payeeIdentifier: 'test$i@upi',
        timestamp: DateTime.now().subtract(Duration(days: 5 - i)),
        sourceBank: 'Bank',
        matchedTemplateId: '1',
        source: 'SMS',
      ));
    }

    final count = await dao.getTransactionCount();
    expect(count, 5);

    // Recent should get the newest ones first (highest timestamp)
    final recent = await dao.getRecentTransactions(2, offset: 1);
    expect(recent.length, 2);
    // Newest is index 4, next is 3, offset 1 means we start at 3.
    expect(recent[0].amount, 400.0);
    expect(recent[1].amount, 300.0);
  });

  test('TransactionDao getTransactionsCursor', () async {
    final dao = TransactionDao();
    for (int i = 0; i < 3; i++) {
      await dao.insertTransaction(ParsedTransaction(
        id: 'id_$i',
        amount: (i + 1) * 100,
        direction: TransactionDirection.debit,
        method: PaymentMethod.upi,
        payeeIdentifier: 'test$i@upi',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1000 + i * 1000), // 1000, 2000, 3000
        sourceBank: 'Bank',
        matchedTemplateId: '1',
        source: 'SMS',
      ));
    }

    // First page, 2 items
    final page1 = await dao.getTransactionsCursor(null, null, 2);
    expect(page1.length, 2);
    expect(page1[0].id, 'id_2');
    expect(page1[1].id, 'id_1');

    // Next page
    final page2 = await dao.getTransactionsCursor(page1[1].timestamp, page1[1].id, 2);
    expect(page2.length, 1);
    expect(page2[0].id, 'id_0');
  });
}
