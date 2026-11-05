import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final strings = AppStrings.of(langState);
        final pages = [
          _OnboardingItem(
            icon: Icons.campaign_rounded,
            title: strings.onboardingTitle1,
            subtitle: strings.onboardingSub1,
            color: const Color(0xFF6200EE),
          ),
          _OnboardingItem(
            icon: Icons.auto_awesome_rounded,
            title: strings.onboardingTitle2,
            subtitle: strings.onboardingSub2,
            color: const Color(0xFFFF6D00),
          ),
          _OnboardingItem(
            icon: Icons.share_rounded,
            title: strings.onboardingTitle3,
            subtitle: strings.onboardingSub3,
            color: const Color(0xFF00C853),
          ),
        ];

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Language Switcher Chip
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: ChoiceChip(
                  label: Text(
                    langState.isHindi ? 'English' : 'हिंदी',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selected: false,
                  onSelected: (_) {
                    context.read<LanguageCubit>().changeLanguage(
                          langState.isHindi ? AppLanguage.english : AppLanguage.hindi,
                        );
                  },
                ),
              ),
              if (_currentPage < pages.length - 1)
                TextButton(
                  onPressed: () => context.go(AppRouter.auth),
                  child: Text(
                    strings.skip,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
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
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(36),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                size: 88,
                                color: item.color,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF757575),
                                height: 1.4,
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
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        context.go(AppRouter.auth);
                      }
                    },
                    child: Text(
                      _currentPage == pages.length - 1
                          ? strings.getStarted
                          : strings.next,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
