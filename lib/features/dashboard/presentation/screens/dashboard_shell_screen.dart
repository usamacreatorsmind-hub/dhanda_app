import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/app_language.dart';
import '../tabs/home_dashboard_tab.dart';
import '../../../settings/presentation/screens/settings_tab.dart';

class DashboardShellScreen extends StatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  State<DashboardShellScreen> createState() => _DashboardShellScreenState();
}

class _DashboardShellScreenState extends State<DashboardShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeDashboardTab(),
    const _PlaceholderTab(title: 'Posts & Banners'),
    const _PlaceholderTab(title: 'Business Digital Card'),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, langState) {
        final strings = AppStrings.of(langState);

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: strings.navHome,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.photo_library_rounded),
                label: strings.navPosts,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.storefront_rounded),
                label: strings.navBusiness,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: strings.navSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
