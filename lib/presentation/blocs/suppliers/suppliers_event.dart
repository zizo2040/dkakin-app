// lib/presentation/blocs/suppliers/suppliers_event.dart
import 'package:equatable/equatable.dart';

abstract class SuppliersEvent extends Equatable {
  const SuppliersEvent();
  @override
  List<Object?> get props => [];
}

class SuppliersLoad extends SuppliersEvent {}
class SuppliersAdd extends SuppliersEvent {
  final String name;
  final String? phone;
  final String? notes;
  const SuppliersAdd({required this.name, this.phone, this.notes});
  @override
  List<Object?> get props => [name, phone, notes];
}
class SuppliersLoadDetail extends SuppliersEvent {
  final String supplierId;
  const SuppliersLoadDetail(this.supplierId);
  @override
  List<Object?> get props => [supplierId];
}
class SuppliersAddInvoice extends SuppliersEvent {
  final String supplierId;
  final double amount;
  final String? invoiceNumber;
  final String? notes;
  const SuppliersAddInvoice({
    required this.supplierId,
    required this.amount,
    this.invoiceNumber,
    this.notes,
  });
  @override
  List<Object?> get props => [supplierId, amount, invoiceNumber, notes];
}
