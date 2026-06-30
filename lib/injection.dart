// lib/injection.dart
// تسجيل جميع الاعتماديات — استبدال أي تنفيذ = تعديل هذا الملف فقط
// لا تستورد أي تنفيذ مباشرة في الشاشات
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/connectivity_checker.dart';
import 'core/security/encryption_service.dart';
import 'core/security/i_activation_validator.dart';
import 'core/security/integrity_checker.dart';
import 'core/security/local_activation_validator.dart';
import 'core/sync/i_sync_service.dart';
import 'core/sync/no_op_sync_service.dart';
import 'data/local/database_helper.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/debt_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/report_repository.dart';
import 'data/repositories/sale_repository.dart';
import 'data/repositories/supplier_repository.dart';
import 'presentation/blocs/activation/activation_cubit.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/customers/customers_bloc.dart';
import 'presentation/blocs/pos/pos_bloc.dart';
import 'presentation/blocs/products/products_bloc.dart';
import 'presentation/blocs/reports/reports_bloc.dart';
import 'presentation/blocs/suppliers/suppliers_bloc.dart';

final getIt = GetIt.instance;

/// تسجيل جميع الاعتماديات
/// يُستدعى مرة واحدة في main.dart قبل runApp
Future<void> configureDependencies() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Database
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // Encryption (يحتاج رقم الهاتف — يُنشأ لاحقاً عند تسجيل الدخول)
  // getIt.registerFactoryParam<EncryptionService, String, void>(
  //   (phone, _) => EncryptionService(phone),
  // );

  // Security — IActivationValidator ← LocalActivationValidator
  // TODO-PHASE2: استبدل بـ RemoteActivationValidator
  getIt.registerLazySingleton<IActivationValidator>(
    () => LocalActivationValidator(
      getIt<SharedPreferences>(),
      EncryptionService('default_phone'), // يُحدث لاحقاً
    ),
  );

  // Sync — ISyncService ← NoOpSyncService
  // TODO-PHASE2: استبدل بـ FirebaseSyncService
  getIt.registerLazySingleton<ISyncService>(
    () => NoOpSyncService(),
  );

  // Connectivity
  getIt.registerLazySingleton<ConnectivityChecker>(
    () => ConnectivityChecker(),
  );

  // Integrity
  getIt.registerLazySingleton<IntegrityChecker>(
    () => IntegrityChecker(mode: IntegrityMode.warn),
  );

  // Repositories
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepository(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<SupplierRepository>(
    () => SupplierRepository(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepository(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<DebtRepository>(
    () => DebtRepository(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepository(getIt<DatabaseHelper>()),
  );
}

/// دوال مساعدة لإنشاء Blocs/Cubits
class BlocFactory {
  static AuthBloc createAuthBloc() => AuthBloc(
        prefs: getIt<SharedPreferences>(),
        db: getIt<DatabaseHelper>(),
      );

  static PosBloc createPosBloc() => PosBloc(
        productRepo: getIt<ProductRepository>(),
        saleRepo: getIt<SaleRepository>(),
        customerRepo: getIt<CustomerRepository>(),
        activation: getIt<IActivationValidator>(),
      );

  static CustomersBloc createCustomersBloc() => CustomersBloc(
        customerRepo: getIt<CustomerRepository>(),
        debtRepo: getIt<DebtRepository>(),
        activation: getIt<IActivationValidator>(),
      );

  static ProductsBloc createProductsBloc() => ProductsBloc(
        productRepo: getIt<ProductRepository>(),
        activation: getIt<IActivationValidator>(),
      );

  static SuppliersBloc createSuppliersBloc() => SuppliersBloc(
        supplierRepo: getIt<SupplierRepository>(),
        activation: getIt<IActivationValidator>(),
      );

  static ReportsBloc createReportsBloc() => ReportsBloc(
        reportRepo: getIt<ReportRepository>(),
      );

  static ActivationCubit createActivationCubit() => ActivationCubit(
        validator: getIt<IActivationValidator>(),
      );
}
