import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/blocklist_dao.dart';
import 'package:sentinelpay_ai/core/data/models/blocked_entity.dart';
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
    await db.delete('blocked_entities');
  });

  test('BlocklistDao block and unblock', () async {
    final dao = BlocklistDao();
    final entity = BlockedEntity(
      id: '123',
      entityValue: 'badguy@upi',
      entityType: EntityType.upi,
      timestamp: DateTime.now(),
    );

    await dao.blockEntity(entity);
    final isBlocked = await dao.isBlocked('badguy@upi', EntityType.upi);
    expect(isBlocked, true);

    final isBlocked2 = await dao.isBlocked('goodguy@upi', EntityType.upi);
    expect(isBlocked2, false);
    
    final all = await dao.getAllBlockedEntities();
    expect(all.length, 1);
    
    await dao.unblockEntity('badguy@upi', EntityType.upi);
    final isBlocked3 = await dao.isBlocked('badguy@upi', EntityType.upi);
    expect(isBlocked3, false);
  });
}
