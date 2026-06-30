// lib/presentation/screens/debts/customer_detail_screen.dart
// تفاصيل الزبون — سجل العمليات + سداد + تراجع + إرسال كشف
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/debt_transaction.dart';
import '../../blocs/customers/customers_bloc.dart';
import '../../blocs/customers/customers_event.dart';
import '../../blocs/customers/customers_state.dart';
import '../../widgets/debt_amount_text.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _paymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(CustomersLoadDetail(widget.customerId));
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.customerDetailTitle),
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

          if (state is CustomerDetailLoaded) {
            final customer = state.customer;
            return Column(
              children: [
                // بطاقة الزبون
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  color: AppColors.debtRed.withOpacity(0.1),
                  child: Column(
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSubtitle,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      if (customer.phone != null)
                        Text(
                          customer.phone!,
                          style: const TextStyle(color: AppColors.textSecondary),
                          textDirection: TextDirection.ltr,
                        ),
                      const SizedBox(height: AppDimensions.paddingM),
                      const Text(
                        AppStrings.totalDebt,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      DebtAmountText(
                        amount: customer.totalDebt,
                        fontSize: AppDimensions.fontDebtTotal,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),

                // أزرار العمليات
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Row(
                    children: [
                      // تراجع
                      if (state.canUndo)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<CustomersBloc>().add(
                                CustomersUndoLast(widget.customerId),
                              );
                            },
                            icon: const Icon(Icons.undo),
                            label: Text(
                              '${AppStrings.undoLast} (${state.undoSecondsRemaining}s)',
                              style: const TextStyle(fontSize: AppDimensions.fontSmall),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warningOrange,
                              foregroundColor: AppColors.white,
                            ),
                          ),
                        ),
                      if (state.canUndo) const SizedBox(width: AppDimensions.paddingS),
                      // سداد
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: customer.totalDebt <= 0
                              ? null
                              : () => _showPaymentDialog(context, customer.totalDebt),
                          icon: const Icon(Icons.check_circle),
                          label: const Text(AppStrings.recordPayment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // عنوان السجل
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        AppStrings.debtHistory,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSubtitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // سجل العمليات
                Expanded(
                  child: state.transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'مفيش عمليات مسجّلة',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = state.transactions[index];
                            return _TransactionTile(transaction: tx);
                          },
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

  void _showPaymentDialog(BuildContext context, double maxAmount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.recordPayment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${AppStrings.totalDebt}: ${formatCurrency(maxAmount)}'),
            const SizedBox(height: AppDimensions.paddingM),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: AppStrings.paymentAmountHint,
                border: OutlineInputBorder(),
              ),
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
              final amount = double.tryParse(_paymentController.text) ?? 0;
              if (amount <= 0) {
                showErrorSnackBar(context, 'أدخل مبلغ صحيح');
                return;
              }
              if (amount > maxAmount) {
                showErrorSnackBar(context, AppStrings.paymentExceedsDebt);
                return;
              }
              context.read<CustomersBloc>().add(CustomersRecordPayment(
                customerId: widget.customerId,
                amount: amount,
              ));
              _paymentController.clear();
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final DebtTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDebt = transaction.transactionType == DebtType.debt;
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingXS,
      ),
      child: ListTile(
        leading: Icon(
          isDebt ? Icons.arrow_upward : Icons.arrow_downward,
          color: isDebt ? AppColors.debtRed : AppColors.successGreen,
        ),
        title: Text(
          isDebt ? AppStrings.transactionDebt : AppStrings.transactionPayment,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: isDebt ? AppColors.debtRed : AppColors.successGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatDateTime(transaction.transactionDate)),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(transaction.notes!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        trailing: Text(
          '${isDebt ? '+' : '-'} ${formatCurrency(transaction.amount)}',
          style: TextStyle(
            fontSize: AppDimensions.fontSubtitle,
            fontWeight: FontWeight.bold,
            color: isDebt ? AppColors.debtRed : AppColors.successGreen,
          ),
        ),
      ),
    );
  }
}
