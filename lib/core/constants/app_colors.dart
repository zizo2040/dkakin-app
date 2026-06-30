// lib/core/constants/app_colors.dart
// تعريف الألوان الموحدة للتطبيق — استخدم هذه القيم فقط، لا أي Hardcoded Colors
import 'package:flutter/material.dart';

abstract class AppColors {
  // الألوان الأساسية
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  // ألوان دافئة ثانوية
  static const Color brown = Color(0xFF6D4C41);
  static const Color brownLight = Color(0xFF8D6E63);
  static const Color brownDark = Color(0xFF4E342E);

  // خلفية كريمية
  static const Color creamBackground = Color(0xFFFFF8E1);
  static const Color creamCard = Color(0xFFFFECB3);

  // ألوان الحالة
  static const Color debtRed = Color(0xFFD32F2F);
  static const Color debtRedLight = Color(0xFFFFEBEE);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color infoBlue = Color(0xFF1976D2);

  // ألوان محايدة
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ألوان مخصصة للوضع الليلي (مستقبلي)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
}
