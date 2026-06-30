// lib/presentation/widgets/big_action_button.dart
// زر Action ضخم — للصفحة الرئيسية
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class BigActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final String? tooltip;
  final String? semanticsLabel;

  const BigActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryGreen,
    this.textColor = AppColors.white,
    this.tooltip,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? label,
      child: Tooltip(
        message: tooltip ?? label,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            minimumSize: const Size(AppDimensions.homeButtonSize, AppDimensions.homeButtonSize),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            elevation: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppDimensions.iconLarge),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppDimensions.fontBody,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
