// lib/presentation/blocs/auth/auth_state.dart
// حالات المصادقة — أربع حالات صريحة: initial, loading, authenticated, unauthenticated
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class AuthInitial extends AuthState {}

/// جاري التحميل
class AuthLoading extends AuthState {}

/// OTP مرسل — في انتظار الإدخال
class AuthOtpSent extends AuthState {
  final String phone;
  final String shopName;

  const AuthOtpSent({required this.phone, required this.shopName});

  @override
  List<Object?> get props => [phone, shopName];
}

/// مصدق — المستخدم مسجل الدخول
class AuthAuthenticated extends AuthState {
  final String userId;
  final String phone;
  final String shopName;

  const AuthAuthenticated({
    required this.userId,
    required this.phone,
    required this.shopName,
  });

  @override
  List<Object?> get props => [userId, phone, shopName];
}

/// غير مصدق — يحتاج تسجيل دخول
class AuthUnauthenticated extends AuthState {}

/// خطأ
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
