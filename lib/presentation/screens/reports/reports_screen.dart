// lib/presentation/screens/reports/reports_screen.dart
// شاشة التقارير — صافي الربح + رسم بياني + أكثر المنتجات مبيعاً
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../blocs/reports/reports_bloc.dart';
import '../../blocs/reports/reports_event.dart';
import '../../blocs/reports/reports_state.dart';
import '../../widgets/debt_amount_text.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(ReportsLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.reportsTitle),
        backgroundColor: AppColors.infoBlue,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) return const LoadingWidget();

          if (state is ReportsLoaded) {
            if (!state.hasEnoughData) {
              return EmptyStateWidget(message: AppStrings.noDataYet, icon: Icons.bar_chart_outlined);
            }

            return RefreshIndicator(
              onRefresh: () async => context.read<ReportsBloc>().add(ReportsLoad()),
              color: AppColors.infoBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // صافي الربح
                      _buildNetProfitCard(state.netProfit),
                      const SizedBox(height: AppDimensions.paddingL),

                      // البطاقات الفرعية
                      Row(
                        children: [
                          Expanded(child: _buildSubCard(AppStrings.cashSales, state.cashSales, AppColors.successGreen, Icons.payments)),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(child: _buildSubCard(AppStrings.newDebts, state.newDebts, AppColors.debtRed, Icons.menu_book)),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(child: _buildSubCard(AppStrings.collectedPayments, state.collectedPayments, AppColors.primaryGreen, Icons.check_circle)),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // الرسم البياني
                      if (state.last7Days.isNotEmpty) ...[
                        const Text(
                          AppStrings.last7Days,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: AppDimensions.fontSubtitle, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        SizedBox(
                          height: 200,
                          child: _buildBarChart(state.last7Days),
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                      ],

                      // أكثر المنتجات مبيعاً
                      if (state.topProducts.isNotEmpty) ...[
                        const Text(
                          AppStrings.topProducts,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: AppDimensions.fontSubtitle, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        ...state.topProducts.map((p) => Card(
                          margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                          child: ListTile(
                            title: Text(p.productName, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${p.quantity} قطعة', textDirection: TextDirection.rtl),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatCurrency(p.revenue), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('أرباح: ${formatCurrency(p.profit)}', style: const TextStyle(fontSize: AppDimensions.fontCaption, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )),
                      ],

                      const SizedBox(height: AppDimensions.paddingL),
                      // ملاحظة المعادلة
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.infoBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: const Text(
                          AppStrings.profitFormulaNote,
                          style: TextStyle(fontSize: AppDimensions.fontCaption, color: AppColors.infoBlue),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is ReportsError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.debtRed)));
          }

          return const LoadingWidget();
        },
      ),
    );
  }

  Widget _buildNetProfitCard(double netProfit) {
    final isPositive = netProfit >= 0;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.successGreen : AppColors.debtRed).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: (isPositive ? AppColors.successGreen : AppColors.debtRed).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(AppStrings.netProfit, style: TextStyle(fontSize: AppDimensions.fontBody, color: isPositive ? AppColors.successGreen : AppColors.debtRed)),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            formatCurrency(netProfit),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.successGreen : AppColors.debtRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconMedium),
          const SizedBox(height: AppDimensions.paddingS),
          Text(title, style: TextStyle(fontSize: AppDimensions.fontCaption, color: color)),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(formatCurrency(amount), style: TextStyle(fontSize: AppDimensions.fontBody, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildBarChart(List days) {
    // ignore: unnecessary_cast
    final List<dynamic> daysList = days;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: daysList.isEmpty ? 100 : (daysList.map((d) => d.totalSales as double).reduce((a, b) => a > b ? a : b) * 1.2),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= daysList.length) return const Text('');
                final day = daysList[index].day as DateTime;
                return Text('${day.day}/${day.month}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: daysList.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.totalSales as double,
                color: AppColors.primaryGreen,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
