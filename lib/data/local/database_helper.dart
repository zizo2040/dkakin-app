// lib/data/local/database_helper.dart
// مساعد قاعدة البيانات SQLite — مبني Offline-First
// TODO-SQLCIPHER: استبدل sqflite بـ sqlcipher_flutter_libs:
//   final db = await openDatabase(...) → await SqlCipher.openDatabase(..., password: '...')
// كل الاستعلامات تبقى كما هي — فقط طريقة الفتح تتغير
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_migrations.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'dkakin.db';
  static const int _dbVersion = 1;

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// الحصول على قاعدة البيانات
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// إغلاق القاعدة
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// تهيئة القاعدة
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure, // تفعيل foreign_keys
    );
  }

  /// تفعيل القيود الخارجية — إلزامي!
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// إنشاء الجداول عند أول تشغيل
  Future<void> _onCreate(Database db, int version) async {
    await DatabaseMigrations.createV1(db);
    await DatabaseMigrations.createIndexes(db);
  }

  /// ترقية القاعدة
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await DatabaseMigrations.upgrade(db, oldVersion, newVersion);
  }

  // ===== دوال CRUD مساعدة =====

  /// إدراج صف
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// استعلام
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// استعلام مخصص
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  /// تحديث
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// حذف
  Future<int> delete(String table, {required String where, required List<Object?> whereArgs}) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// عدد الصفوف
  Future<int> count(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table ${where != null ? 'WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// معاملة (Transaction)
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// مسح كل البيانات (للاختبار)
  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sale_items');
      await txn.delete('debt_transactions');
      await txn.delete('sales');
      await txn.delete('products');
      await txn.delete('customers');
      await txn.delete('suppliers');
      await txn.delete('supplier_invoices');
      await txn.delete('users');
      await txn.delete('app_settings');
    });
  }

  /// الحصول على مسار ملف القاعدة (للنسخ الاحتياطي)
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, _dbName);
  }
}
