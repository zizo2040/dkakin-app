// lib/data/repositories/supplier_repository.dart
// مستودع الموردين — CRUD + فواتير + إجمالي المشتريات
import '../local/database_helper.dart';
import '../models/supplier.dart';
import '../models/supplier_invoice.dart';

class SupplierRepository {
  final DatabaseHelper _db;
  static const String _table = 'suppliers';
  static const String _invoicesTable = 'supplier_invoices';

  SupplierRepository(this._db);

  /// إضافة مورد
  Future<String> insert(Supplier supplier) async {
    await _db.insert(_table, supplier.toMap());
    return supplier.id;
  }

  /// جميع الموردين
  Future<List<Supplier>> getAll() async {
    final maps = await _db.query(_table, orderBy: 'name');
    return maps.map(Supplier.fromMap).toList();
  }

  /// مورد بالمعرف
  Future<Supplier?> getById(String id) async {
    final maps = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }

  /// بحث بالاسم
  Future<List<Supplier>> searchByName(String query) async {
    final maps = await _db.query(
      _table,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name',
    );
    return maps.map(Supplier.fromMap).toList();
  }

  /// تحديث مورد
  Future<int> update(Supplier supplier) async {
    return _db.update(
      _table,
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  /// حذف مورد
  Future<int> delete(String id) async {
    return _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// عدد الموردين
  Future<int> count() async {
    return _db.count(_table);
  }

  // ===== فواتير المورد =====

  /// إضافة فاتورة
  Future<String> addInvoice(SupplierInvoice invoice) async {
    await _db.insert(_invoicesTable, invoice.toMap());
    return invoice.id;
  }

  /// فواتير المورد
  Future<List<SupplierInvoice>> getInvoices(String supplierId) async {
    final maps = await _db.query(
      _invoicesTable,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'invoice_date DESC',
    );
    return maps.map(SupplierInvoice.fromMap).toList();
  }

  /// إجمالي مشتريات المورد
  Future<double> getTotalPurchases(String supplierId) async {
    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total 
      FROM supplier_invoices 
      WHERE supplier_id = ?
    ''', [supplierId]);
    return (result.first['total'] as num).toDouble();
  }
}
