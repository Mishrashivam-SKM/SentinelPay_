import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/scam_dao.dart';
import 'package:sentinelpay_ai/core/data/models/scam_message.dart';
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
    await db.delete('scam_messages');
  });

  test('ScamDao insert, getAll, and markAsSynced', () async {
    final dao = ScamDao();
    final msg = ScamMessage(
      id: 'scam1',
      sender: 'V-BANK',
      body: 'Your account is blocked. Click here: bit.ly/123',
      timestamp: DateTime.now(),
      scamType: 'Phishing',
      confidenceScore: 0.95,
      isSyncedToCommunity: false,
    );

    await dao.insertScamMessage(msg);
    final all = await dao.getAllScamMessages();
    
    expect(all.length, 1);
    expect(all.first.id, 'scam1');
    expect(all.first.isSyncedToCommunity, false);

    await dao.markAsSynced('scam1');
    final allAfter = await dao.getAllScamMessages();
    expect(allAfter.first.isSyncedToCommunity, true);
  });
}
