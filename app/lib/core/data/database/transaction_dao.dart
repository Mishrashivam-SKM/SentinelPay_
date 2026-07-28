import 'package:sqflite/sqflite.dart';
import '../models/parsed_transaction.dart';
import 'database_helper.dart';
import 'package:uuid/uuid.dart';

class TransactionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<String> insertTransaction(ParsedTransaction transaction) async {
    final db = await _dbHelper.database;
    final map = transaction.toMap();
    if (map['id'] == null) {
      map['id'] = _uuid.v4();
    }
    
    await db.insert(
      'transactions',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return map['id'];
  }

  Future<List<ParsedTransaction>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) => ParsedTransaction.fromMap(e)).toList();
  }

  Future<List<ParsedTransaction>> getRecentTransactions(int limit) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((e) => ParsedTransaction.fromMap(e)).toList();
  }

  Future<int> getTransactionCount() async {
    final db = await _dbHelper.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM transactions')) ?? 0;
  }
}
