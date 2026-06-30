// lib/presentation/screens/home/home_screen.dart
// الشاشة الرئيسية — بطاقات + أزرار + ملخص اليوم
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/big_action_button.dart';
import '../../widgets/debt_amount_text.dart';
import '../debts/customers_list_screen.dart';
import '../pos/pos_screen.dart';
import '../products/products_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _todaySales = 0;
  double _totalDebts = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final saleRepo = context.read<SaleRepository>();
      final reportRepo = context.read<ReportRepository>();
      final sales = await saleRepo.getTodayTotal();
      final debts = await reportRepo.getTotalOutstandingDebts();
      if (mounted) {
        setState(() {
          _todaySales = sales;
          _totalDebts = debts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final shopName = state is AuthAuthenticated ? state.shopName : '';
          final now = DateTime.now();

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الشريط العلوي
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            ),
                            icon: const Icon(Icons.settings, color: AppColors.brown),
                            tooltip: AppStrings.btnSettings,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${AppStrings.homeTitle} $shopName',
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSubtitle,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                '${getDayName(now)}، ${now.day} ${getMonthName(now)} ${now.year}',
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSmall,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingL),

                      // بطاقات الملخص
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                          : Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    title: AppStrings.todaySales,
                                    amount: _todaySales,
                                    color: AppColors.primaryGreen,
                                    icon: Icons.trending_up,
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.paddingM),
                                Expanded(
                                  child: _SummaryCard(
                                    title: AppStrings.totalDebts,
                                    amount: _totalDebts,
                                    color: AppColors.debtRed,
                                    icon: Icons.account_balance_wallet_outlined,
                                  ),
                                ),
                              ],
                            ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // رسالة ترحيبية في اليوم الأول
                      if (!_isLoading && _todaySales == 0) ...[
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.infoBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.waving_hand, color: AppColors.infoBlue, size: 32),
                              SizedBox(width: AppDimensions.paddingM),
                              Expanded(
                                child: Text(
                                  AppStrings.welcomeFirstDay,
                                  style: TextStyle(
                                    fontSize: AppDimensions.fontBody,
                                    color: AppColors.infoBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                      ],

                      // الأزرار الأربعة
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: AppDimensions.paddingM,
                        crossAxisSpacing: AppDimensions.paddingM,
                        children: [
                          BigActionButton(
                            label: AppStrings.btnNewSale,
                            icon: Icons.shopping_cart_outlined,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PosScreen()),
                            ),
                            backgroundColor: AppColors.primaryGreen,
                            tooltip: AppStrings.a11ySalesIcon,
                          ),
                          BigActionButton(
                            label: AppStrings.btnDebtBook,
                            icon: Icons.menu_book_outlined,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomersListScreen()),
                            ),
                            backgroundColor: AppColors.debtRed,
                            tooltip: AppStrings.a11yDebtIcon,
                          ),
                          BigActionButton(
                            label: AppStrings.btnReports,
                            icon: Icons.bar_chart_outlined,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReportsScreen()),
                            ),
                            backgroundColor: AppColors.infoBlue,
                            tooltip: AppStrings.a11yReportIcon,
                          ),
                          BigActionButton(
                            label: AppStrings.btnSettings,
                            icon: Icons.settings_outlined,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            ),
                            backgroundColor: AppColors.brown,
                            tooltip: AppStrings.a11ySettingsIcon,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // وضع الزحمة
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PosScreen(rushMode: true)),
                        ),
                        icon: const Icon(Icons.bolt, size: AppDimensions.iconMedium),
                        label: const Text(
                          AppStrings.btnRushMode,
                          style: TextStyle(fontSize: AppDimensions.fontSubtitle),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warningOrange,
                          foregroundColor: AppColors.white,
                          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// بطاقة ملخص
class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: AppDimensions.iconMedium),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppDimensions.fontSmall,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingS),
          DebtAmountText(
            amount: amount,
            fontSize: AppDimensions.fontSubtitle,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
