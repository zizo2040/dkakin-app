// lib/presentation/blocs/pos/pos_bloc.dart
// Bloc نقطة البيع — يتعامل مع السلة والبحث والدفع
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/trial_limits.dart';
import '../../../core/security/i_activation_validator.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/sale_item.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/sale_repository.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final ProductRepository _productRepo;
  final SaleRepository _saleRepo;
  final CustomerRepository _customerRepo;
  final IActivationValidator _activation;

  PosBloc({
    required ProductRepository productRepo,
    required SaleRepository saleRepo,
    required CustomerRepository customerRepo,
    required IActivationValidator activation,
  })  : _productRepo = productRepo,
        _saleRepo = saleRepo,
        _customerRepo = customerRepo,
        _activation = activation,
        super(PosLoading()) {
    on<PosLoadProducts>(_onLoadProducts);
    on<PosSearchProduct>(_onSearch);
    on<PosAddToCart>(_onAddToCart);
    on<PosUpdateQuantity>(_onUpdateQuantity);
    on<PosRemoveFromCart>(_onRemoveFromCart);
    on<PosCheckoutCash>(_onCheckoutCash);
    on<PosCheckoutDebt>(_onCheckoutDebt);
    on<PosClearCart>(_onClearCart);
    on<PosLoadTopProducts>(_onLoadTopProducts);
  }

  /// تحميل المنتجات
  Future<void> _onLoadProducts(
    PosLoadProducts event,
    Emitter<PosState> emit,
  ) async {
    emit(PosLoading());
    try {
      final products = await _productRepo.getAll();
      final topProducts = await _productRepo.getMostUsed(8);
      emit(PosReady(products: products, topProducts: topProducts));
    } catch (e) {
      emit(PosError('${AppStrings.dbError}: $e'));
    }
  }

  /// البحث
  Future<void> _onSearch(
    PosSearchProduct event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    if (event.query.isEmpty) {
      emit(current.copyWith(searchResults: [], searchQuery: null));
      return;
    }

    try {
      final results = await _productRepo.searchByName(event.query);
      emit(current.copyWith(searchResults: results, searchQuery: event.query));
    } catch (e) {
      emit(PosError('${AppStrings.dbError}: $e'));
    }
  }

  /// إضافة للسلة
  Future<void> _onAddToCart(
    PosAddToCart event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    // التحقق من المخزون
    if (event.quantity > event.availableStock) {
      emit(PosError('${AppStrings.stockWarning} ${event.availableStock}'));
      emit(current); // إعادة الحالة السابقة
      return;
    }

    final existingIndex = current.cart.indexWhere(
      (item) => item.productId == event.productId,
    );

    List<CartItem> newCart = List.from(current.cart);

    if (existingIndex >= 0) {
      final existing = newCart[existingIndex];
      final newQuantity = existing.quantity + event.quantity;
      if (newQuantity > event.availableStock) {
        emit(PosError('${AppStrings.stockWarning} ${event.availableStock}'));
        emit(current);
        return;
      }
      newCart[existingIndex] = existing.copyWith(quantity: newQuantity);
    } else {
      newCart.add(CartItem(
        productId: event.productId,
        productName: event.productName,
        unitPrice: event.unitPrice,
        quantity: event.quantity,
        availableStock: event.availableStock,
      ));
    }

    emit(current.copyWith(cart: newCart));
  }

  /// تغيير الكمية
  Future<void> _onUpdateQuantity(
    PosUpdateQuantity event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    if (event.newQuantity < 1) return;

    final index = current.cart.indexWhere(
      (item) => item.productId == event.productId,
    );
    if (index < 0) return;

    final item = current.cart[index];
    if (event.newQuantity > item.availableStock) {
      emit(PosError('${AppStrings.stockWarning} ${item.availableStock}'));
      emit(current);
      return;
    }

    final newCart = List<CartItem>.from(current.cart);
    newCart[index] = item.copyWith(quantity: event.newQuantity);
    emit(current.copyWith(cart: newCart));
  }

  /// إزالة من السلة
  Future<void> _onRemoveFromCart(
    PosRemoveFromCart event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;
    final newCart = current.cart.where(
      (item) => item.productId != event.productId,
    ).toList();
    emit(current.copyWith(cart: newCart));
  }

  /// دفع كاش
  Future<void> _onCheckoutCash(
    PosCheckoutCash event,
    Emitter<PosState> emit,
  ) async {
    await _processSale(
      customerId: null,
      customerName: 'زبون نقدي',
      notes: null,
      isDebt: false,
      emit: emit,
    );
  }

  /// دفع دين
  Future<void> _onCheckoutDebt(
    PosCheckoutDebt event,
    Emitter<PosState> emit,
  ) async {
    await _processSale(
      customerId: event.customerId,
      customerName: event.customerName ?? 'زبون',
      notes: event.notes,
      isDebt: true,
      emit: emit,
    );
  }

  /// معالجة البيع
  Future<void> _processSale({
    required String? customerId,
    required String customerName,
    required String? notes,
    required bool isDebt,
    required Emitter<PosState> emit,
  }) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    if (current.cart.isEmpty) return;

    // التحقق من حد البيع
    final canSell = await _activation.canPerform(UsageType.sale);
    if (!canSell) {
      emit(PosError(AppStrings.trialLimitSale));
      emit(current);
      return;
    }

    try {
      final saleId = const Uuid().v4();
      final total = current.grandTotal;

      final sale = Sale(
        id: saleId,
        customerId: customerId,
        totalAmount: total,
        saleType: isDebt ? SaleType.debt : SaleType.cash,
        notes: notes,
      );

      final items = current.cart.map((cartItem) => SaleItem(
        id: const Uuid().v4(),
        saleId: saleId,
        productId: cartItem.productId,
        quantity: cartItem.quantity,
        unitPrice: cartItem.unitPrice,
      )).toList();

      await _saleRepo.processSale(sale: sale, items: items);

      // تسجيل الاستخدام
      await _activation.recordUsage(UsageType.sale);

      emit(PosSaleSuccess(
        saleId: saleId,
        total: total,
        customerName: customerName,
        isDebt: isDebt,
      ));

      // إعادة تحميل
      final products = await _productRepo.getAll();
      final topProducts = await _productRepo.getMostUsed(8);
      emit(PosReady(products: products, topProducts: topProducts));
    } catch (e) {
      emit(PosError('${AppStrings.dbError}: $e'));
      emit(current);
    }
  }

  /// مسح السلة
  Future<void> _onClearCart(
    PosClearCart event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;
    emit(current.copyWith(cart: []));
  }

  /// تحميل الأكثر مبيعاً
  Future<void> _onLoadTopProducts(
    PosLoadTopProducts event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;
    try {
      final top = await _productRepo.getMostUsed(8);
      emit(current.copyWith(topProducts: top));
    } catch (_) {
      // silently fail for top products
    }
  }
}
