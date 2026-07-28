import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'sentinelpay_v2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL,
        direction TEXT,
        method TEXT,
        payee_identifier TEXT,
        payee_name TEXT,
        timestamp TEXT,
        source_bank TEXT,
        matched_template_id TEXT,
        source TEXT,
        verdict TEXT,
        confidence REAL,
        evidence_json TEXT,
        user_reported_outcome TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE payees (
        vpa TEXT PRIMARY KEY,
        display_name TEXT,
        first_seen TEXT,
        last_seen TEXT,
        frequency_count INTEGER,
        is_known INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE behaviour_profile (
        id INTEGER PRIMARY KEY,
        rolling_window_size INTEGER,
        model_version TEXT,
        last_trained_at TEXT,
        training_sample_count INTEGER,
        feature_store_ref TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sms_parse_log (
        id TEXT PRIMARY KEY,
        parsed_at TEXT,
        match_status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        sms_permission_granted INTEGER DEFAULT 0,
        sms_raw_retention_enabled INTEGER DEFAULT 0,
        privacy_prefs TEXT,
        accessibility_prefs TEXT,
        opt_in_flags TEXT
      )
    ''');
    
    // Insert default profile
    await db.insert('behaviour_profile', {
      'id': 1,
      'rolling_window_size': 200,
      'model_version': '1.0.0',
      'last_trained_at': DateTime.now().toIso8601String(),
      'training_sample_count': 0,
    });
  }
}
