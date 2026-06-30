// lib/presentation/screens/settings/settings_screen.dart
// شاشة الإعدادات — بيانات الدكان + الطابعة + نسخ احتياطي + تفعيل
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/sync/i_sync_service.dart';
import '../../blocs/activation/activation_cubit.dart';
import '../../blocs/activation/activation_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/error_snackbar.dart';
import '../activation/activation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _shopNameController = TextEditingController();
  bool _autoBackup = true;

  @override
  void initState() {
    super.initState();
    context.read<ActivationCubit>().loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            _shopNameController.text = authState.shopName;
          }

          return ListView(
            children: [
              // بيانات الدكان
              _SectionTitle(AppStrings.shopInfo),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    children: [
                      TextField(
                        controller: _shopNameController,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(labelText: AppStrings.shopNameHint),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      ElevatedButton(
                        onPressed: () {
                          if (_shopNameController.text.trim().isNotEmpty) {
                            context.read<AuthBloc>().add(AuthShopUpdated(_shopNameController.text.trim()));
                            showSuccessSnackBar(context, 'تم التحديث');
                          }
                        },
                        child: const Text(AppStrings.save),
                      ),
                    ],
                  ),
                ),
              ),

              // الطابعة
              _SectionTitle(AppStrings.printerSection),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: ListTile(
                  // TODO: استخدم esc_pos_bluetooth لاقتران الطابعة
                  // يتطلب صلاحيات BLUETOOTH و BLUETOOTH_ADMIN في AndroidManifest.xml
                  leading: const Icon(Icons.print, color: AppColors.brown),
                  title: const Text(AppStrings.connectPrinter),
                  subtitle: const Text(AppStrings.printerDisconnected, style: TextStyle(color: AppColors.textHint)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showErrorSnackBar(context, AppStrings.bluetoothNotAvailable),
                ),
              ),

              // النسخ الاحتياطي
              _SectionTitle(AppStrings.backupSection),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(AppStrings.autoLocalBackup),
                      value: _autoBackup,
                      onChanged: (v) => setState(() => _autoBackup = v),
                      activeColor: AppColors.primaryGreen,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.cloud_upload, color: AppColors.infoBlue),
                      title: const Text(AppStrings.linkGoogleDrive),
                      subtitle: const Text('غير مربوط'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final syncService = context.read<ISyncService>();
                        final result = await syncService.backupNow();
                        showErrorSnackBar(context, result.message);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.backup, color: AppColors.primaryGreen),
                      title: const Text(AppStrings.backupNow),
                      onTap: () async {
                        final syncService = context.read<ISyncService>();
                        final result = await syncService.backupNow();
                        showSuccessSnackBar(context, result.message);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.restore, color: AppColors.warningOrange),
                      title: const Text(AppStrings.restoreBackup),
                      onTap: () => _showRestoreConfirm(context),
                    ),
                  ],
                ),
              ),

              // حالة التفعيل
              _SectionTitle(AppStrings.activationSection),
              BlocBuilder<ActivationCubit, ActivationState>(
                builder: (context, state) {
                  if (state is ActivationStatusLoaded) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              state.isFullyActivated ? Icons.verified : Icons.timelapse,
                              color: state.isFullyActivated ? AppColors.successGreen : AppColors.warningOrange,
                            ),
                            title: Text(state.isFullyActivated ? AppStrings.fullyActivated : AppStrings.trialActive),
                            subtitle: state.isFullyActivated
                                ? null
                                : Text(state.remaining.entries.map((e) => '${e.key}: ${e.value}').join(' | ')),
                            trailing: state.isFullyActivated
                                ? null
                                : TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ActivationScreen()),
                                    ),
                                    child: const Text('فعّل'),
                                  ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Card(
                    margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                    child: ListTile(title: Text('جاري التحميل...')),
                  );
                },
              ),

              // الدعم
              _SectionTitle('الدعم'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: ListTile(
                  leading: const Icon(Icons.support_agent, color: AppColors.successGreen),
                  title: const Text(AppStrings.supportWhatsapp),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    final url = Uri.parse('https://wa.me/967XXXXXXXXX');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),

              // تسجيل الخروج
              const SizedBox(height: AppDimensions.paddingXL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text(AppStrings.logout),
                        content: const Text('متأكد من تسجيل الخروج؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debtRed),
                            child: const Text(AppStrings.logout),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(AppStrings.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.debtRed.withOpacity(0.1),
                    foregroundColor: AppColors.debtRed,
                    minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL * 2),
            ],
          );
        },
      ),
    );
  }

  void _showRestoreConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.restoreBackup),
        content: const Text(AppStrings.restoreConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final syncService = context.read<ISyncService>();
              final result = await syncService.restoreFromBackup();
              showErrorSnackBar(context, result.message);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debtRed),
            child: const Text(AppStrings.restoreBackup),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.paddingM, AppDimensions.paddingL, AppDimensions.paddingM, AppDimensions.paddingS),
      child: Text(
        title,
        style: const TextStyle(fontSize: AppDimensions.fontBody, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }
}
