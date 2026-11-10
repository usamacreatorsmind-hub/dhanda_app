import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final strings = AppStrings.of(langState);
        final languageCubit = context.read<LanguageCubit>();

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: buildPremiumAppBar(context, title: strings.settingsTitle),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User / Business Header Card
              const SurfaceCard(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SoftIconBadge(
                      icon: Icons.storefront_rounded,
                      size: 26,
                      padding: 13,
                      borderRadius: 15,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Business Store',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '+91 9876543210',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Language Selection Section
              SurfaceCard(
                child: RadioGroup<AppLanguage>(
                  groupValue: langState.language,
                  onChanged: (val) {
                    if (val != null) languageCubit.changeLanguage(val);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                        child: Text(
                          strings.languageSelection,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const RadioListTile<AppLanguage>(
                        title: Text(
                          'English',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5),
                        ),
                        value: AppLanguage.english,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      const RadioListTile<AppLanguage>(
                        title: Text(
                          'हिंदी (Hindi)',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5),
                        ),
                        value: AppLanguage.hindi,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Account Settings
              SurfaceCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const SoftIconBadge(
                        icon: Icons.edit_outlined,
                        size: 18,
                        padding: 8,
                        borderRadius: 10,
                      ),
                      title: Text(
                        strings.editBusinessProfile,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                      onTap: () {
                        context.push(AppRouter.businessSetup);
                      },
                    ),
                    const Divider(height: 1, indent: 60),
                    ListTile(
                      leading: const SoftIconBadge(
                        icon: Icons.share_outlined,
                        size: 18,
                        padding: 8,
                        borderRadius: 10,
                      ),
                      title: Text(
                        langState.isHindi ? 'ऐप शेयर करें' : 'Share App',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 60),
                    ListTile(
                      leading: const SoftIconBadge(
                        icon: Icons.star_outline_rounded,
                        size: 18,
                        padding: 8,
                        borderRadius: 10,
                      ),
                      title: Text(
                        langState.isHindi ? 'रेटिंग दें' : 'Rate Us',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  backgroundColor: AppTheme.dangerSoft,
                  side: const BorderSide(color: AppTheme.dangerBorder),
                ),
                onPressed: () {
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
                            backgroundColor: AppTheme.danger,
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
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(strings.logout),
              ),
            ],
          ),
        );
      },
    );
  }
}
