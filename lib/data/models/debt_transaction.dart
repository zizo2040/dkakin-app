// lib/data/models/debt_transaction.dart
// نموذج معاملة الديون — أسماء الحقول تطابق قاعدة البيانات
class DebtTransaction {
  final String id; // UUID v4
  final String customerId;
  final double amount;
  final DebtType transactionType;
  final String? saleId; // nullable للسدادات المستقلة
  final String? notes;
  final DateTime transactionDate;

  // حقول مؤقتة من الربط
  final String? customerName;

  DebtTransaction({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.transactionType,
    this.saleId,
    this.notes,
    DateTime? transactionDate,
    this.customerName,
  }) : transactionDate = transactionDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount': amount,
      'transaction_type': transactionType.name,
      'sale_id': saleId,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }

  factory DebtTransaction.fromMap(Map<String, dynamic> map) {
    return DebtTransaction(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      transactionType: DebtType.values.byName(map['transaction_type'] as String),
      saleId: map['sale_id'] as String?,
      notes: map['notes'] as String?,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      customerName: map['customer_name'] as String?,
    );
  }

  DebtTransaction copyWith({
    String? id,
    String? customerId,
    double? amount,
    DebtType? transactionType,
    String? saleId,
    String? notes,
    DateTime? transactionDate,
    String? customerName,
  }) {
    return DebtTransaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      saleId: saleId ?? this.saleId,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      customerName: customerName ?? this.customerName,
    );
  }

  @override
  String toString() => 'DebtTransaction($transactionType: $amount)';
}

enum DebtType {
  debt, // دين جديد
  payment, // سداد
}
