// lib/data/repositories/sale_repository.dart
// مستودع المبيعات — CRUD + معالجة كاملة لعملية البيع (معاملة)
import '../local/database_helper.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class SaleRepository {
  final DatabaseHelper _db;
  static const String _salesTable = 'sales';
  static const String _itemsTable = 'sale_items';

  SaleRepository(this._db);

  /// إجراء عملية بيع كاملة (معاملة)
  Future<String> processSale({
    required Sale sale,
    required List<SaleItem> items,
  }) async {
    return _db.transaction((txn) async {
      // 1. إدراج البيع
      await txn.insert(_salesTable, sale.toMap());

      // 2. إدراج البنود
      for (final item in items) {
        await txn.insert(_itemsTable, item.toMap());

        // 3. تقليل المخزون
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }

      return sale.id;
    });
  }

  /// جميع المبيعات
  Future<List<Sale>> getAll({int limit = 100}) async {
    final maps = await _db.query(
      _salesTable,
      orderBy: 'sale_date DESC',
      limit: limit,
    );
    return maps.map(Sale.fromMap).toList();
  }

  /// مبيعات اليوم
  Future<List<Sale>> getTodaySales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final maps = await _db.query(
      _salesTable,
      where: 'sale_date BETWEEN ? AND ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'sale_date DESC',
    );
    return maps.map(Sale.fromMap).toList();
  }

  /// بنود بيع معين
  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final maps = await _db.rawQuery('''
      SELECT si.*, p.name as product_name 
      FROM sale_items si
      INNER JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = ?
    ''', [saleId]);
    return maps.map(SaleItem.fromMap).toList();
  }

  /// إجمالي مبيعات اليوم
  Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total 
      FROM sales 
      WHERE sale_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);

    return (result.first['total'] as num).toDouble();
  }

  /// مبيعات آخر 7 أيام
  Future<List<Map<String, dynamic>>> getLast7DaysSales() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - 6).toIso8601String();

    return _db.rawQuery('''
      SELECT 
        date(sale_date) as day,
        SUM(total_amount) as total,
        COUNT(*) as count
      FROM sales
      WHERE sale_date >= ?
      GROUP BY date(sale_date)
      ORDER BY day
    ''', [startDate]);
  }

  /// عدد المبيعات
  Future<int> count() async {
    return _db.count(_salesTable);
  }

  /// مبيعات نقدية اليوم
  Future<double> getTodayCashSales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total 
      FROM sales 
      WHERE sale_type = 'cash' AND sale_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);

    return (result.first['total'] as num).toDouble();
  }

  /// ديون جديدة اليوم
  Future<double> getTodayDebtSales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total 
      FROM sales 
      WHERE sale_type = 'debt' AND sale_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);

    return (result.first['total'] as num).toDouble();
  }
}
