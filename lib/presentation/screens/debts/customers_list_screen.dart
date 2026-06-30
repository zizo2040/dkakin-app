// lib/presentation/screens/debts/customers_list_screen.dart
// قائمة الزبائن — مرتبة بالأكثر ديناً
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../widgets/debt_amount_text.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';
import 'customer_detail_screen.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(CustomersLoad());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.debtsTitle),
        backgroundColor: AppColors.debtRed,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<CustomersBloc, CustomersState>(
        listener: (context, state) {
          if (state is CustomersError) {
            showErrorSnackBar(context, state.message);
          } else if (state is CustomersSuccess) {
            showSuccessSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CustomersLoading) {
            return const LoadingWidget();
          }

          if (state is CustomersLoaded) {
            if (state.isEmpty) {
              return EmptyStateWidget(
                message: AppStrings.noCustomers,
                icon: Icons.people_outline,
                onAction: () => _showAddCustomerDialog(context),
                actionLabel: AppStrings.addCustomer,
              );
            }

            return Column(
              children: [
                // شريط البحث
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      context.read<CustomersBloc>().add(CustomersSearch(value));
                    },
                    decoration: InputDecoration(
                      hintText: AppStrings.search,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                  ),
                ),
                // خيارات الفرز
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: Row(
                    children: [
                      _SortChip(
                        label: AppStrings.sortByDebt,
                        isSelected: state.sortType == SortType.byDebt,
                        onTap: () => context.read<CustomersBloc>().add(const CustomersSort(SortType.byDebt)),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      _SortChip(
                        label: AppStrings.sortByRecent,
                        isSelected: state.sortType == SortType.byRecent,
                        onTap: () => context.read<CustomersBloc>().add(const CustomersSort(SortType.byRecent)),
                      ),
                      const SizedBox(width: AppDimensions.paddingS),
                      _SortChip(
                        label: AppStrings.sortByName,
                        isSelected: state.sortType == SortType.byName,
                        onTap: () => context.read<CustomersBloc>().add(const CustomersSort(SortType.byName)),
                      ),
                    ],
                  ),
                ),
                // القائمة
                Expanded(
                  child: ListView.builder(
                    itemCount: state.displayList.length,
                    itemBuilder: (context, index) {
                      final customer = state.displayList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingXS,
                        ),
                        child: ListTile(
                          title: Text(
                            customer.name,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: customer.phone != null
                              ? Text(customer.phone!, textDirection: TextDirection.ltr)
                              : null,
                          trailing: DebtAmountText(
                            amount: customer.totalDebt,
                            fontSize: AppDimensions.fontSubtitle,
                            fontWeight: FontWeight.bold,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerDetailScreen(customerId: customer.id),
                            ),
                          ),
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
        onPressed: () => _showAddCustomerDialog(context),
        backgroundColor: AppColors.debtRed,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.addCustomer),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: AppStrings.customerNameHint),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(labelText: AppStrings.customerPhoneHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                context.read<CustomersBloc>().add(CustomersAdd(
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                ));
                _nameController.clear();
                _phoneController.clear();
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

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.debtRed.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.debtRed : AppColors.textSecondary,
      ),
    );
  }
}
