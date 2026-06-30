// lib/presentation/widgets/error_snackbar.dart
// SnackBar خطأ موحد — يُستخدم عبر showErrorSnackBar(context, message)
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.white),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppDimensions.fontBody,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.debtRed,
      duration: Duration(seconds: AppDimensions.snackBarDuration),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
    ),
  );
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.white),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: AppDimensions.fontBody,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.successGreen,
duration: Duration(seconds: AppDimensions.snackBarDuration),      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
    ),
  );
}
