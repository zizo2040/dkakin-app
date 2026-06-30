// lib/presentation/blocs/reports/reports_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/repositories/report_repository.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final double netProfit;
  final double cashSales;
  final double newDebts;
  final double collectedPayments;
  final List<DailyReport> last7Days;
  final List<TopProductReport> topProducts;
  final bool hasEnoughData;

  const ReportsLoaded({
    required this.netProfit,
    required this.cashSales,
    required this.newDebts,
    required this.collectedPayments,
    required this.last7Days,
    required this.topProducts,
    this.hasEnoughData = true,
  });

  @override
  List<Object?> get props => [
        netProfit,
        cashSales,
        newDebts,
        collectedPayments,
        last7Days,
        topProducts,
        hasEnoughData,
      ];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}
