// lib/core/constants/app_dimensions.dart
// أحجام الخط والمسافات الموحدة — استخدم هذه القيم لضمان اتساق التصميم
import 'package:flutter/material.dart';

abstract class AppDimensions {
  // أحجام الخطوط
  static const double fontTitle = 26;
  static const double fontSubtitle = 22;
  static const double fontBody = 18;
  static const double fontSmall = 16;
  static const double fontCaption = 14;
  static const double fontGrandTotal = 32;
  static const double fontDebtTotal = 28;

  // أحجام الأيقونات
  static const double iconSmall = 24;
  static const double iconMedium = 32;
  static const double iconLarge = 48;
  static const double iconButton = 36;

  // المسافات
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 16;
  static const double paddingL = 24;
  static const double paddingXL = 32;

  // حواف الدائرية
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;

  // ارتفاعات
  static const double buttonHeight = 56;
  static const double appBarHeight = 64;
  static const double bottomNavHeight = 72;
  static const double cardHeight = 80;

  // أبعاد الأزرار الرئيسية في Home
  static const double homeButtonSize = 140;

  // أقصى عرض للمحتوى (للتابلت)
  static const double maxContentWidth = 600;

  // مدة الانتقالات
  static const Duration transitionFast = Duration(milliseconds: 200);
  static const Duration transitionNormal = Duration(milliseconds: 350);
  static const Duration transitionSlow = Duration(milliseconds: 500);

  // مدة ظهور SnackBar
  static const Duration snackBarDuration = Duration(seconds: 3);

  // مدة السماح بالتراجع
  static const int undoSeconds = 60;
}
