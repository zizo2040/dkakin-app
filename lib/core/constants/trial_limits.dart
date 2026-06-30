// lib/core/constants/trial_limits.dart
// حدود الفترة التجريبية — تُخزَّن مشفرة وتُتحقق من قبل IActivationValidator
abstract class TrialLimits {
  static const int maxCustomers = 5;
  static const int maxProducts = 10;
  static const int maxSuppliers = 5;
  static const int maxSales = 30;
  static const int maxMessages = 10;

  // مدة الفترة التجريبية بالأيام
  static const int trialDays = 14;
}

// أنواع الاستخدام التي يتم تتبعها
enum UsageType {
  customer,
  product,
  supplier,
  sale,
  message,
}

// أنواع الحدود لعرض رسائل التنبيه
enum LimitType {
  customers,
  products,
  suppliers,
  sales,
  messages,
}

extension LimitTypeExtension on LimitType {
  String get displayName {
    switch (this) {
      case LimitType.customers:
        return 'الزباين';
      case LimitType.products:
        return 'المنتجات';
      case LimitType.suppliers:
        return 'الموردين';
      case LimitType.sales:
        return 'عمليات البيع';
      case LimitType.messages:
        return 'الرسائل';
    }
  }

  int get maxValue {
    switch (this) {
      case LimitType.customers:
        return TrialLimits.maxCustomers;
      case LimitType.products:
        return TrialLimits.maxProducts;
      case LimitType.suppliers:
        return TrialLimits.maxSuppliers;
      case LimitType.sales:
        return TrialLimits.maxSales;
      case LimitType.messages:
        return TrialLimits.maxMessages;
    }
  }
}
