// lib/presentation/screens/activation/activation_screen.dart
// شاشة تفعيل الكود — تظهر كـ Dialog عند تجاوز الحدود أو كصفحة من الإعدادات
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/security/i_activation_validator.dart';
import '../../blocs/activation/activation_cubit.dart';
import '../../blocs/activation/activation_state.dart';
import '../../widgets/error_snackbar.dart';
import '../../widgets/loading_widget.dart';

class ActivationScreen extends StatefulWidget {
  final LimitType? limitType; // إذا مرّر، يعني أننا جئنا من حدّ مُتجاوز

  const ActivationScreen({super.key, this.limitType});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ActivationCubit>().loadStatus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.activationTitle),
        backgroundColor: AppColors.warningOrange,
        foregroundColor: AppColors.white,
      ),
      body: BlocConsumer<ActivationCubit, ActivationState>(
        listener: (context, state) {
          if (state is ActivationSuccess) {
            showSuccessSnackBar(context, state.message);
            Navigator.pop(context);
          } else if (state is ActivationError) {
            showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ActivationLoading) {
            return const LoadingWidget(message: AppStrings.verifying);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.paddingXL),
                const Icon(
                  Icons.vpn_key,
                  size: 80,
                  color: AppColors.warningOrange,
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // رسالة التجاوز
                if (widget.limitType != null)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.debtRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                    child: Text(
                      '${AppStrings.activationMessage} ${widget.limitType!.displayName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontSubtitle,
                        color: AppColors.debtRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: AppDimensions.paddingXL),
                const Text(
                  AppStrings.activationRequired,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: AppDimensions.fontBody, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.paddingXL),

                // حقل الكود
                TextField(
                  controller: _codeController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  maxLength: 14, // XXXX-XXXX-XXXX
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                    _CodeFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: AppStrings.codeHint,
                    hintStyle: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 4,
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

                const SizedBox(height: AppDimensions.paddingXL),

                // زر التفعيل
                ElevatedButton(
                  onPressed: () {
                    final code = _codeController.text.trim();
                    if (code.length >= 12) {
                      context.read<ActivationCubit>().activate(code);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warningOrange,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  child: const Text(
                    AppStrings.activate,
                    style: TextStyle(fontSize: AppDimensions.fontSubtitle),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL * 2),

                // طلب الكود عبر واتساب
                OutlinedButton.icon(
                  onPressed: () async {
                    final deviceId = await context.read<IActivationValidator>().getDeviceId();
                    final message = '${AppStrings.requestCodeMessage}\n$deviceId';
                    final url = Uri.parse('https://wa.me/967XXXXXXXXX?text=${Uri.encodeComponent(message)}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.message),
                  label: const Text(AppStrings.requestCode),
                ),

                // العدادات المتبقية
                if (state is ActivationStatusLoaded && !state.isFullyActivated) ...[
                  const SizedBox(height: AppDimensions.paddingXL),
                  const Text(
                    AppStrings.trialRemaining,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: AppDimensions.fontBody, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppDimensions.paddingM,
                    children: state.remaining.entries.map((entry) {
                      return Chip(
                        label: Text('${entry.key}: ${entry.value}'),
                        backgroundColor: (entry.value > 0 ? AppColors.primaryGreen : AppColors.debtRed).withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: entry.value > 0 ? AppColors.primaryGreen : AppColors.debtRed,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Formatter يضيف الشرطات تلقائياً
class _CodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('-');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
