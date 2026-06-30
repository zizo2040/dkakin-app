// lib/presentation/blocs/products/products_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/trial_limits.dart';
import '../../../core/security/i_activation_validator.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository _productRepo;
  final IActivationValidator _activation;

  ProductsBloc({
    required ProductRepository productRepo,
    required IActivationValidator activation,
  })  : _productRepo = productRepo,
        _activation = activation,
        super(ProductsLoading()) {
    on<ProductsLoad>(_onLoad);
    on<ProductsSearch>(_onSearch);
    on<ProductsAdd>(_onAdd);
    on<ProductsDelete>(_onDelete);
  }

  Future<void> _onLoad(ProductsLoad event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      final products = await _productRepo.getAll();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onSearch(ProductsSearch event, Emitter<ProductsState> emit) async {
    if (state is! ProductsLoaded) return;
    final current = state as ProductsLoaded;
    try {
      if (event.query.isEmpty) {
        emit(current.copyWith(filtered: [], searchQuery: null));
        return;
      }
      final results = await _productRepo.searchByName(event.query);
      emit(current.copyWith(filtered: results, searchQuery: event.query));
    } catch (e) {
      emit(ProductsError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onAdd(ProductsAdd event, Emitter<ProductsState> emit) async {
    final canAdd = await _activation.canPerform(UsageType.product);
    if (!canAdd) {
      emit(const ProductsError(AppStrings.trialLimitProduct));
      return;
    }

    try {
      final product = Product(
        id: const Uuid().v4(),
        name: event.name,
        sellPrice: event.sellPrice,
        costPrice: event.costPrice,
        quantity: event.quantity,
        expiryDate: event.expiryDate,
        supplierId: event.supplierId,
      );
      await _productRepo.insert(product);
      await _activation.recordUsage(UsageType.product);
      emit(const ProductsSuccess(AppStrings.addProduct));
      add(ProductsLoad());
    } catch (e) {
      emit(ProductsError('${AppStrings.dbError}: $e'));
    }
  }

  Future<void> _onDelete(ProductsDelete event, Emitter<ProductsState> emit) async {
    try {
      await _productRepo.delete(event.productId);
      emit(const ProductsSuccess('تم الحذف'));
      add(ProductsLoad());
    } catch (e) {
      emit(ProductsError('${AppStrings.dbError}: $e'));
    }
  }
}
