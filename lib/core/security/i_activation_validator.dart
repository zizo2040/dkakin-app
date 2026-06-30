// lib/core/security/i_activation_validator.dart
// واجهة التحقق من التفعيل — كل الشاشات تتعامل مع هذه الواجهة فقط
// عبر get_it، لا تستورد أي تنفيذ مباشرة
// استبدال التنفيذ = ملف جديد + سطر واحد في injection.dart
import '../constants/trial_limits.dart';

/// حالة التفعيل الحالية
enum ActivationStatus {
  trialActive, // فترة تجريبية نشطة
  trialExpired, // انتهت الفترة التجريبية
  activated, // مفعل بالكامل
  blocked, // محظور
}

/// نتيجة التحقق من صلاحية كود التفعيل
class ActivationResult {
  final bool isValid;
  final String? message;
  final ActivationStatus? newStatus;

  const ActivationResult({
    required this.isValid,
    this.message,
    this.newStatus,
  });
}

/// واجهة التحقق من التفعيل — التطبيق كله يعتمد عليها
abstract class IActivationValidator {
  /// التحقق من حالة التفعيل الحالية
  Future<ActivationStatus> checkStatus();

  /// التحقق من صلاحية كود التفعيل
  Future<ActivationResult> validateCode(String code);

  /// تسجيل عملية استخدام (لتتبع حدود الفترة التجريبية)
  Future<void> recordUsage(UsageType type);

  /// الحصول على العدد الحالي لنوع استخدام معين
  Future<int> getCurrentUsage(UsageType type);

  /// التحقق ما إذا كان نوع الاستخدام مسموحاً به
  Future<bool> canPerform(UsageType type);

  /// الحصول على المتبقي من نوع محدد
  Future<int> getRemaining(UsageType type);

  /// تفعيل الكود (يحفظ حالة التفعيل محلياً)
  Future<void> activate(String code);

  /// التحقق ما إذا كان التطبيق مفعلاً بالكامل
  Future<bool> isFullyActivated();

  /// الحصول على معرف الجهاز/المستخدم (UUID v4)
  Future<String> getDeviceId();
}
