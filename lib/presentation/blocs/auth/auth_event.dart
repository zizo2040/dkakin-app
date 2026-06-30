// lib/presentation/blocs/auth/auth_event.dart
// أحداث المصادقة
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// فحص حالة الجلسة المحفوظة
class AuthCheckRequested extends AuthEvent {}

/// تسجيل الدخول — إدخال رقم الهاتف
class AuthPhoneSubmitted extends AuthEvent {
  final String phone;
  final String shopName;

  const AuthPhoneSubmitted({required this.phone, required this.shopName});

  @override
  List<Object?> get props => [phone, shopName];
}

/// التحقق من OTP
class AuthOtpSubmitted extends AuthEvent {
  final String otp;
  final String phone;
  final String shopName;

  const AuthOtpSubmitted({
    required this.otp,
    required this.phone,
    required this.shopName,
  });

  @override
  List<Object?> get props => [otp, phone, shopName];
}

/// تسجيل الخروج
class AuthLogoutRequested extends AuthEvent {}

/// تحديث بيانات الدكان
class AuthShopUpdated extends AuthEvent {
  final String newShopName;

  const AuthShopUpdated(this.newShopName);

  @override
  List<Object?> get props => [newShopName];
}
