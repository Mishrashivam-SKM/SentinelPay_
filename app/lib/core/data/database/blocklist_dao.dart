import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/blocked_entity.dart';
import 'database_helper.dart';

class BlocklistDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> blockEntity(BlockedEntity entity) async {
    final db = await _dbHelper.database;
    await db.insert(
      'blocked_entities',
      entity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> unblockEntity(String entityValue, EntityType entityType) async {
    final db = await _dbHelper.database;
    await db.delete(
      'blocked_entities',
      where: 'LOWER(entity_value) = LOWER(?) AND entity_type = ?',
      whereArgs: [entityValue, entityType.name],
    );
  }

  Future<bool> isBlocked(String entityValue, EntityType entityType) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blocked_entities',
      where: 'LOWER(entity_value) = LOWER(?) AND entity_type = ?',
      whereArgs: [entityValue, entityType.name],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<BlockedEntity>> getAllBlockedEntities() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'blocked_entities',
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) => BlockedEntity.fromMap(e)).toList();
  }
}
