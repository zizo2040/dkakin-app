// lib/presentation/screens/suppliers/supplier_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';

class SupplierDetailScreen extends StatefulWidget {
  final String supplierId;
  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final _amountController = TextEditingController();
  final _invoiceNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SuppliersBloc>().add(SuppliersLoadDetail(widget.supplierId));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.supplierDetailTitle),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<SuppliersBloc, SuppliersState>(
        listener: (context, state) {
          if (state is SuppliersError) showErrorSnackBar(context, state.message);
          if (state is SuppliersSuccess) showSuccessSnackBar(context, state.message);
        },
        builder: (context, state) {
          if (state is SuppliersLoading) return const LoadingWidget();
          if (state is SupplierDetailLoaded) {
            final supplier = state.supplier;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  color: AppColors.brown.withOpacity(0.1),
                  child: Column(
                    children: [
                      Text(supplier.name, style: const TextStyle(fontSize: AppDimensions.fontSubtitle, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                      if (supplier.phone != null) Text(supplier.phone!, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(AppStrings.totalPurchases, style: const TextStyle(color: AppColors.textSecondary)),
                      Text(formatCurrency(state.totalPurchases), style: const TextStyle(fontSize: AppDimensions.fontDebtTotal, fontWeight: FontWeight.bold, color: AppColors.brown)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingM),
                  child: Align(alignment: Alignment.centerRight, child: Text(AppStrings.invoicesHistory, style: TextStyle(fontSize: AppDimensions.fontSubtitle, fontWeight: FontWeight.bold))),
                ),
                Expanded(
                  child: state.invoices.isEmpty
                      ? const Center(child: Text('مفيش فواتير', style: TextStyle(color: AppColors.textHint)))
                      : ListView.builder(
                          itemCount: state.invoices.length,
                          itemBuilder: (context, index) {
                            final inv = state.invoices[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 4),
                              child: ListTile(
                                title: Text(inv.invoiceNumber ?? 'فاتورة #${index + 1}', textDirection: TextDirection.rtl),
                                subtitle: Text(formatDate(inv.invoiceDate)),
                                trailing: Text(formatCurrency(inv.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
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
        onPressed: () => _showAddInvoiceDialog(context),
        backgroundColor: AppColors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.addInvoice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _amountController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: AppStrings.invoiceAmountHint)),
            TextField(controller: _invoiceNumberController, textDirection: TextDirection.rtl, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: AppStrings.invoiceNumberHint)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (amount > 0) {
                context.read<SuppliersBloc>().add(SuppliersAddInvoice(
                  supplierId: widget.supplierId,
                  amount: amount,
                  invoiceNumber: _invoiceNumberController.text.trim().isEmpty ? null : _invoiceNumberController.text.trim(),
                ));
                _amountController.clear();
                _invoiceNumberController.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
