// lib/presentation/blocs/activation/activation_state.dart
// Cubit للتفعيل — حالات بسيطة تكفي Cubit
import 'package:equatable/equatable.dart';
import '../../../core/security/i_activation_validator.dart';

abstract class ActivationState extends Equatable {
  const ActivationState();
  @override
  List<Object?> get props => [];
}

class ActivationInitial extends ActivationState {}

class ActivationLoading extends ActivationState {}

class ActivationStatusLoaded extends ActivationState {
  final ActivationStatus status;
  final Map<String, int> remaining; // المتبقي لكل نوع
  final bool isFullyActivated;

  const ActivationStatusLoaded({
    required this.status,
    required this.remaining,
    required this.isFullyActivated,
  });

  @override
  List<Object?> get props => [status, remaining, isFullyActivated];
}

class ActivationSuccess extends ActivationState {
  final String message;
  const ActivationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ActivationError extends ActivationState {
  final String message;
  const ActivationError(this.message);
  @override
  List<Object?> get props => [message];
}
