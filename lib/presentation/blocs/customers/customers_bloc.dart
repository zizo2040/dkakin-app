// lib/presentation/blocs/customers/customers_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/trial_limits.dart';
import '../../../core/security/i_activation_validator.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/debt_repository.dart';
import 'customers_event.dart';
import 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final CustomerRepository _customerRepo;
  final DebtRepository _debtRepo;
  final IActivationValidator _activation;

  CustomersBloc({
    required CustomerRepository customerRepo,
    required DebtRepository debtRepo,
    required IActivationValidator activation,
  })  : _customerRepo = customerRepo,
        _debtRepo = debtRepo,
        _activation = activation,
        super(CustomersLoading()) {
    on<CustomersLoad>(_onLoad);
    on<CustomersSearch>(_onSearch);
    on<CustomersAdd>(_onAdd);
    on<CustomersSort>(_onSort);
    on<CustomersRecordPayment>(_onRecordPayment);
    on<CustomersUndoLast>(_onUndoLast);
    on<CustomersLoadDetail>(_onLoadDetail);
  }

  Future<void> _onLoad(CustomersLoad event, Emitter<CustomersState> emit) async {
    emit(CustomersLoading());
    try {
      final customers = await _customerRepo.getByMostDebt();
      emit(CustomersLoaded(customers: customers));
    } catch (e) {
      emit(CustomersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onSearch(CustomersSearch event, Emitter<CustomersState> emit) async {
    if (state is! CustomersLoaded) return;
    final current = state as CustomersLoaded;
    try {
      if (event.query.isEmpty) {
        emit(current.copyWith(filtered: [], searchQuery: null));
        return;
      }
      final results = await _customerRepo.searchByName(event.query);
      emit(current.copyWith(filtered: results, searchQuery: event.query));
    } catch (e) {
      emit(CustomersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onAdd(CustomersAdd event, Emitter<CustomersState> emit) async {
    final canAdd = await _activation.canPerform(UsageType.customer);
    if (!canAdd) {
      emit(const CustomersError(AppStrings.trialLimitCustomer));
      return;
    }

    try {
      final customer = Customer(
        id: const Uuid().v4(),
        name: event.name,
        phone: event.phone,
      );
      await _customerRepo.insert(customer);
      await _activation.recordUsage(UsageType.customer);

      emit(const CustomersSuccess(AppStrings.addCustomer));
      add(CustomersLoad());
    } catch (e) {
      emit(CustomersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onSort(CustomersSort event, Emitter<CustomersState> emit) async {
    if (state is! CustomersLoaded) return;
    final current = state as CustomersLoaded;
    try {
      List<Customer> sorted;
      switch (event.sortType) {
        case SortType.byDebt:
          sorted = await _customerRepo.getByMostDebt();
          break;
        case SortType.byRecent:
          sorted = await _customerRepo.getRecent(100);
          break;
        case SortType.byName:
          sorted = await _customerRepo.getAll(orderBy: 'name');
          break;
      }
      emit(current.copyWith(customers: sorted, sortType: event.sortType));
    } catch (e) {
      emit(CustomersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onRecordPayment(
    CustomersRecordPayment event,
    Emitter<CustomersState> emit,
  ) async {
    try {
      await _debtRepo.recordPayment(
        customerId: event.customerId,
        amount: event.amount,
        notes: event.notes,
      );
      emit(const CustomersSuccess(AppStrings.recordPayment));
      add(CustomersLoadDetail(event.customerId));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onUndoLast(CustomersUndoLast event, Emitter<CustomersState> emit) async {
    try {
      final success = await _debtRepo.undoLastTransaction(event.customerId);
      if (success) {
        emit(const CustomersSuccess('تم التراجع بنجاح'));
        add(CustomersLoadDetail(event.customerId));
      } else {
        emit(const CustomersError('مفيش عملية للتراجع عنها'));
      }
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    CustomersLoadDetail event,
    Emitter<CustomersState> emit,
  ) async {
    emit(CustomersLoading());
    try {
      final customer = await _customerRepo.getById(event.customerId);
      if (customer == null) {
        emit(const CustomersError('الزبون مش موجود'));
        return;
      }
      final transactions = await _debtRepo.getCustomerTransactions(event.customerId);

      // التحقق من إمكانية التراجع
      final lastTx = await _debtRepo.getLastTransaction(event.customerId);
      bool canUndo = false;
      int? undoSeconds;
      if (lastTx != null) {
        final diff = DateTime.now().difference(lastTx.transactionDate).inSeconds;
        canUndo = diff < 60;
        undoSeconds = canUndo ? 60 - diff : null;
      }

      emit(CustomerDetailLoaded(
        customer: customer,
        transactions: transactions,
        canUndo: canUndo,
        undoSecondsRemaining: undoSeconds,
      ));
    } catch (e) {
      emit(CustomersError('${AppStrings.dbError}: $e'));
    }
  }
}
