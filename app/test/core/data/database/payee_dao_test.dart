import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/payee_dao.dart';

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
    await db.delete('payees');
  });

  test('PayeeDao incrementPayeeFrequency new and existing', () async {
    final dao = PayeeDao();
    final now = DateTime.now();
    
    // Increment new payee
    await dao.incrementPayeeFrequency('test@upi', 'Test User', now);
    
    final payee1 = await dao.getPayeeByVpa('test@upi');
    expect(payee1, isNotNull);
    expect(payee1!.frequencyCount, 1);
    expect(payee1.displayName, 'Test User');
    expect(payee1.firstSeen, now);

    // Increment existing payee
    final later = now.add(const Duration(days: 1));
    await dao.incrementPayeeFrequency('test@upi', 'Test User Updated', later);
    
    final payee2 = await dao.getPayeeByVpa('test@upi');
    expect(payee2, isNotNull);
    expect(payee2!.frequencyCount, 2);
    expect(payee2.lastSeen, later);
    expect(payee2.firstSeen, now);
    expect(payee2.displayName, 'Test User Updated');
  });

  test('PayeeDao getPayeeByVpa returns null if not found', () async {
    final dao = PayeeDao();
    final payee = await dao.getPayeeByVpa('nonexistent@upi');
    expect(payee, isNull);
  });
}
