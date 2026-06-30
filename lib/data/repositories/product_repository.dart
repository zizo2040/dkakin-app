// lib/data/repositories/product_repository.dart
// مستودع المنتجات — CRUD + بحث + تحديث المخزون + أكثر المنتجات مبيعاً
import '../local/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper _db;
  static const String _table = 'products';

  ProductRepository(this._db);

  /// إضافة منتج
  Future<String> insert(Product product) async {
    await _db.insert(_table, product.toMap());
    return product.id;
  }

  /// جميع المنتجات النشطة
  Future<List<Product>> getAll({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await _db.query(
      _table,
      where: where,
      orderBy: 'name',
    );
    return maps.map(Product.fromMap).toList();
  }

  /// منتج بالمعرف
  Future<Product?> getById(String id) async {
    final maps = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// بحث بالاسم
  Future<List<Product>> searchByName(String query) async {
    final maps = await _db.query(
      _table,
      where: 'name LIKE ? AND is_active = 1',
      whereArgs: ['%$query%'],
      orderBy: 'name',
    );
    return maps.map(Product.fromMap).toList();
  }

  /// تحديث المنتج
  Future<int> update(Product product) async {
    return _db.update(
      _table,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// تحديث المخزون (كمية)
  Future<void> updateQuantity(String productId, int newQuantity) async {
    await _db.update(
      _table,
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  /// تقليل المخزون
  Future<void> decreaseQuantity(String productId, int amount) async {
    await _db.rawQuery(
      'UPDATE products SET quantity = quantity - ? WHERE id = ?',
      [amount, productId],
    );
  }

  /// حذف منتج (soft delete)
  Future<int> delete(String id) async {
    return _db.update(
      _table,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// عدد المنتجات
  Future<int> count() async {
    return _db.count(_table, where: 'is_active = 1');
  }

  /// أكثر المنتجات مبيعاً
  Future<List<Map<String, dynamic>>> getTopSelling(int limit) async {
    return _db.rawQuery('''
      SELECT 
        p.id, 
        p.name, 
        p.sell_price,
        SUM(si.quantity) as total_quantity,
        SUM(si.quantity * si.unit_price) as total_revenue
      FROM products p
      INNER JOIN sale_items si ON p.id = si.product_id
      WHERE p.is_active = 1
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [limit]);
  }

  /// المنتجات الأكثر استخداماً حديثاً (لشاشة POS)
  Future<List<Product>> getMostUsed(int limit) async {
    final maps = await _db.rawQuery('''
      SELECT p.* FROM products p
      INNER JOIN sale_items si ON p.id = si.product_id
      INNER JOIN sales s ON si.sale_id = s.id
      WHERE p.is_active = 1
      GROUP BY p.id
      ORDER BY MAX(s.sale_date) DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(Product.fromMap).toList();
  }
}
