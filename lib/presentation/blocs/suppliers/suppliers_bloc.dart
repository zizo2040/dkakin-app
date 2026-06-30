// lib/presentation/blocs/suppliers/suppliers_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/trial_limits.dart';
import '../../../core/security/i_activation_validator.dart';
import '../../../data/models/supplier.dart';
import '../../../data/models/supplier_invoice.dart';
import '../../../data/repositories/supplier_repository.dart';
import 'suppliers_event.dart';
import 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final SupplierRepository _supplierRepo;
  final IActivationValidator _activation;

  SuppliersBloc({
    required SupplierRepository supplierRepo,
    required IActivationValidator activation,
  })  : _supplierRepo = supplierRepo,
        _activation = activation,
        super(SuppliersLoading()) {
    on<SuppliersLoad>(_onLoad);
    on<SuppliersAdd>(_onAdd);
    on<SuppliersLoadDetail>(_onLoadDetail);
    on<SuppliersAddInvoice>(_onAddInvoice);
  }

  Future<void> _onLoad(SuppliersLoad event, Emitter<SuppliersState> emit) async {
    emit(SuppliersLoading());
    try {
      final suppliers = await _supplierRepo.getAll();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SuppliersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onAdd(SuppliersAdd event, Emitter<SuppliersState> emit) async {
    final canAdd = await _activation.canPerform(UsageType.supplier);
    if (!canAdd) {
      emit(const SuppliersError(AppStrings.trialLimitSupplier));
      return;
    }

    try {
      final supplier = Supplier(
        id: const Uuid().v4(),
        name: event.name,
        phone: event.phone,
        notes: event.notes,
      );
      await _supplierRepo.insert(supplier);
      await _activation.recordUsage(UsageType.supplier);
      emit(const SuppliersSuccess(AppStrings.addSupplier));
      add(SuppliersLoad());
    } catch (e) {
      emit(SuppliersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onLoadDetail(
    SuppliersLoadDetail event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(SuppliersLoading());
    try {
      final supplier = await _supplierRepo.getById(event.supplierId);
      if (supplier == null) {
        emit(const SuppliersError('المورد مش موجود'));
        return;
      }
      final invoices = await _supplierRepo.getInvoices(event.supplierId);
      final totalPurchases = await _supplierRepo.getTotalPurchases(event.supplierId);
      emit(SupplierDetailLoaded(
        supplier: supplier,
        invoices: invoices,
        totalPurchases: totalPurchases,
      ));
    } catch (e) {
      emit(SuppliersError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onAddInvoice(
    SuppliersAddInvoice event,
    Emitter<SuppliersState> emit,
  ) async {
    try {
      final invoice = SupplierInvoice(
        id: const Uuid().v4(),
        supplierId: event.supplierId,
        totalAmount: event.amount,
        invoiceNumber: event.invoiceNumber,
        notes: event.notes,
      );
      await _supplierRepo.addInvoice(invoice);
      emit(const SuppliersSuccess('تم تسجيل الفاتورة'));
      add(SuppliersLoadDetail(event.supplierId));
    } catch (e) {
      emit(SuppliersError('${AppStrings.dbError}: $e'));
    }
  }
}
