// lib/core/sync/no_op_sync_service.dart
// تنفيذ وهمي للمزامنة — المرحلة الأولى (Offline فقط)
// لا يفعل شيئاً حقيقياً، فقط يُرجع حالة "غير متصل"
// TODO-PHASE2: استبدل هذا بـ FirebaseSyncService
import 'i_sync_service.dart';

class NoOpSyncService implements ISyncService {
  @override
  Future<SyncResult> pushPendingChanges() async {
    return SyncResult(
      success: true,
      message: 'وضع عدم الاتصال — البيانات محلية',
      itemsSynced: 0,
    );
  }

  @override
  Future<SyncResult> pullRemoteUpdates() async {
    return SyncResult(
      success: true,
      message: 'وضع عدم الاتصال — لا يوجد تحديثات',
      itemsSynced: 0,
    );
  }

  @override
  Future<SyncStatus> getLastSyncStatus() async {
    return SyncStatus.empty();
  }

  @override
  Future<SyncResult> backupNow() async {
    // النسخ المحلي يُدار من LocalBackupService
    return SyncResult(
      success: true,
      message: 'تم النسخ المحلي — المزامنة السحابية ستُفعّل قريباً',
      itemsSynced: 0,
    );
  }

  @override
  Future<SyncResult> restoreFromBackup() async {
    return SyncResult(
      success: false,
      message: 'هذه الميزة ستُفعّل عند ربط حساب قوقل درايف',
      itemsSynced: 0,
    );
  }
}
