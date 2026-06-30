// lib/data/repositories/debt_repository.dart
// مستودع الديون — معاملات الديون + سجل الزبون + سداد + تراجع
import '../local/database_helper.dart';
import '../models/debt_transaction.dart';
import '../models/customer.dart';

class DebtRepository {
  final DatabaseHelper _db;
  static const String _table = 'debt_transactions';
  static const String _customersTable = 'customers';

  DebtRepository(this._db);

  /// تسجيل دين جديد
  Future<String> recordDebt(DebtTransaction transaction) async {
    return _db.transaction((txn) async {
      // 1. إدراج معاملة الدين
      await txn.insert(_table, transaction.toMap());

      // 2. زيادة إجمالي ديون الزبون
      await txn.rawUpdate(
        'UPDATE customers SET total_debt = total_debt + ? WHERE id = ?',
        [transaction.amount, transaction.customerId],
      );

      return transaction.id;
    });
  }

  /// تسجيل سداد
  Future<String> recordPayment({
    required String customerId,
    required double amount,
    String? notes,
  }) async {
    return _db.transaction((txn) async {
      // 1. التحقق من عدم تجاوز الدين
      final customerResult = await txn.rawQuery(
        'SELECT total_debt FROM customers WHERE id = ?',
        [customerId],
      );
      final currentDebt = (customerResult.first['total_debt'] as num).toDouble();

      if (amount > currentDebt) {
        throw Exception('مبلغ السداد أكبر من الدين الحالي');
      }

      // 2. إدراج معاملة السداد
      final transaction = DebtTransaction(
        id: '${DateTime.now().millisecondsSinceEpoch}_$customerId',
        customerId: customerId,
        amount: amount,
        transactionType: DebtType.payment,
        notes: notes,
      );
      await txn.insert(_table, transaction.toMap());

      // 3. تقليل دين الزبون
      await txn.rawUpdate(
        'UPDATE customers SET total_debt = total_debt - ? WHERE id = ?',
        [amount, customerId],
      );

      return transaction.id;
    });
  }

  /// سجل معاملات زبون
  Future<List<DebtTransaction>> getCustomerTransactions(
    String customerId, {
    int limit = 100,
  }) async {
    final maps = await _db.rawQuery('''
      SELECT dt.*, c.name as customer_name
      FROM debt_transactions dt
      INNER JOIN customers c ON dt.customer_id = c.id
      WHERE dt.customer_id = ?
      ORDER BY dt.transaction_date DESC
      LIMIT ?
    ''', [customerId, limit]);
    return maps.map(DebtTransaction.fromMap).toList();
  }

  /// إجمالي ديون جميع الزبائن
  Future<double> getTotalDebts() async {
    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(total_debt), 0) as total FROM customers
    ''');
    return (result.first['total'] as num).toDouble();
  }

  /// عدد معاملات الديون
  Future<int> count() async {
    return _db.count(_table);
  }

  /// إجمالي سدادات اليوم
  Future<double> getTodayPayments() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM debt_transactions 
      WHERE transaction_type = 'payment' 
      AND transaction_date BETWEEN ? AND ?
    ''', [startOfDay, endOfDay]);

    return (result.first['total'] as num).toDouble();
  }

  /// تراجع عن آخر عملية (خلال 60 ثانية)
  Future<bool> undoLastTransaction(String customerId) async {
    return _db.transaction((txn) async {
      // الحصول على آخر عملية
      final lastResult = await txn.rawQuery('''
        SELECT * FROM debt_transactions
        WHERE customer_id = ?
        ORDER BY transaction_date DESC
        LIMIT 1
      ''', [customerId]);

      if (lastResult.isEmpty) return false;

      final lastTx = DebtTransaction.fromMap(lastResult.first);

      // التحقق من أن العملية أحدث من 60 ثانية
      final now = DateTime.now();
      if (now.difference(lastTx.transactionDate).inSeconds > 60) {
        throw Exception('انتهى وقت التراجع (60 ثانية)');
      }

      // عكس العملية
      if (lastTx.transactionType == DebtType.debt) {
        // إذا كانت دين: نقلص من دين الزبون
        await txn.rawUpdate(
          'UPDATE customers SET total_debt = total_debt - ? WHERE id = ?',
          [lastTx.amount, customerId],
        );
      } else {
        // إذا كانت سداد: نزيد دين الزبون
        await txn.rawUpdate(
          'UPDATE customers SET total_debt = total_debt + ? WHERE id = ?',
          [lastTx.amount, customerId],
        );
      }

      // حذف المعاملة
      await txn.delete(
        _table,
        where: 'id = ?',
        whereArgs: [lastTx.id],
      );

      return true;
    });
  }

  /// آخر معاملة للزبون
  Future<DebtTransaction?> getLastTransaction(String customerId) async {
    final maps = await _db.query(
      _table,
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'transaction_date DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DebtTransaction.fromMap(maps.first);
  }
}
