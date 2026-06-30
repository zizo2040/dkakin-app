// lib/core/utils/helpers.dart
// دوال مساعدة مشتركة — لا حالة (stateless)،纯 دالة
import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

/// تنسيق الأرقام كعملة
String formatCurrency(double amount) {
  final formatter = NumberFormat('#,##0.##', 'ar');
  return '${formatter.format(amount)} ${AppStrings.currencySymbol}';
}

/// تنسيق التاريخ بالعربية
String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy/MM/dd', 'ar');
  return formatter.format(date);
}

/// تنسيق التاريخ والوقت
String formatDateTime(DateTime date) {
  final formatter = DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
  return formatter.format(date);
}

/// اسم الشهر بالعربية
String getMonthName(DateTime date) {
  final formatter = DateFormat('MMMM', 'ar');
  return formatter.format(date);
}

/// تنسيق الرقم كيوم في الأسبوع
String getDayName(DateTime date) {
  final formatter = DateFormat('EEEE', 'ar');
  return formatter.format(date);
}

/// التحقق من صحة رقم التليفون (اليمن)
bool isValidPhone(String phone) {
  final clean = phone.replaceAll(RegExp(r'\D'), '');
  // رقم يمني: 9 أرقام بعد +967
  return clean.length >= 9;
}

/// تنظيف رقم التليفون
String cleanPhone(String phone) {
  return phone.replaceAll(RegExp(r'\D'), '');
}

/// تنسيق رقم الهاتف اليمني
String formatYemeniPhone(String phone) {
  final clean = cleanPhone(phone);
  if (clean.length == 9) {
    return '${AppStrings.userIdPrefix} ${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6)}';
  }
  return phone;
}

/// التحقق من أن النص ليس فارغاً
bool isNotEmpty(String? text) {
  return text != null && text.trim().isNotEmpty;
}

/// التحقق من أن السعر رقم موجب
bool isValidPrice(String price) {
  final value = double.tryParse(price);
  return value != null && value >= 0;
}

/// التحقق من أن الكمية رقم صحيح موجب
bool isValidQuantity(String qty) {
  final value = int.tryParse(qty);
  return value != null && value > 0;
}

/// حساب الفرق بين تاريخين بالأيام
int daysBetween(DateTime from, DateTime to) {
  return to.difference(from).inDays;
}

/// التحقق ما إذا كان المنتج على وشك الانتهاء (30 يوم)
bool isNearExpiry(DateTime? expiryDate) {
  if (expiryDate == null) return false;
  final daysLeft = daysBetween(DateTime.now(), expiryDate);
  return daysLeft <= 30 && daysLeft >= 0;
}

/// التحقق ما إذا كان المنتج منتهي الصلاحية
bool isExpired(DateTime? expiryDate) {
  if (expiryDate == null) return false;
  return expiryDate.isBefore(DateTime.now());
}

/// إنشاء رسالة كشف الدين
String buildDebtStatement({
  required String customerName,
  required String shopName,
  required List<Map<String, dynamic>> items,
  required double previousDebt,
  required double newDebt,
  required double total,
}) {
  final buffer = StringBuffer();
  buffer.writeln('${AppStrings.statementHeader} $customerName،');
  buffer.writeln('${AppStrings.statementShop} $shopName:');
  buffer.writeln();
  for (final item in items) {
    buffer.writeln('• ${item['name']}: ${formatCurrency(item['price'] as double)}');
  }
  buffer.writeln('—————————');
  buffer.writeln('${AppStrings.statementPrevDebt}: ${formatCurrency(previousDebt)}');
  buffer.writeln('${AppStrings.statementNewDebt}: ${formatCurrency(newDebt)}');
  buffer.writeln('${AppStrings.statementTotal}: ${formatCurrency(total)}');
  buffer.writeln(AppStrings.statementThanks);
  return buffer.toString();
}

/// بناء رابط واتساب
String buildWhatsappUrl(String phone, String message) {
  final clean = cleanPhone(phone);
  final encoded = Uri.encodeComponent(message);
  return 'https://wa.me/$clean?text=$encoded';
}

/// بناء رابط SMS
String buildSmsUrl(String phone, String message) {
  final clean = cleanPhone(phone);
  final encoded = Uri.encodeComponent(message);
  return 'sms:$clean?body=$encoded';
}

/// تقييد القيمة بين حد أدنى وحد أقصى
T clamp<T extends num>(T value, T min, T max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
