// lib/data/models/sale_item.dart
// نموذج بند البيع — أسماء الحقول تطابق قاعدة البيانات
class SaleItem {
  final String id; // UUID v4
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice;

  // حقول مؤقتة من الربط مع products
  final String? productName;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.productName,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as String,
      saleId: map['sale_id'] as String,
      productId: map['product_id'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      productName: map['product_name'] as String?,
    );
  }

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    double? unitPrice,
    String? productName,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      productName: productName ?? this.productName,
    );
  }

  @override
  String toString() => 'SaleItem($productName x$quantity @ $unitPrice)';
}
