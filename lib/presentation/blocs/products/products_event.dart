// lib/presentation/blocs/products/products_event.dart
import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object?> get props => [];
}

class ProductsLoad extends ProductsEvent {}
class ProductsSearch extends ProductsEvent {
  final String query;
  const ProductsSearch(this.query);
  @override
  List<Object?> get props => [query];
}
class ProductsAdd extends ProductsEvent {
  final String name;
  final double sellPrice;
  final double costPrice;
  final int quantity;
  final DateTime? expiryDate;
  final String? supplierId;
  const ProductsAdd({
    required this.name,
    required this.sellPrice,
    required this.costPrice,
    required this.quantity,
    this.expiryDate,
    this.supplierId,
  });
  @override
  List<Object?> get props => [name, sellPrice, costPrice, quantity, expiryDate, supplierId];
}
class ProductsDelete extends ProductsEvent {
  final String productId;
  const ProductsDelete(this.productId);
  @override
  List<Object?> get props => [productId];
}
