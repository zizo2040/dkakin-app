// lib/presentation/blocs/reports/reports_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/report_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportRepository _reportRepo;

  ReportsBloc({required ReportRepository reportRepo})
      : _reportRepo = reportRepo,
        super(ReportsLoading()) {
    on<ReportsLoad>(_onLoad);
  }

  Future<void> _onLoad(ReportsLoad event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final netProfit = await _reportRepo.getTodayNetProfit();
      final cashSales = await _reportRepo.getTodayCashSales();
      final newDebts = await _reportRepo.getTodayNewDebts();
      final collectedPayments = await _reportRepo.getTodayCollectedPayments();
      final last7Days = await _reportRepo.getLast7DaysReport();
      final topProducts = await _reportRepo.getTop5Products();

      // التحقق من وجود بيانات كافية
      final totalSales = await _reportRepo.getTotalSalesAllTime();
      final hasEnoughData = totalSales > 0;

      emit(ReportsLoaded(
        netProfit: netProfit,
        cashSales: cashSales,
        newDebts: newDebts,
        collectedPayments: collectedPayments,
        last7Days: last7Days,
        topProducts: topProducts,
        hasEnoughData: hasEnoughData,
      ));
    } catch (e) {
      emit(ReportsError('${AppStrings.dbError}: $e'));
    }
  }
}
