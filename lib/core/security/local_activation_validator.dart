// lib/core/security/local_activation_validator.dart
// التنفيذ المحلي للتحقق من التفعيل — المرحلة الأولى (Offline)
// قابل للاستبدال لاحقاً بـ RemoteActivationValidator بدون تغيير أي شاشة
// المفتاح السري مضمن — هذا مقبول للمرحلة المحلية فقط
// TODO-PRODUCTION: غيّر SALT قبل الإطلاق الفعلي، واستخدم Firebase Functions للتحقق
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'i_activation_validator.dart';
import '../constants/trial_limits.dart';
import 'encryption_service.dart';

class LocalActivationValidator implements IActivationValidator {
  static const String _keyDeviceId = 'device_id';
  static const String _keyActivated = 'is_activated';
  static const String _keyActivationCode = 'activation_code';
  static const String _prefixUsage = 'usage_';

  // مفتاح HMAC مدمج — يجب تغييره قبل الإنتاج (هذا للعرض فقط)
  // TODO-PRODUCTION: استخدم تقسيم/دمج للمفتاح أو احفظه في Keystore/Keychain
  static final List<int> _hmacKey = _deriveKey('dkakin_secret_key_2024_v1');

  final SharedPreferences _prefs;
  final EncryptionService _encryption;

  LocalActivationValidator(this._prefs, this._encryption);

  static List<int> _deriveKey(String password) {
    final salt = 'dkakin_salt_yemen_egypt_2024'; // TODO-PRODUCTION: غيّر هذا الملح!
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).bytes;
  }

  @override
  Future<ActivationStatus> checkStatus() async {
    final isActivated = _prefs.getBool(_keyActivated) ?? false;
    if (isActivated) return ActivationStatus.activated;

    // التحقق من انتهاء الفترة التجريبية (14 يوم)
    final createdAt = _prefs.getString('user_created_at');
    if (createdAt != null) {
      final created = DateTime.parse(createdAt);
      final daysPassed = DateTime.now().difference(created).inDays;
      if (daysPassed > TrialLimits.trialDays) {
        return ActivationStatus.trialExpired;
      }
    }

    return ActivationStatus.trialActive;
  }

  @override
  Future<ActivationResult> validateCode(String code) async {
    try {
      final cleanCode = code.replaceAll('-', '').trim().toUpperCase();
      if (cleanCode.length != 12) {
        return const ActivationResult(
          isValid: false,
          message: 'الكود لازم يكون 12 رقم/حرف',
        );
      }

      // التحقق من توقيع HMAC محلياً
      final deviceId = await getDeviceId();
      final shortDeviceId = deviceId.substring(0, 8);

      // البنية المتوقعة: Base32(HMAC-SHA256(shortDeviceId + codePrefix))
      // هذا تنفيذ مبسط — في الإنتاج استخدم سيرفر Firebase
      final expectedSignature = _computeSignature(shortDeviceId, cleanCode.substring(0, 6));
      final providedSignature = cleanCode.substring(6);

      // مقارنة آمنة ضد هجمات Timing
      if (_secureCompare(expectedSignature, providedSignature)) {
        return const ActivationResult(
          isValid: true,
          message: 'تم التحقق بنجاح',
          newStatus: ActivationStatus.activated,
        );
      }

      // أيضاً تحقق من "كود عالمي" للدعم الفني
      if (_isUniversalSupportCode(cleanCode)) {
        return const ActivationResult(
          isValid: true,
          message: 'كود دعم فني مقبول',
          newStatus: ActivationStatus.activated,
        );
      }

      return const ActivationResult(
        isValid: false,
        message: 'الكود غير صحيح',
      );
    } catch (e) {
      return ActivationResult(
        isValid: false,
        message: 'مشكلة في التحقق: $e',
      );
    }
  }

  String _computeSignature(String deviceId, String prefix) {
    final data = utf8.encode(deviceId + prefix);
    final hmac = Hmac(sha256, _hmacKey);
    final digest = hmac.convert(data);
    return digest.toString().substring(0, 6).toUpperCase();
  }

  bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  bool _isUniversalSupportCode(String code) {
    // كود دعم فني مؤقت للاختبار
    // TODO-PRODUCTION: احذف هذا في الإصدار النهائي أو استبدله بمنطق أكثر أماناً
    return code == 'DKKN-SUPPORT-2024';
  }

  @override
  Future<void> recordUsage(UsageType type) async {
    final key = '$_prefixUsage${type.name}';
    final encrypted = _prefs.getString(key);
    int current = 0;
    if (encrypted != null) {
      try {
        final decrypted = await _encryption.decrypt(encrypted);
        current = int.tryParse(decrypted) ?? 0;
      } catch (_) {
        current = 0;
      }
    }
    current++;
    final newEncrypted = await _encryption.encrypt(current.toString());
    await _prefs.setString(key, newEncrypted);
  }

  @override
  Future<int> getCurrentUsage(UsageType type) async {
    final key = '$_prefixUsage${type.name}';
    final encrypted = _prefs.getString(key);
    if (encrypted == null) return 0;
    try {
      final decrypted = await _encryption.decrypt(encrypted);
      return int.tryParse(decrypted) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> canPerform(UsageType type) async {
    final isActivated = await isFullyActivated();
    if (isActivated) return true;

    final current = await getCurrentUsage(type);
    final max = _getMaxForType(type);
    return current < max;
  }

  @override
  Future<int> getRemaining(UsageType type) async {
    final isActivated = await isFullyActivated();
    if (isActivated) return 999999;

    final current = await getCurrentUsage(type);
    final max = _getMaxForType(type);
    final remaining = max - current;
    return remaining > 0 ? remaining : 0;
  }

  int _getMaxForType(UsageType type) {
    switch (type) {
      case UsageType.customer:
        return TrialLimits.maxCustomers;
      case UsageType.product:
        return TrialLimits.maxProducts;
      case UsageType.supplier:
        return TrialLimits.maxSuppliers;
      case UsageType.sale:
        return TrialLimits.maxSales;
      case UsageType.message:
        return TrialLimits.maxMessages;
    }
  }

  @override
  Future<void> activate(String code) async {
    final result = await validateCode(code);
    if (!result.isValid) {
      throw Exception(result.message ?? 'كود غير صحيح');
    }
    await _prefs.setBool(_keyActivated, true);
    await _prefs.setString(_keyActivationCode, code);
  }

  @override
  Future<bool> isFullyActivated() async {
    return _prefs.getBool(_keyActivated) ?? false;
  }

  @override
  Future<String> getDeviceId() async {
    var id = _prefs.getString(_keyDeviceId);
    if (id == null) {
      // إنشاء UUID v4 جديد — متوافق مع Firebase
      id = const Uuid().v4();
      await _prefs.setString(_keyDeviceId, id);
    }
    return id;
  }
}
