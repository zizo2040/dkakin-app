// lib/presentation/blocs/reports/reports_event.dart
import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object?> get props => [];
}

class ReportsLoad extends ReportsEvent {}
