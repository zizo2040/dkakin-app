// lib/presentation/screens/auth/otp_screen.dart
// شاشة OTP — كود التأكيد (وهمي حالياً: 000000)
// TODO-PHASE2: استبدل هذا بـ Firebase Phone Auth
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/error_snackbar.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String shopName;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.shopName,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      showErrorSnackBar(context, AppStrings.invalidOtp);
      return;
    }

    context.read<AuthBloc>().add(AuthOtpSubmitted(
      otp: otp,
      phone: widget.phone,
      shopName: widget.shopName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.creamBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showErrorSnackBar(context, state.message);
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.paddingXL),
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppDimensions.paddingL),
                const Text(
                  AppStrings.otpTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppDimensions.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  'تم إرسال كود لرقم: ${widget.phone}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontBody,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 32,
                    letterSpacing: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: const TextStyle(
                      fontSize: 32,
                      letterSpacing: 16,
                      color: AppColors.textHint,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                // ملاحظة الكود الوهمي
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warningOrange, size: 20),
                      SizedBox(width: AppDimensions.paddingS),
                      Expanded(
                        child: Text(
                          'للاختبار: ادخل 000000',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSmall,
                            color: AppColors.warningOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _verify,
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
                              AppStrings.otpVerify,
                              style: TextStyle(fontSize: AppDimensions.fontSubtitle),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
