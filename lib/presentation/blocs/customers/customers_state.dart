// lib/presentation/blocs/customers/customers_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/debt_transaction.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();
  @override
  List<Object?> get props => [];
}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<Customer> customers;
  final List<Customer> filtered;
  final SortType sortType;
  final String? searchQuery;

  const CustomersLoaded({
    required this.customers,
    this.filtered = const [],
    this.sortType = SortType.byDebt,
    this.searchQuery,
  });

  List<Customer> get displayList => searchQuery != null && searchQuery!.isNotEmpty ? filtered : customers;
  bool get isEmpty => displayList.isEmpty;

  CustomersLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filtered,
    SortType? sortType,
    String? searchQuery,
  }) {
    return CustomersLoaded(
      customers: customers ?? this.customers,
      filtered: filtered ?? this.filtered,
      sortType: sortType ?? this.sortType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [customers, filtered, sortType, searchQuery];
}

class CustomerDetailLoaded extends CustomersState {
  final Customer customer;
  final List<DebtTransaction> transactions;
  final bool canUndo;
  final int? undoSecondsRemaining;

  const CustomerDetailLoaded({
    required this.customer,
    required this.transactions,
    this.canUndo = false,
    this.undoSecondsRemaining,
  });

  CustomerDetailLoaded copyWith({
    Customer? customer,
    List<DebtTransaction>? transactions,
    bool? canUndo,
    int? undoSecondsRemaining,
  }) {
    return CustomerDetailLoaded(
      customer: customer ?? this.customer,
      transactions: transactions ?? this.transactions,
      canUndo: canUndo ?? this.canUndo,
      undoSecondsRemaining: undoSecondsRemaining ?? this.undoSecondsRemaining,
    );
  }

  @override
  List<Object?> get props => [customer, transactions, canUndo, undoSecondsRemaining];
}

class CustomersError extends CustomersState {
  final String message;
  const CustomersError(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomersSuccess extends CustomersState {
  final String message;
  const CustomersSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
