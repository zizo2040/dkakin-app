// lib/core/errors/app_exceptions.dart
// استثناءات مخصصة للتطبيق — تُستخدم داخل الطبقات الداخلية
// ويُحوّل كل استثناء إلى Result.failure في الحدود الخارجية
class AppException implements Exception {
  final String message;
  final String? code;
  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class DatabaseException extends AppException {
  DatabaseException(String message) : super(message, code: 'DB_EXCEPTION');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_EXCEPTION');
}

class TrialLimitExceeded implements Exception {
  final String limitName;
  final int current;
  final int max;
  TrialLimitExceeded(this.limitName, this.current, this.max);

  @override
  String toString() => 'TrialLimitExceeded: $limitName ($current/$max)';
}

class EncryptionException extends AppException {
  EncryptionException(String message) : super(message, code: 'ENCRYPTION_EXCEPTION');
}

class SyncException extends AppException {
  SyncException(String message) : super(message, code: 'SYNC_EXCEPTION');
}
