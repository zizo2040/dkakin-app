// lib/presentation/screens/splash_screen.dart
// شاشة البداية — شعار + فحص الجلسة + انتقال تلقائي
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // فحص الجلسة بعد 2.5 ثانية
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.creamBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الدكان
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 64,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              // اسم التطبيق
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              // الشعار
              const Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontSize: AppDimensions.fontSubtitle,
                  color: AppColors.brown,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL * 2),
              // مؤشر تحميل
              const CircularProgressIndicator(
                color: AppColors.primaryGreen,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
