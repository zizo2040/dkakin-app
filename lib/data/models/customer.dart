// lib/data/models/customer.dart
// نموذج الزبون — أسماء الحقول تطابق قاعدة البيانات
class Customer {
  final String id; // UUID v4
  final String name;
  final String? phone;
  final double totalDebt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.totalDebt = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'total_debt': totalDebt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      totalDebt: (map['total_debt'] as num?)?.toDouble() ?? 0,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    double? totalDebt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      totalDebt: totalDebt ?? this.totalDebt,
    );
  }

  @override
  String toString() => 'Customer(id: $id, name: $name, debt: $totalDebt)';
}
