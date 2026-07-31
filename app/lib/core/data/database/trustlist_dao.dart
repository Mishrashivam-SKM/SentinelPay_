import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/blocked_entity.dart'; // We can reuse this model as it has identical structure
import 'database_helper.dart';

class TrustlistDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> trustEntity(BlockedEntity entity) async {
    final db = await _dbHelper.database;
    await db.insert(
      'trusted_entities',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> untrustEntity(String entityValue, EntityType entityType) async {
    final db = await _dbHelper.database;
    await db.delete(
      'trusted_entities',
      where: 'LOWER(entity_value) = LOWER(?) AND entity_type = ?',
      whereArgs: [entityValue, entityType.name],
    );
  }

  Future<bool> isTrusted(String entityValue, EntityType entityType) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trusted_entities',
      where: 'LOWER(entity_value) = LOWER(?) AND entity_type = ?',
      whereArgs: [entityValue, entityType.name],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<BlockedEntity>> getAllTrustedEntities() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'trusted_entities',
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) => BlockedEntity.fromMap(e)).toList();
  }
}
