// lib/data/models/product.dart
// نموذج المنتج — أسماء الحقول تطابق قاعدة البيانات
class Product {
  final String id; // UUID v4
  final String name;
  final double sellPrice;
  final double costPrice;
  final int quantity;
  final DateTime? expiryDate;
  final String? supplierId;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.sellPrice,
    required this.costPrice,
    this.quantity = 0,
    this.expiryDate,
    this.supplierId,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sell_price': sellPrice,
      'cost_price': costPrice,
      'quantity': quantity,
      'expiry_date': expiryDate?.toIso8601String(),
      'supplier_id': supplierId,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      sellPrice: (map['sell_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      supplierId: map['supplier_id'] as String?,
      isActive: (map['is_active'] as num? ?? 1) == 1,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? sellPrice,
    double? costPrice,
    int? quantity,
    DateTime? expiryDate,
    String? supplierId,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sellPrice: sellPrice ?? this.sellPrice,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      supplierId: supplierId ?? this.supplierId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, qty: $quantity)';
}
