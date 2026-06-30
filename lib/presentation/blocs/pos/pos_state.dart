// lib/presentation/blocs/pos/pos_state.dart
// حالات نقطة البيع — أربع حالات: loading, empty, error, ready
import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';

/// عنصر في السلة
class CartItem extends Equatable {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final int availableStock;

  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.availableStock,
  });

  double get totalPrice => quantity * unitPrice;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    int? availableStock,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
    );
  }

  @override
  List<Object?> get props => [productId, productName, unitPrice, quantity, availableStock];
}

abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];
}

/// جاري التحميل
class PosLoading extends PosState {}

/// جاهز للبيع
class PosReady extends PosState {
  final List<Product> products;
  final List<Product> searchResults;
  final List<CartItem> cart;
  final List<Product> topProducts;
  final String? searchQuery;

  const PosReady({
    required this.products,
    this.searchResults = const [],
    this.cart = const [],
    this.topProducts = const [],
    this.searchQuery,
  });

  double get grandTotal => cart.fold(0, (sum, item) => sum + item.totalPrice);
  int get cartItemCount => cart.fold(0, (sum, item) => sum + item.quantity);

  PosReady copyWith({
    List<Product>? products,
    List<Product>? searchResults,
    List<CartItem>? cart,
    List<Product>? topProducts,
    String? searchQuery,
  }) {
    return PosReady(
      products: products ?? this.products,
      searchResults: searchResults ?? this.searchResults,
      cart: cart ?? this.cart,
      topProducts: topProducts ?? this.topProducts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [products, searchResults, cart, topProducts, searchQuery];
}

/// خطأ
class PosError extends PosState {
  final String message;
  const PosError(this.message);

  @override
  List<Object?> get props => [message];
}

/// عملية ناجحة
class PosSaleSuccess extends PosState {
  final String saleId;
  final double total;
  final String customerName;
  final bool isDebt;

  const PosSaleSuccess({
    required this.saleId,
    required this.total,
    required this.customerName,
    required this.isDebt,
  });

  @override
  List<Object?> get props => [saleId, total, customerName, isDebt];
}
