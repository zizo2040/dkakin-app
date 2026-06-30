// lib/app.dart
// جذر التطبيق — تغليف MaterialApp بالـ BlocProviders
import 'package:dkakin/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/security/i_activation_validator.dart';
import 'core/sync/i_sync_service.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/report_repository.dart';
import 'data/repositories/sale_repository.dart';
import 'data/repositories/supplier_repository.dart';
import 'injection.dart';
import 'presentation/blocs/activation/activation_cubit.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/screens/splash_screen.dart';

class DkakinApp extends StatelessWidget {
  const DkakinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // إجبار الوضع العمودي + RTL
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getIt<CustomerRepository>()),
        RepositoryProvider.value(value: getIt<ProductRepository>()),
        RepositoryProvider.value(value: getIt<SaleRepository>()),
        RepositoryProvider.value(value: getIt<SupplierRepository>()),
        RepositoryProvider.value(value: getIt<ReportRepository>()),
        RepositoryProvider.value(value: getIt<ISyncService>()),
        RepositoryProvider.value(value: getIt<IActivationValidator>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BlocFactory.createAuthBloc()),
          BlocProvider(create: (_) => BlocFactory.createActivationCubit()),
        ],
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          // إجبار RTL
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            );
          },
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.creamBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              primary: AppColors.primaryGreen,
              secondary: AppColors.brown,
              surface: AppColors.creamBackground,
              error: AppColors.debtRed,
            ),
            fontFamily: 'Cairo', // TODO: أضف خط Cairo في pubspec.yaml
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              bodyLarge: TextStyle(fontSize: 18, color: AppColors.textPrimary),
              bodyMedium: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontSize: AppDimensions.fontSubtitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
            ),
            cardTheme: CardThemeData( // صحيح
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingM,
              ),
            ),
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
