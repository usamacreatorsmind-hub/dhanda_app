import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, langState) {
          final strings = AppStrings.of(langState);
          final pages = [
            _OnboardingItem(
              icon: Icons.campaign_rounded,
              title: strings.onboardingTitle1,
              subtitle: strings.onboardingSub1,
              accent: AppTheme.primaryColor,
              surface: AppTheme.primarySoft,
            ),
            _OnboardingItem(
              icon: Icons.auto_awesome_rounded,
              title: strings.onboardingTitle2,
              subtitle: strings.onboardingSub2,
              accent: AppTheme.secondaryColor,
              surface: AppTheme.secondarySoft,
            ),
            _OnboardingItem(
              icon: Icons.share_rounded,
              title: strings.onboardingTitle3,
              subtitle: strings.onboardingSub3,
              accent: AppTheme.success,
              surface: AppTheme.successSoft,
            ),
          ];

          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Bar: Brand indicator + Language Switcher + Skip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          strings.appTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            context.read<LanguageCubit>().changeLanguage(
                              langState.isHindi
                                  ? AppLanguage.english
                                  : AppLanguage.hindi,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.translate_rounded,
                                  size: 14,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  langState.isHindi ? 'English' : 'हिंदी',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_currentPage < pages.length - 1) ...[
                          const SizedBox(width: 4),
                          TextButton(
                            onPressed: () => context.go(AppRouter.auth),
                            child: Text(
                              strings.skip,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Slides
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        final item = pages[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Layered architectural illustration well
                              Container(
                                width: 176,
                                height: 176,
                                decoration: BoxDecoration(
                                  color: item.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 124,
                                    height: 124,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: item.accent.withValues(
                                          alpha: 0.16,
                                        ),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.accent.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 56,
                                      color: item.accent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 8,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : const Color(0xFFD7DCE6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          context.go(AppRouter.auth);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == pages.length - 1
                                ? strings.getStarted
                                : strings.next,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color surface;

  _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.surface,
  });
}
