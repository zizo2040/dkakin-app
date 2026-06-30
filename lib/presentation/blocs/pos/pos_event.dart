// lib/presentation/blocs/pos/pos_event.dart
// أحداث نقطة البيع
import 'package:equatable/equatable.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل المنتجات
class PosLoadProducts extends PosEvent {}

/// البحث عن منتج
class PosSearchProduct extends PosEvent {
  final String query;
  const PosSearchProduct(this.query);

  @override
  List<Object?> get props => [query];
}

/// إضافة منتج للسلة
class PosAddToCart extends PosEvent {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final int availableStock;

  const PosAddToCart({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.availableStock,
  });

  @override
  List<Object?> get props => [productId, productName, unitPrice, quantity, availableStock];
}

/// تغيير الكمية
class PosUpdateQuantity extends PosEvent {
  final String productId;
  final int newQuantity;

  const PosUpdateQuantity({required this.productId, required this.newQuantity});

  @override
  List<Object?> get props => [productId, newQuantity];
}

/// إزالة من السلة
class PosRemoveFromCart extends PosEvent {
  final String productId;
  const PosRemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// إتمام البيع (كاش)
class PosCheckoutCash extends PosEvent {}

/// إتمام البيع (دين)
class PosCheckoutDebt extends PosEvent {
  final String customerId;
  final String? customerName;
  final String? notes;

  const PosCheckoutDebt({
    required this.customerId,
    this.customerName,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, customerName, notes];
}

/// مسح السلة
class PosClearCart extends PosEvent {}

/// تحميل المنتجات الأكثر مبيعاً
class PosLoadTopProducts extends PosEvent {}
