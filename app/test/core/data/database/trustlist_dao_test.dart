import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sentinelpay_ai/core/data/database/trustlist_dao.dart';
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
    await db.delete('trusted_entities');
  });

  test('TrustlistDao trust and untrust', () async {
    final dao = TrustlistDao();
    final entity = BlockedEntity(
      id: '123',
      entityValue: 'goodguy@upi',
      entityType: EntityType.upi,
      timestamp: DateTime.now(),
    );

    await dao.trustEntity(entity);
    final isTrusted = await dao.isTrusted('goodguy@upi', EntityType.upi);
    expect(isTrusted, true);

    final isTrusted2 = await dao.isTrusted('badguy@upi', EntityType.upi);
    expect(isTrusted2, false);
    
    final all = await dao.getAllTrustedEntities();
    expect(all.length, 1);
    
    await dao.untrustEntity('goodguy@upi', EntityType.upi);
    final isTrusted3 = await dao.isTrusted('goodguy@upi', EntityType.upi);
    expect(isTrusted3, false);
  });
}
