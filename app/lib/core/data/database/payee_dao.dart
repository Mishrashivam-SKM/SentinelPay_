import 'package:sqflite/sqflite.dart';
import '../models/payee.dart';
import 'database_helper.dart';

class PayeeDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertOrUpdatePayee(Payee payee) async {
    final db = await _dbHelper.database;
    await db.insert(
      'payees',
      payee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Payee?> getPayeeByVpa(String vpa) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payees',
      where: 'vpa = ?',
      whereArgs: [vpa],
    );

    if (maps.isNotEmpty) {
      return Payee.fromMap(maps.first);
    }
    return null;
  }

  Future<void> incrementPayeeFrequency(String vpa, String? displayName, DateTime timestamp) async {
    final db = await _dbHelper.database;
    final payee = await getPayeeByVpa(vpa);
    
    if (payee != null) {
      final updatedPayee = Payee(
        vpa: vpa,
        displayName: displayName ?? payee.displayName,
        firstSeen: payee.firstSeen,
        lastSeen: timestamp,
        frequencyCount: payee.frequencyCount + 1,
        isKnown: true,
      );
      await insertOrUpdatePayee(updatedPayee);
    } else {
      final newPayee = Payee(
        vpa: vpa,
        displayName: displayName,
        firstSeen: timestamp,
        lastSeen: timestamp,
        frequencyCount: 1,
        isKnown: true,
      );
      await insertOrUpdatePayee(newPayee);
    }
  }
}
