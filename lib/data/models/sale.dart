// lib/data/models/sale.dart
// نموذج عملية البيع — أسماء الحقول تطابق قاعدة البيانات
class Sale {
  final String id; // UUID v4
  final String? customerId; // nullable للمبيعات النقدية بدون زبون
  final double totalAmount;
  final SaleType saleType;
  final String? notes;
  final DateTime saleDate;

  Sale({
    required this.id,
    this.customerId,
    required this.totalAmount,
    required this.saleType,
    this.notes,
    DateTime? saleDate,
  }) : saleDate = saleDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'sale_type': saleType.name,
      'notes': notes,
      'sale_date': saleDate.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      customerId: map['customer_id'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      saleType: SaleType.values.byName(map['sale_type'] as String),
      notes: map['notes'] as String?,
      saleDate: DateTime.parse(map['sale_date'] as String),
    );
  }

  Sale copyWith({
    String? id,
    String? customerId,
    double? totalAmount,
    SaleType? saleType,
    String? notes,
    DateTime? saleDate,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      saleType: saleType ?? this.saleType,
      notes: notes ?? this.notes,
      saleDate: saleDate ?? this.saleDate,
    );
  }

  @override
  String toString() => 'Sale(id: $id, type: $saleType, amount: $totalAmount)';
}

enum SaleType {
  cash, // كاش
  debt, // دين
}
