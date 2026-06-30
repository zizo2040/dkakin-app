// lib/presentation/screens/auth/login_screen.dart
// شاشة تسجيل الدخول — رقم الهاتف + اسم الدكان
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/error_snackbar.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    final shopName = _shopNameController.text.trim();

    if (!isValidPhone(phone)) {
      showErrorSnackBar(context, AppStrings.invalidPhone);
      return;
    }
    if (!isNotEmpty(shopName)) {
      showErrorSnackBar(context, AppStrings.invalidShopName);
      return;
    }

    context.read<AuthBloc>().add(AuthPhoneSubmitted(
      phone: phone,
      shopName: shopName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showErrorSnackBar(context, state.message);
          } else if (state is AuthOtpSent) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  phone: state.phone,
                  shopName: state.shopName,
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.paddingXL * 2),
                // الأيقونة
                const Icon(
                  Icons.storefront,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                // العنوان
                const Text(
                  AppStrings.registerTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppDimensions.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                // حقل اسم الدكان
                TextField(
                  controller: _shopNameController,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: AppDimensions.fontBody),
                  decoration: InputDecoration(
                    labelText: AppStrings.shopNameHint,
                    labelStyle: const TextStyle(fontSize: AppDimensions.fontBody),
                    prefixIcon: const Icon(Icons.store, size: AppDimensions.iconMedium),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
                // حقل رقم الهاتف
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: const Text(
                        AppStrings.userIdPrefix,
                        style: TextStyle(fontSize: AppDimensions.fontBody),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: AppDimensions.fontBody),
                        decoration: InputDecoration(
                          labelText: AppStrings.phoneHint,
                          labelStyle: const TextStyle(fontSize: AppDimensions.fontBody),
                          prefixIcon: const Icon(Icons.phone, size: AppDimensions.iconMedium),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                // زر المتابعة
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: AppColors.white)
                          : const Text(
                              AppStrings.ok,
                              style: TextStyle(fontSize: AppDimensions.fontSubtitle),
                            ),
                    );
                  },
                ),
                const Spacer(),
                // ملاحظة
                const Text(
                  AppStrings.otpMockNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppDimensions.fontCaption,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
