// lib/presentation/screens/suppliers/suppliers_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';
import 'supplier_detail_screen.dart';

class SuppliersListScreen extends StatefulWidget {
  const SuppliersListScreen({super.key});

  @override
  State<SuppliersListScreen> createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SuppliersBloc>().add(SuppliersLoad());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.suppliersTitle),
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
          if (state is SuppliersLoaded) {
            if (state.isEmpty) {
              return EmptyStateWidget(
                message: AppStrings.noSuppliers,
                icon: Icons.local_shipping_outlined,
                onAction: () => _showAddDialog(context),
                actionLabel: AppStrings.addSupplier,
              );
            }
            return ListView.builder(
              itemCount: state.suppliers.length,
              itemBuilder: (context, index) {
                final s = state.suppliers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 4),
                  child: ListTile(
                    title: Text(s.name, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: s.phone != null ? Text(s.phone!, textDirection: TextDirection.ltr) : null,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplierId: s.id)),
                    ),
                  ),
                );
              },
            );
          }
          return const LoadingWidget();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.brown,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.addSupplier),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, textDirection: TextDirection.rtl, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: AppStrings.supplierNameHint)),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: AppStrings.supplierPhoneHint)),
            TextField(controller: _notesController, textDirection: TextDirection.rtl, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: AppStrings.supplierNotesHint)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                context.read<SuppliersBloc>().add(SuppliersAdd(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                ));
                _nameController.clear();
                _phoneController.clear();
                _notesController.clear();
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
