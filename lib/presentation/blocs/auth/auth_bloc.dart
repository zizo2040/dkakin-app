// lib/presentation/blocs/auth/auth_bloc.dart
// Bloc المصادقة — يتعامل مع التسجيل/الدخول والـ OTP
// TODO-PHASE2: استبدل OTP الوهمي بـ Firebase Phone Auth
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/local/database_helper.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences _prefs;
  final DatabaseHelper _db;

  static const String _keyUserId = 'user_id';
  static const String _keyPhone = 'user_phone';
  static const String _keyShopName = 'shop_name';
  static const String _keyCreatedAt = 'user_created_at';

  AuthBloc({
    required SharedPreferences prefs,
    required DatabaseHelper db,
  })  : _prefs = prefs,
        _db = db,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthShopUpdated>(_onShopUpdated);
  }

  /// فحص الجلسة المحفوظة
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userId = _prefs.getString(_keyUserId);
      final phone = _prefs.getString(_keyPhone);
      final shopName = _prefs.getString(_keyShopName);

      if (userId != null && phone != null && shopName != null) {
        emit(AuthAuthenticated(userId: userId, phone: phone, shopName: shopName));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthError(AppStrings.genericError));
    }
  }

  /// إرسال رقم الهاتف — الانتقال لشاشة OTP
  Future<void> _onPhoneSubmitted(
    AuthPhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO-PHASE2: هنا نرسل OTP حقيقي عبر Firebase
      // الآن ننتقل مباشرة لشاشة OTP
      emit(AuthOtpSent(phone: event.phone, shopName: event.shopName));
    } catch (e) {
      emit(const AuthError(AppStrings.genericError));
    }
  }

  /// التحقق من OTP
  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // OTP وهمي: 000000 مقبول دائماً
      // TODO-PHASE2: تحقق حقيقي من Firebase
      if (event.otp == '000000') {
        // إنشاء UUID v4 للمستخدم — متوافق مع Firebase
        final userId = const Uuid().v4();
        final now = DateTime.now().toIso8601String();

        // حفظ محلياً
        await _prefs.setString(_keyUserId, userId);
        await _prefs.setString(_keyPhone, event.phone);
        await _prefs.setString(_keyShopName, event.shopName);
        await _prefs.setString(_keyCreatedAt, now);

        // إدراج في قاعدة البيانات
        await _db.insert('users', {
          'id': userId,
          'phone': event.phone,
          'shop_name': event.shopName,
          'created_at': now,
          'sync_status': 'pending',
          'last_synced_at': null,
        });

        emit(AuthAuthenticated(
          userId: userId,
          phone: event.phone,
          shopName: event.shopName,
        ));
      } else {
        emit(const AuthError(AppStrings.invalidOtp));
      }
    } catch (e) {
      emit(const AuthError(AppStrings.genericError));
    }
  }

  /// تسجيل الخروج
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _prefs.remove(_keyUserId);
      await _prefs.remove(_keyPhone);
      await _prefs.remove(_keyShopName);
      await _prefs.remove(_keyCreatedAt);
      // لا نحذف قاعدة البيانات — تبقى للاستخدام اللاحق
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError(AppStrings.genericError));
    }
  }

  /// تحديث اسم الدكان
  Future<void> _onShopUpdated(
    AuthShopUpdated event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _prefs.setString(_keyShopName, event.newShopName);
      if (state is AuthAuthenticated) {
        final current = state as AuthAuthenticated;
        emit(AuthAuthenticated(
          userId: current.userId,
          phone: current.phone,
          shopName: event.newShopName,
        ));
      }
    } catch (e) {
      emit(const AuthError(AppStrings.genericError));
    }
  }
}
