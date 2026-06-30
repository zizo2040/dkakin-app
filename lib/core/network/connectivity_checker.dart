// lib/core/network/connectivity_checker.dart
// فحص الاتصال بالشبكة — اختياري، لا يمنع أي عملية
// التطبيق يعمل Offline-First دائماً
class ConnectivityChecker {
  /// التحقق ما إذا كان الجهاز متصلاً بالإنترنت
  /// هذا تنفيذ مبسط — TODO-PHASE2: استخدم connectivity_plus package
  Future<bool> isConnected() async {
    // للمرحلة الحالية نفترض دائماً Offline
    // في المرحلة السحابية: فحص فعلي عبر connectivity_plus أو lookup
    return false;
  }

  /// مراقبة تغير حالة الاتصال (للمزامنة التلقائية المستقبلية)
  Stream<bool> get onConnectivityChanged async* {
    // TODO-PHASE2: استبدل هذا بـ Connectivity().onConnectivityChanged
    yield false;
  }
}
