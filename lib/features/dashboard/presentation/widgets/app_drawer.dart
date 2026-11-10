import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../business_profile/data/models/business_profile_model.dart';
import '../../../business_profile/data/repositories/business_profile_repository.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onTabSelected;

  const AppDrawer({super.key, this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final repository = BusinessProfileRepository();

    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final strings = AppStrings.of(langState);
        final languageCubit = context.read<LanguageCubit>();

        return StreamBuilder<BusinessProfileModel>(
          stream: repository.watchCurrentUserProfile(),
          builder: (context, snapshot) {
            final profile = snapshot.data ?? const BusinessProfileModel(userId: 'guest_user');
            final bizName =
                profile.businessName.isNotEmpty ? profile.businessName : 'My Business Store';
            final phone =
                profile.primaryPhone.isNotEmpty ? profile.primaryPhone : '+91 9876543210';
            final category = profile.primaryCategory.isNotEmpty
                ? profile.primaryCategory
                : (langState.isHindi ? 'रिटेल और शॉपिंग' : 'Retail & Shopping');

            return Drawer(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              child: Column(
                children: [
                  // Soft Light Tonal Header (No dark/neon purple gradient slab)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 22,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FB),
                      border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primarySoft,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.primaryBorder),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 28,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          bizName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 17.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          profile.connectedGmail.isNotEmpty
                              ? '$phone • ${profile.connectedGmail}'
                              : phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StatusPill(
                          label: category,
                          textColor: AppTheme.primaryColor,
                          backgroundColor: Colors.white,
                          borderColor: AppTheme.borderColor,
                        ),
                      ],
                    ),
                  ),

                  // Navigation List with restrained, uniform iconography
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      children: [
                        _DrawerTile(
                          icon: Icons.home_rounded,
                          title: strings.navHome,
                          onTap: () {
                            Navigator.pop(context);
                            if (onTabSelected != null) onTabSelected!(0);
                          },
                        ),
                        _DrawerTile(
                          icon: Icons.switch_account_rounded,
                          title: langState.isHindi ? 'प्रोफ़ाइल चुनें (Select Profile)' : 'Select Profile',
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppRouter.selectProfile);
                          },
                        ),
                        _DrawerTile(
                          icon: Icons.tune_rounded,
                          title: langState.isHindi ? 'प्राथमिकताएं (Preferences)' : 'Preferences',
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppRouter.preferences);
                          },
                        ),
                        _DrawerTile(
                          icon: Icons.business_center_rounded,
                          title: langState.isHindi
                              ? 'बिज़नेस प्रोफ़ाइल प्रबंधित करें'
                              : 'Manage Business Profile',
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppRouter.manageBusinessProfile);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Divider(height: 1),
                        ),
                        ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          leading: const SoftIconBadge(
                            icon: Icons.language_rounded,
                            iconColor: AppTheme.primaryColor,
                            backgroundColor: AppTheme.primarySoft,
                            size: 19,
                            padding: 8,
                            borderRadius: 10,
                          ),
                          title: Text(
                            strings.languageSelection,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            langState.isHindi ? 'हिंदी' : 'English',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          trailing: Switch(
                            value: langState.isHindi,
                            onChanged: (isHindi) {
                              languageCubit.changeLanguage(
                                isHindi ? AppLanguage.hindi : AppLanguage.english,
                              );
                            },
                          ),
                        ),
                        _DrawerTile(
                          icon: Icons.settings_outlined,
                          title: langState.isHindi ? 'सेटिंग्स (Settings)' : 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            context.push(AppRouter.settings);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _DrawerTile(
                          icon: Icons.share_outlined,
                          title: langState.isHindi ? 'ऐप शेयर करें' : 'Share App',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          'Dhanda AI SaaS • v1.0.0',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: SoftIconBadge(
        icon: icon,
        iconColor: AppTheme.textSecondary,
        backgroundColor: AppTheme.surfaceMuted,
        size: 19,
        padding: 8,
        borderRadius: 10,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 19, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
