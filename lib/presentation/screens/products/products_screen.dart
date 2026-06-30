// lib/presentation/screens/products/products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../blocs/products/products_bloc.dart';
import '../../blocs/products/products_event.dart';
import '../../blocs/products/products_state.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _selectedExpiry;
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(ProductsLoad());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _sellPriceController.dispose();
    _costPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.productsTitle),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) showErrorSnackBar(context, state.message);
          if (state is ProductsSuccess) showSuccessSnackBar(context, state.message);
        },
        builder: (context, state) {
          if (state is ProductsLoading) return const LoadingWidget();

          if (state is ProductsLoaded) {
            if (state.isEmpty) {
              return EmptyStateWidget(
                message: AppStrings.noProducts,
                icon: Icons.inventory_2_outlined,
                onAction: () => _showAddDialog(context),
                actionLabel: AppStrings.addProduct,
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    onChanged: (value) => context.read<ProductsBloc>().add(ProductsSearch(value)),
                    decoration: InputDecoration(
                      hintText: AppStrings.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.displayList.length,
                    itemBuilder: (context, index) {
                      final p = state.displayList[index];
                      final nearExpiry = isNearExpiry(p.expiryDate);
                      final expired = isExpired(p.expiryDate);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 4),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(p.name, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (nearExpiry || expired) ...[
                                const SizedBox(width: 8),
                                Text(
                                  expired ? AppStrings.expiredWarning : AppStrings.expiryWarning,
                                  style: TextStyle(fontSize: AppDimensions.fontCaption, color: expired ? AppColors.debtRed : AppColors.warningOrange),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text('${AppStrings.quantity}: ${p.quantity}', textDirection: TextDirection.rtl),
                          trailing: Text(formatCurrency(p.sellPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSubtitle)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const LoadingWidget();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(AppStrings.addProduct),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nameController, textDirection: TextDirection.rtl, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: AppStrings.productNameHint)),
                TextField(controller: _sellPriceController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: AppStrings.sellPriceHint)),
                TextField(controller: _costPriceController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: AppStrings.costPriceHint)),
                TextField(controller: _quantityController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: AppStrings.quantityHint)),
                // تاريخ الانتهاء
                ListTile(
                  title: Text(_selectedExpiry == null ? AppStrings.expiryDateHint : formatDate(_selectedExpiry!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => _selectedExpiry = picked);
                  },
                ),
                // Dropdown الموردين
                FutureBuilder(
                  future: context.read<SupplierRepository>().getAll(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final suppliers = snapshot.data!;
                    return DropdownButtonFormField<String?>(
                      value: _selectedSupplierId,
                      hint: const Text(AppStrings.selectSupplier),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('—')),
                        ...suppliers.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name, textDirection: TextDirection.rtl))),
                      ],
                      onChanged: (value) => setState(() => _selectedSupplierId = value),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final sellPrice = double.tryParse(_sellPriceController.text) ?? 0;
                final costPrice = double.tryParse(_costPriceController.text) ?? 0;
                final quantity = int.tryParse(_quantityController.text) ?? 0;

                if (name.isEmpty || sellPrice <= 0) return;

                // تحذير سعر البيع أقل من التكلفة
                if (sellPrice < costPrice) {
                  showDialog(
                    context: context,
                    builder: (warnCtx) => AlertDialog(
                      title: const Text('تنبيه'),
                      content: const Text(AppStrings.priceWarning),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(warnCtx), child: const Text(AppStrings.cancel)),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(warnCtx);
                            _saveProduct(name, sellPrice, costPrice, quantity);
                          },
                          child: const Text('متأكد'),
                        ),
                      ],
                    ),
                  );
                } else {
                  _saveProduct(name, sellPrice, costPrice, quantity);
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProduct(String name, double sellPrice, double costPrice, int quantity) {
    context.read<ProductsBloc>().add(ProductsAdd(
      name: name,
      sellPrice: sellPrice,
      costPrice: costPrice,
      quantity: quantity,
      expiryDate: _selectedExpiry,
      supplierId: _selectedSupplierId,
    ));
    _nameController.clear();
    _sellPriceController.clear();
    _costPriceController.clear();
    _quantityController.clear();
    _selectedExpiry = null;
    _selectedSupplierId = null;
    Navigator.pop(context);
  }
}
