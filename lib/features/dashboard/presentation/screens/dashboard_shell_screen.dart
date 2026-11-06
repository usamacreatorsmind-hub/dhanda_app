import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../tabs/home_dashboard_tab.dart';
import '../widgets/app_drawer.dart';

class DashboardShellScreen extends StatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  State<DashboardShellScreen> createState() => _DashboardShellScreenState();
}

class _DashboardShellScreenState extends State<DashboardShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeDashboardTab(),
    const _PlaceholderTab(title: 'Review Replies'),
    const _PlaceholderTab(title: 'AI Post'),
    const _PlaceholderTab(title: 'Google Post'),
    const _PlaceholderTab(title: 'Google Media'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
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
            children: _tabs,
          ),
          bottomNavigationBar: Container(
            color: const Color(0xFF091124),
            child: SafeArea(
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == _currentIndex;

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
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                          decoration: isSelected
                              ? BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5E2B88), Color(0xFF3F1960)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                )
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.isAiIcon)
                                _AiPostIcon(
                                  color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
                                  size: 20,
                                )
                              else
                                Icon(
                                  item.icon,
                                  color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
                                  size: 22,
                                ),
                              const SizedBox(height: 4),
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Colors.white : const Color(0xFF8C9BAE),
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
              border: Border.all(color: color, width: 1.6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'AI',
              style: TextStyle(
                color: color,
                fontSize: 9.5,
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

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '$title (Phase 2 Component)',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
