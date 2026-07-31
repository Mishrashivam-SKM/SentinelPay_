import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelpay_ai/core/data/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('DatabaseHelper onCreate and onUpgrade work correctly', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: DatabaseHelper.onCreate,
        onUpgrade: DatabaseHelper.onUpgrade,
      ),
    );

    expect(db.isOpen, true);

    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    final tableNames = tables.map((t) => t['name'] as String).toList();

    expect(tableNames, contains('transactions'));
    expect(tableNames, contains('payees'));
    expect(tableNames, contains('behaviour_profile'));
    expect(tableNames, contains('sms_parse_log'));
    expect(tableNames, contains('settings'));
    expect(tableNames, contains('scam_messages'));
    expect(tableNames, contains('blocked_entities'));
    expect(tableNames, contains('trusted_entities'));

    await db.close();
  });

  test('DatabaseHelper onUpgrade triggers correctly', () async {
    // Open v1
    var db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // just minimal schema for v1
          await db.execute('''
            CREATE TABLE transactions (id TEXT PRIMARY KEY)
          ''');
        },
      ),
    );
    await db.close();
    
    // Now upgrade to v4
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 4,
        onUpgrade: DatabaseHelper.onUpgrade,
      ),
    );
    
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    final tableNames = tables.map((t) => t['name'] as String).toList();

    expect(tableNames, contains('scam_messages')); // added in v2
    expect(tableNames, contains('blocked_entities')); // added in v3
    expect(tableNames, contains('trusted_entities')); // added in v4

    await db.close();
  });
}
