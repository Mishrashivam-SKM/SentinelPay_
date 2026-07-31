import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/scam_message.dart';
import 'database_helper.dart';

class ScamDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertScamMessage(ScamMessage message) async {
    final db = await _dbHelper.database;
    await db.insert(
      'scam_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScamMessage>> getAllScamMessages() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scam_messages',
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) => ScamMessage.fromMap(e)).toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'scam_messages',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
