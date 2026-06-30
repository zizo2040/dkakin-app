// lib/presentation/blocs/suppliers/suppliers_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/supplier.dart';
import '../../../data/models/supplier_invoice.dart';

abstract class SuppliersState extends Equatable {
  const SuppliersState();
  @override
  List<Object?> get props => [];
}

class SuppliersLoading extends SuppliersState {}

class SuppliersLoaded extends SuppliersState {
  final List<Supplier> suppliers;
  const SuppliersLoaded(this.suppliers);
  bool get isEmpty => suppliers.isEmpty;
  @override
  List<Object?> get props => [suppliers];
}

class SupplierDetailLoaded extends SuppliersState {
  final Supplier supplier;
  final List<SupplierInvoice> invoices;
  final double totalPurchases;
  const SupplierDetailLoaded({
    required this.supplier,
    required this.invoices,
    required this.totalPurchases,
  });
  @override
  List<Object?> get props => [supplier, invoices, totalPurchases];
}

class SuppliersError extends SuppliersState {
  final String message;
  const SuppliersError(this.message);
  @override
  List<Object?> get props => [message];
}

class SuppliersSuccess extends SuppliersState {
  final String message;
  const SuppliersSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
