// lib/core/utils/result.dart
// نمط Result<Success, Failure> لمعالجة الأخطاء الموحدة
// بدلاً من رمي استثناءات متناثرة في كل مكان
import '../constants/trial_limits.dart';

/// فئة الأخطاء الموحدة
class AppFailure {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppFailure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';
}

/// أنواع الأخطاء الشائعة
class DatabaseFailure extends AppFailure {
  const DatabaseFailure({super.message = 'مشكلة في قاعدة البيانات', super.code = 'DB_ERROR'});
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.message, super.code = 'VALIDATION_ERROR'});
}

class TrialLimitFailure extends AppFailure {
  final LimitType limitType;
  const TrialLimitFailure({required this.limitType, super.code = 'TRIAL_LIMIT'})
      : super(message: 'وصلت للحد الأقصى');
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({super.message = 'مشكلة في الاتصال', super.code = 'NETWORK_ERROR'});
}

class SecurityFailure extends AppFailure {
  const SecurityFailure({super.message = 'مشكلة أمنية', super.code = 'SECURITY_ERROR'});
}

/// نمط Result بدون freezed — يعمل فوراً بدون توليد كود
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => isSuccess ? (this as Success<T>).data : null;
  AppFailure? get error => isFailure ? (this as Failure<T>).error : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure error) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      Failure<T>(error: final e) => failure(e),
      _ => throw StateError('Invalid Result state'),
    };
  }

  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(AppFailure error)? failure,
    required R Function() orElse,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success != null ? success(d) : orElse(),
      Failure<T>(error: final e) => failure != null ? failure(e) : orElse(),
      _ => orElse(),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppFailure error;
  const Failure(this.error);
}
