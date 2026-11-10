import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final strings = AppStrings.of(langState);

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: buildPremiumAppBar(
            context,
            title: strings.settingsTitle,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Support & Legal'),
              const SizedBox(height: 10),
              SurfaceCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.headset_mic_outlined,
                      title: langState.isHindi ? 'मदद और सहायता' : 'Help & Support',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              langState.isHindi
                                  ? 'सहायता के लिए support@dhanda.app पर संपर्क करें'
                                  : 'Contact us at support@dhanda.app',
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: langState.isHindi ? 'नियम एवं शर्तें' : 'Terms and Conditions',
                      onTap: () {
                        _showInfoDialog(
                          context,
                          langState.isHindi ? 'नियम एवं शर्तें' : 'Terms & Conditions',
                          langState.isHindi
                              ? 'धंधा ऐप का उपयोग करके आप हमारी सेवाओं के नियमों और शर्तों से सहमत होते हैं।'
                              : 'By using Dhanda App, you agree to our terms and conditions for business AI tools.',
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: langState.isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                      onTap: () {
                        _showInfoDialog(
                          context,
                          langState.isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                          langState.isHindi
                              ? 'आपकी व्यावसायिक जानकारी और डेटा हमारे पास पूरी तरह सुरक्षित है।'
                              : 'Your business profile and data are completely safe and protected with us.',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const SectionHeader(title: 'Account'),
              const SizedBox(height: 10),
              SurfaceCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppTheme.warning,
                      badgeBg: AppTheme.warningSoft,
                      titleColor: AppTheme.warning,
                      title: strings.logout,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: Text(strings.logout),
                            content: Text(
                              langState.isHindi
                                  ? 'क्या आप निश्चित रूप से लॉगआउट करना चाहते हैं?'
                                  : 'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: Text(langState.isHindi ? 'रद्द करें' : 'Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.warning,
                                  minimumSize: const Size(90, 42),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  context.read<AuthCubit>().signOut();
                                  context.go(AppRouter.auth);
                                },
                                child: Text(strings.logout),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      iconColor: AppTheme.danger,
                      badgeBg: AppTheme.dangerSoft,
                      titleColor: AppTheme.danger,
                      title: langState.isHindi
                          ? 'खाता हटाएं (Delete Account)'
                          : 'Delete Account',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: Text(langState.isHindi ? 'खाता हटाएं' : 'Delete Account'),
                            content: Text(
                              langState.isHindi
                                  ? 'क्या आप निश्चित रूप से अपना खाता स्थायी रूप से हटाना चाहते हैं? यह क्रिया वापस नहीं ली जा सकती।'
                                  : 'Are you sure you want to permanently delete your account? This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: Text(langState.isHindi ? 'रद्द करें' : 'Cancel'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  minimumSize: const Size(90, 42),
                                ),
                                onPressed: () {
                                  Navigator.pop(dialogCtx);
                                  context.read<AuthCubit>().signOut();
                                  context.go(AppRouter.auth);
                                },
                                child: Text(
                                  langState.isHindi ? 'हां, हटाएं' : 'Delete',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color badgeBg;
  final Color titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = AppTheme.primaryColor,
    this.badgeBg = AppTheme.primarySoft,
    this.titleColor = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SoftIconBadge(
        icon: icon,
        iconColor: iconColor,
        backgroundColor: badgeBg,
        size: 19,
        padding: 8,
        borderRadius: 10,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
          color: titleColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
