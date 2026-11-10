import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_theme.dart';
import '../tabs/ai_post_tab.dart';
import '../tabs/google_media_tab.dart';
import '../tabs/google_post_tab.dart';
import '../tabs/home_dashboard_tab.dart';
import '../tabs/review_replies_tab.dart';
import '../widgets/app_drawer.dart';

class DashboardShellScreen extends StatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  State<DashboardShellScreen> createState() => _DashboardShellScreenState();
}

class _DashboardShellScreenState extends State<DashboardShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeDashboardTab(
        onSwitchTab: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      const ReviewRepliesTab(),
      const AiPostTab(),
      const GooglePostTab(),
      const GoogleMediaTab(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, langState) {
          final strings = AppStrings.of(langState);

          final items = [
            _NavItemData(
              title: strings.navHome,
              icon: Icons.home_rounded,
            ),
            _NavItemData(
              title: strings.navReviewReplies,
              icon: Icons.chat_bubble_outline_rounded,
            ),
            _NavItemData(
              title: strings.navAiPost,
              isAiIcon: true,
            ),
            _NavItemData(
              title: strings.navGooglePost,
              icon: Icons.article_outlined,
            ),
            _NavItemData(
              title: strings.navGoogleMedia,
              icon: Icons.collections_outlined,
            ),
          ];

          return Scaffold(
            drawer: AppDrawer(
              onTabSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF181D27).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = index == _currentIndex;
                      final activeColor = AppTheme.primaryColor;
                      final inactiveColor = AppTheme.textMuted;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primarySoft : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.isAiIcon)
                                  _AiPostIcon(
                                    color: isSelected ? activeColor : inactiveColor,
                                    size: 20,
                                  )
                                else
                                  Icon(
                                    item.icon,
                                    color: isSelected ? activeColor : inactiveColor,
                                    size: 21,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? activeColor : inactiveColor,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItemData {
  final String title;
  final IconData? icon;
  final bool isAiIcon;

  _NavItemData({
    required this.title,
    this.icon,
    this.isAiIcon = false,
  });
}

class _AiPostIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _AiPostIcon({
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 4,
      height: size + 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size - 1,
            height: size - 1,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'AI',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
          Positioned(
            top: -1,
            right: 0,
            child: Icon(
              Icons.auto_awesome,
              size: 9,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
