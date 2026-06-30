// lib/presentation/screens/pos/pos_screen.dart
// شاشة نقطة البيع — أهم شاشة في التطبيق
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../blocs/pos/pos_bloc.dart';
import '../../blocs/pos/pos_event.dart';
import '../../blocs/pos/pos_state.dart';
import '../../widgets/debt_amount_text.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';
import '../debts/customers_list_screen.dart';

class PosScreen extends StatefulWidget {
  final bool rushMode;
  const PosScreen({super.key, this.rushMode = false});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PosBloc>().add(PosLoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCustomerBottomSheet(BuildContext context, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _CustomerSelectionSheet(
              total: total,
              scrollController: scrollController,
              onCustomerSelected: (customerId, customerName, notes) {
                Navigator.pop(ctx);
                context.read<PosBloc>().add(PosCheckoutDebt(
                  customerId: customerId,
                  customerName: customerName,
                  notes: notes,
                ));
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.posTitle),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<PosBloc, PosState>(
        listener: (context, state) {
          if (state is PosError) {
            showErrorSnackBar(context, state.message);
          } else if (state is PosSaleSuccess) {
            showSuccessSnackBar(
              context,
              state.isDebt ? AppStrings.debtRecorded : AppStrings.saleSuccess,
            );
            if (state.isDebt) {
              _showSendStatementDialog(context, state);
            }
          }
        },
        builder: (context, state) {
          if (state is PosLoading) {
            return const LoadingWidget();
          }

          if (state is PosReady) {
            return Column(
              children: [
                // شريط البحث
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          onChanged: (value) {
                            context.read<PosBloc>().add(PosSearchProduct(value));
                          },
                          decoration: InputDecoration(
                            hintText: AppStrings.searchProduct,
                            hintStyle: const TextStyle(fontSize: AppDimensions.fontBody),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              // TODO: فتح الكاميرا — يتطلب صلاحية CAMERA في AndroidManifest.xml
                              // <uses-permission android:name="android.permission.CAMERA" />
                              onPressed: () {
                                showErrorSnackBar(context, AppStrings.cameraNotAvailable);
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              tooltip: AppStrings.barcodeScan,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // نتائج البحث أو المنتجات الأكثر مبيعاً
                if (state.searchQuery != null && state.searchQuery!.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: state.searchResults.isEmpty
                        ? EmptyStateWidget(message: 'مفيش نتائج لـ "${state.searchQuery}"')
                        : ListView.builder(
                            itemCount: state.searchResults.length,
                            itemBuilder: (context, index) {
                              final p = state.searchResults[index];
                              return _ProductListTile(
                                product: p,
                                onTap: () => _addToCart(context, p),
                              );
                            },
                          ),
                  )
                else
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                          child: Text(
                            AppStrings.topProducts,
                            style: TextStyle(
                              fontSize: AppDimensions.fontSubtitle,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: state.topProducts.isEmpty
                              ? EmptyStateWidget(
                                  message: 'ابدأ بإضافة منتجات',
                                  onAction: () {},
                                  actionLabel: AppStrings.addProduct,
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: AppDimensions.paddingS,
                                    mainAxisSpacing: AppDimensions.paddingS,
                                  ),
                                  itemCount: state.topProducts.length,
                                  itemBuilder: (context, index) {
                                    final p = state.topProducts[index];
                                    return _ProductGridItem(
                                      product: p,
                                      onTap: () => _addToCart(context, p),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                // السلة
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // عنوان السلة
                      if (state.cart.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          color: AppColors.creamCard,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  context.read<PosBloc>().add(PosClearCart());
                                },
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('مسح', style: TextStyle(fontSize: AppDimensions.fontSmall)),
                              ),
                              Text(
                                '${state.cartItemCount} ${AppStrings.quantity}',
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontBody,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // بنود السلة
                      if (state.cart.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingL),
                          child: Text(
                            AppStrings.cartEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppDimensions.fontBody,
                              color: AppColors.textHint,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.cart.length,
                            itemBuilder: (context, index) {
                              final item = state.cart[index];
                              return _CartItemCard(
                                item: item,
                                onIncrease: () {
                                  context.read<PosBloc>().add(PosUpdateQuantity(
                                    productId: item.productId,
                                    newQuantity: item.quantity + 1,
                                  ));
                                },
                                onDecrease: () {
                                  if (item.quantity > 1) {
                                    context.read<PosBloc>().add(PosUpdateQuantity(
                                      productId: item.productId,
                                      newQuantity: item.quantity - 1,
                                    ));
                                  }
                                },
                                onRemove: () {
                                  context.read<PosBloc>().add(
                                    PosRemoveFromCart(item.productId),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                      // المجموع
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppStrings.grandTotal,
                              style: TextStyle(
                                fontSize: AppDimensions.fontSubtitle,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GrandTotalText(amount: state.grandTotal),
                          ],
                        ),
                      ),

                      // أزرار الدفع
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: state.cart.isEmpty
                                    ? null
                                    : () => context.read<PosBloc>().add(PosCheckoutCash()),
                                icon: const Icon(Icons.payments_outlined),
                                label: const Text(
                                  AppStrings.payCash,
                                  style: TextStyle(fontSize: AppDimensions.fontBody),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successGreen,
                                  foregroundColor: AppColors.white,
                                  minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: state.cart.isEmpty
                                    ? null
                                    : () => _showCustomerBottomSheet(context, state.grandTotal),
                                icon: const Icon(Icons.menu_book_outlined),
                                label: const Text(
                                  AppStrings.payDebt,
                                  style: TextStyle(fontSize: AppDimensions.fontBody),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.debtRed,
                                  foregroundColor: AppColors.white,
                                  minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const LoadingWidget();
        },
      ),
    );
  }

void _addToCart(BuildContext context, product) {
  context.read<PosBloc>().add(PosAddToCart(
    productId: product.id,               // أو product['id'] إذا كانت Map
    productName: product['name'] as String,
    unitPrice: product.sellPrice,        // أو (product['sell_price'] as num).toDouble()
    quantity: 1,
    availableStock: product.quantity,    // أو (product['quantity'] as int)
  ));
}
  void _showSendStatementDialog(BuildContext context, PosSaleSuccess state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.sendStatement),
        content: Text('إجمالي: ${formatCurrency(state.total)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.noThanks),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: إرسال كشف عبر واتساب
              showSuccessSnackBar(context, 'تم فتح واتساب');
            },
            child: const Text(AppStrings.viaWhatsapp),
          ),
        ],
      ),
    );
  }
}

// ===== الودجات الفرعية =====

class _ProductListTile extends StatelessWidget {
  final product;
  final VoidCallback onTap;

  const _ProductListTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name, textDirection: TextDirection.rtl),
      subtitle: Text(
        '${formatCurrency(product.sellPrice)} - ${AppStrings.stockWarning} ${product.quantity}',
        textDirection: TextDirection.rtl,
      ),
      trailing: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          shape: const CircleBorder(),
          minimumSize: const Size(44, 44),
        ),
        child: const Icon(Icons.add, size: 20),
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final product;
  final VoidCallback onTap;

  const _ProductGridItem({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppDimensions.fontSmall,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatCurrency(product.sellPrice),
              style: const TextStyle(
                fontSize: AppDimensions.fontCaption,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 18, color: AppColors.debtRed),
              ),
              Expanded(
                child: Text(
                  item.productName,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatCurrency(item.totalPrice),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppDimensions.fontBody,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove_circle_outline, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: AppDimensions.fontSubtitle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add_circle_outline, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== BottomSheet لاختيار الزبون =====

class _CustomerSelectionSheet extends StatefulWidget {
  final double total;
  final ScrollController scrollController;
  final Function(String customerId, String customerName, String? notes) onCustomerSelected;

  const _CustomerSelectionSheet({
    required this.total,
    required this.scrollController,
    required this.onCustomerSelected,
  });

  @override
  State<_CustomerSelectionSheet> createState() => _CustomerSelectionSheetState();
}

class _CustomerSelectionSheetState extends State<_CustomerSelectionSheet> {
  final _noteController = TextEditingController();
  String? _selectedCustomerId;
  String? _selectedCustomerName;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // المقبض
        Container(
          margin: const EdgeInsets.only(top: AppDimensions.paddingM),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.grandTotal}: ${formatCurrency(widget.total)}',
                style: const TextStyle(
                  fontSize: AppDimensions.fontSubtitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                AppStrings.selectCustomer,
                style: TextStyle(
                  fontSize: AppDimensions.fontSubtitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // قائمة الزبائن الأخيرة
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppStrings.recentCustomers,
              style: TextStyle(
                fontSize: AppDimensions.fontBody,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: context.read<CustomerRepository>().getRecent(5),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('مفيش زباين مسجّلين', style: TextStyle(color: AppColors.textHint)),
                );
              }
              return ListView.builder(
                controller: widget.scrollController,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final customer = snapshot.data![index];
                  final isSelected = _selectedCustomerId == customer.id;
                  return ListTile(
                    title: Text(customer.name, textDirection: TextDirection.rtl),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                        : const Icon(Icons.circle_outlined, color: AppColors.divider),
                    onTap: () {
                      setState(() {
                        _selectedCustomerId = customer.id;
                        _selectedCustomerName = customer.name;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        // ملاحظة
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: TextField(
            controller: _noteController,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: AppStrings.debtNoteHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
        ),n        // أزرار
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomersListScreen()),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text(AppStrings.newCustomer),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _selectedCustomerId == null
                      ? null
                      : () => widget.onCustomerSelected(
                            _selectedCustomerId!,
                            _selectedCustomerName!,
                            _noteController.text.isEmpty ? null : _noteController.text,
                          ),
                  icon: const Icon(Icons.save),
                  label: const Text(AppStrings.recordDebt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.debtRed,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
