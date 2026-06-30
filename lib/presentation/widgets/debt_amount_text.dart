// lib/presentation/widgets/debt_amount_text.dart
// نص مبلغ الدين — أحمر إذا > 0، رمادي إذا = 0
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/helpers.dart';

class DebtAmountText extends StatelessWidget {
  final double amount;
  final double fontSize;
  final FontWeight fontWeight;

  const DebtAmountText({
    super.key,
    required this.amount,
    this.fontSize = AppDimensions.fontBody,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    final color = amount > 0 ? AppColors.debtRed : AppColors.textSecondary;
    return Text(
      formatCurrency(amount),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

/// نص المجموع الكلي بخط ضخم ملون
class GrandTotalText extends StatelessWidget {
  final double amount;

  const GrandTotalText({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCurrency(amount),
      style: const TextStyle(
        fontSize: AppDimensions.fontGrandTotal,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
