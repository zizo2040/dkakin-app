// lib/core/sync/i_sync_service.dart
// واجهة المزامنة — التطبيق يتعامل معها فقط، لا يعرف التنفيذ
// عند الربط بـ Firebase لاحقاً: أنشئ FirebaseSyncService implements ISyncService
// وغيّر السطر في injection.dart فقط
abstract class ISyncService {
  /// دفع التغييرات المعلقة للسيرفر
  Future<SyncResult> pushPendingChanges();

  /// سحب التحديثات من السيرفر
  Future<SyncResult> pullRemoteUpdates();

  /// الحصول على حالة آخر مزامنة
  Future<SyncStatus> getLastSyncStatus();

  /// نسخ احتياطي يدوي
  Future<SyncResult> backupNow();

  /// استعادة من النسخ الاحتياطي
  Future<SyncResult> restoreFromBackup();
}

/// حالة المزامنة
class SyncStatus {
  final bool isSynced;
  final DateTime? lastSyncAt;
  final int pendingCount;
  final String? lastError;

  SyncStatus({
    required this.isSynced,
    this.lastSyncAt,
    this.pendingCount = 0,
    this.lastError,
  });

  SyncStatus.empty()
      : isSynced = false,
        lastSyncAt = null,
        pendingCount = 0,
        lastError = null;
}

/// نتيجة عملية المزامنة
class SyncResult {
  final bool success;
  final String message;
  final int? itemsSynced;

  SyncResult({
    required this.success,
    required this.message,
    this.itemsSynced,
  });
}
