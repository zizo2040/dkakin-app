// lib/data/repositories/report_repository.dart
// مستودع التقارير — الحسابات والإحصائيات
// صافي الربح = (مبيعات كاش + مسددات) - تكلفة البضاعة المباعة
import '../local/database_helper.dart';

class ReportRepository {
  final DatabaseHelper _db;

  ReportRepository(this._db);

  /// صافي ربح اليوم
  /// المعادلة: (مبيعات كاش + مسددات) - تكلفة البضاعة المباعة
  Future<double> getTodayNetProfit() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    // مبيعات كاش اليوم
    final cashResult = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total 
      FROM sales 
      WHERE sale_type = 'cash' AND sale_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);
    final cashSales = (cashResult.first['total'] as num).toDouble();

    // مسددات اليوم
    final paymentsResult = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM debt_transactions 
      WHERE transaction_type = 'payment' AND transaction_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);
    final payments = (paymentsResult.first['total'] as num).toDouble();

    // تكلفة البضاعة المباعة اليوم
    final costResult = await _db.rawQuery('''
      SELECT COALESCE(SUM(si.quantity * p.cost_price), 0) as total_cost
      FROM sale_items si
      INNER JOIN sales s ON si.sale_id = s.id
      INNER JOIN products p ON si.product_id = p.id
      WHERE s.sale_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);
    final costOfGoods = (costResult.first['total_cost'] as num).toDouble();

    // المعادلة
    final netProfit = (cashSales + payments) - costOfGoods;
    return netProfit;
  }

  /// مبيعات كاش اليوم
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
  Future<double> getTodayNewDebts() async {
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

  /// سداد محصل اليوم
  Future<double> getTodayCollectedPayments() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM debt_transactions 
      WHERE transaction_type = 'payment' AND transaction_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);

    return (result.first['total'] as num).toDouble();
  }

  /// مبيعات آخر 7 أيام (للرسم البياني)
  Future<List<DailyReport>> getLast7DaysReport() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day - 6);

    final result = await _db.rawQuery('''
      SELECT 
        date(s.sale_date) as day,
        SUM(CASE WHEN s.sale_type = 'cash' THEN s.total_amount ELSE 0 END) as cash_sales,
        SUM(CASE WHEN s.sale_type = 'debt' THEN s.total_amount ELSE 0 END) as debt_sales,
        COUNT(*) as transaction_count
      FROM sales s
      WHERE date(s.sale_date) >= date(?)
      GROUP BY date(s.sale_date)
      ORDER BY day
    ''', [startDate.toIso8601String()]);

    return result.map((map) => DailyReport(
      day: DateTime.parse(map['day'] as String),
      cashSales: (map['cash_sales'] as num?)?.toDouble() ?? 0,
      debtSales: (map['debt_sales'] as num?)?.toDouble() ?? 0,
      transactionCount: (map['transaction_count'] as num?)?.toInt() ?? 0,
    )).toList();
  }

  /// أكثر 5 منتجات مبيعاً
  Future<List<TopProductReport>> getTop5Products() async {
    final result = await _db.rawQuery('''
      SELECT 
        p.id,
        p.name,
        SUM(si.quantity) as total_quantity,
        SUM(si.quantity * si.unit_price) as total_revenue,
        SUM(si.quantity * p.cost_price) as total_cost
      FROM sale_items si
      INNER JOIN products p ON si.product_id = p.id
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT 5
    ''');

    return result.map((map) => TopProductReport(
      productId: map['id'] as String,
      productName: map['name'] as String,
      quantity: (map['total_quantity'] as num).toInt(),
      revenue: (map['total_revenue'] as num).toDouble(),
      cost: (map['total_cost'] as num).toDouble(),
    )).toList();
  }

  /// إجمالي المبيعات (كل الأنواع)
  Future<double> getTotalSalesAllTime() async {
    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) as total FROM sales
    ''');
    return (result.first['total'] as num).toDouble();
  }

  /// إجمالي الديون المستحقة
  Future<double> getTotalOutstandingDebts() async {
    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_debt), 0) as total FROM customers
    ''');
    return (result.first['total'] as num).toDouble();
  }
}

/// تقرير يومي
class DailyReport {
  final DateTime day;
  final double cashSales;
  final double debtSales;
  final int transactionCount;

  DailyReport({
    required this.day,
    required this.cashSales,
    required this.debtSales,
    required this.transactionCount,
  });

  double get totalSales => cashSales + debtSales;
}

/// تقرير المنتج الأكثر مبيعاً
class TopProductReport {
  final String productId;
  final String productName;
  final int quantity;
  final double revenue;
  final double cost;

  TopProductReport({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
    required this.cost,
  });

  double get profit => revenue - cost;
}
