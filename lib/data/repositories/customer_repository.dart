// lib/data/repositories/customer_repository.dart
// مستودع الزبائن — كل عمليات CRUD + بحث + تتبع الديون
import '../local/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _db;
  static const String _table = 'customers';

  CustomerRepository(this._db);

  /// إضافة زبون جديد
  Future<String> insert(Customer customer) async {
    await _db.insert(_table, customer.toMap());
    return customer.id;
  }

  /// الحصول على جميع الزبائن
  Future<List<Customer>> getAll({String orderBy = 'name'}) async {
    final maps = await _db.query(_table, orderBy: orderBy);
    return maps.map(Customer.fromMap).toList();
  }

  /// الحصول على زبون بالمعرف
  Future<Customer?> getById(String id) async {
    final maps = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  /// البحث عن زبون بالاسم
  Future<List<Customer>> searchByName(String query) async {
    final maps = await _db.query(
      _table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name',
    );
    return maps.map(Customer.fromMap).toList();
  }

  /// تحديث الزبون
  Future<int> update(Customer customer) async {
    return _db.update(
      _table,
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// تحديث إجمالي الدين
  Future<void> updateTotalDebt(String customerId, double newDebt) async {
    await _db.update(
      _table,
      {'total_debt': newDebt},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  /// حذف زبون
  Future<int> delete(String id) async {
    return _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// عدد الزبائن
  Future<int> count() async {
    return _db.count(_table);
  }

  /// الزبائن الأكثر ديناً
  Future<List<Customer>> getByMostDebt() async {
    final maps = await _db.query(
      _table,
      where: 'total_debt > 0',
      orderBy: 'total_debt DESC',
    );
    return maps.map(Customer.fromMap).toList();
  }

  /// آخر زبون تم التعامل معه
  Future<List<Customer>> getRecent(int limit) async {
    final maps = await _db.rawQuery('''
      SELECT c.* FROM customers c
      INNER JOIN sales s ON c.id = s.customer_id
      ORDER BY s.sale_date DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(Customer.fromMap).toList();
  }
}
