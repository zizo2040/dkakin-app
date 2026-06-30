// lib/presentation/blocs/customers/customers_event.dart
import 'package:equatable/equatable.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();
  @override
  List<Object?> get props => [];
}

class CustomersLoad extends CustomersEvent {}
class CustomersSearch extends CustomersEvent {
  final String query;
  const CustomersSearch(this.query);
  @override
  List<Object?> get props => [query];
}
class CustomersAdd extends CustomersEvent {
  final String name;
  final String? phone;
  const CustomersAdd({required this.name, this.phone});
  @override
  List<Object?> get props => [name, phone];
}
class CustomersSort extends CustomersEvent {
  final SortType sortType;
  const CustomersSort(this.sortType);
  @override
  List<Object?> get props => [sortType];
}
class CustomersRecordPayment extends CustomersEvent {
  final String customerId;
  final double amount;
  final String? notes;
  const CustomersRecordPayment({
    required this.customerId,
    required this.amount,
    this.notes,
  });
  @override
  List<Object?> get props => [customerId, amount, notes];
}
class CustomersUndoLast extends CustomersEvent {
  final String customerId;
  const CustomersUndoLast(this.customerId);
  @override
  List<Object?> get props => [customerId];
}
class CustomersLoadDetail extends CustomersEvent {
  final String customerId;
  const CustomersLoadDetail(this.customerId);
  @override
  List<Object?> get props => [customerId];
}

enum SortType { byDebt, byRecent, byName }
