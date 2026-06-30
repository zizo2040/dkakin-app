// lib/presentation/blocs/products/products_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object?> get props => [];
}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Product> filtered;
  final String? searchQuery;

  const ProductsLoaded({
    required this.products,
    this.filtered = const [],
    this.searchQuery,
  });

  List<Product> get displayList => searchQuery != null && searchQuery!.isNotEmpty ? filtered : products;
  bool get isEmpty => displayList.isEmpty;

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Product>? filtered,
    String? searchQuery,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      filtered: filtered ?? this.filtered,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [products, filtered, searchQuery];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProductsSuccess extends ProductsState {
  final String message;
  const ProductsSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
