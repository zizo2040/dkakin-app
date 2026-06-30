// lib/presentation/blocs/activation/activation_cubit.dart
// Cubit بسيط لإدارة التفعيل — لا أحداث معقدة، فقط Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/trial_limits.dart';
import '../../../core/security/i_activation_validator.dart';
import 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  final IActivationValidator _validator;

  ActivationCubit({required IActivationValidator validator})
      : _validator = validator,
        super(ActivationInitial());

  /// تحميل حالة التفعيل مع العدادات
  Future<void> loadStatus() async {
    emit(ActivationLoading());
    try {
      final status = await _validator.checkStatus();
      final isActivated = await _validator.isFullyActivated();

      final remaining = <String, int>{};
      for (final type in UsageType.values) {
        remaining[type.name] = await _validator.getRemaining(type);
      }

      emit(ActivationStatusLoaded(
        status: status,
        remaining: remaining,
        isFullyActivated: isActivated,
      ));
    } catch (e) {
      emit(ActivationError('${AppStrings.genericError}: $e'));
    }
  }

  /// تفعيل كود
  Future<void> activate(String code) async {
    emit(ActivationLoading());
    try {
      final result = await _validator.validateCode(code);
      if (result.isValid) {
        await _validator.activate(code);
        emit(const ActivationSuccess(AppStrings.activationSuccess));
        await loadStatus();
      } else {
        emit(ActivationError(result.message ?? AppStrings.invalidCode));
        await loadStatus();
      }
    } catch (e) {
      emit(ActivationError(e.toString()));
    }
  }

  /// التحقق من صلاحية كود (بدون تفعيل)
  Future<bool> validateOnly(String code) async {
    try {
      final result = await _validator.validateCode(code);
      return result.isValid;
    } catch (_) {
      return false;
    }
  }
}
