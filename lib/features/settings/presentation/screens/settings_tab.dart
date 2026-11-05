import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
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
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(strings.settingsTitle),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User / Business Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'My Business Store',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+91 9876543210',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Language Selection Section
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        strings.languageSelection,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    RadioListTile<AppLanguage>(
                      title: const Text('English'),
                      value: AppLanguage.english,
                      groupValue: langState.language,
                      onChanged: (val) {
                        if (val != null) languageCubit.changeLanguage(val);
                      },
                    ),
                    RadioListTile<AppLanguage>(
                      title: const Text('हिंदी (Hindi)'),
                      value: AppLanguage.hindi,
                      groupValue: langState.language,
                      onChanged: (val) {
                        if (val != null) languageCubit.changeLanguage(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Account Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                      title: Text(strings.editBusinessProfile),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        context.push(AppRouter.businessSetup);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.share_rounded, color: Colors.green),
                      title: Text(langState.isHindi ? 'ऐप शेयर करें' : 'Share App'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                      title: Text(langState.isHindi ? 'रेटिंग दें' : 'Rate Us'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Logout Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
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
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                icon: const Icon(Icons.logout_rounded),
                label: Text(strings.logout),
              ),
            ],
          ),
        );
      },
    );
  }
}
