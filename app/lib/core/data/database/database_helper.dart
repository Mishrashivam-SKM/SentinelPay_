// coverage:ignore-file
import 'dart:convert';
import 'dart:math';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final _secureStorage = const FlutterSecureStorage();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static void setDatabaseForTest(Database db) {
    _database = db;
  }

  Future<void> deleteDatabaseFile() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'sentinelpay_v2.db');
    await deleteDatabase(path);
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'sentinelpay_v2.db');

    String? dbPassword = await _secureStorage.read(key: 'db_encryption_key');
    if (dbPassword == null) {
      final random = Random.secure();
      dbPassword = base64UrlEncode(List<int>.generate(32, (i) => random.nextInt(256)));
      await _secureStorage.write(key: 'db_encryption_key', value: dbPassword);
    }

    return await openDatabase(
      path,
      version: 4,
      password: dbPassword,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  static Future<void> onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE scam_messages (
        id TEXT PRIMARY KEY,
        sender TEXT,
        body TEXT,
        timestamp TEXT,
        scamType TEXT,
        confidenceScore REAL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE blocked_entities (
        id TEXT PRIMARY KEY,
        entity_value TEXT,
        entity_type TEXT,
        timestamp INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE trusted_entities (
        id TEXT PRIMARY KEY,
        entity_value TEXT,
        entity_type TEXT,
        timestamp INTEGER
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

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS scam_messages (
          id TEXT PRIMARY KEY,
          sender TEXT,
          body TEXT,
          timestamp TEXT,
          scamType TEXT,
          confidenceScore REAL,
          is_synced INTEGER DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE blocked_entities (
          id TEXT PRIMARY KEY,
          entity_value TEXT,
          entity_type TEXT,
          timestamp INTEGER
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE trusted_entities (
          id TEXT PRIMARY KEY,
          entity_value TEXT,
          entity_type TEXT,
          timestamp INTEGER
        )
      ''');
    }
  }
}
