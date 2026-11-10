import 'package:dhanda_app/core/localization/app_language.dart';
import 'package:dhanda_app/core/theme/app_theme.dart';
import 'package:dhanda_app/core/widgets/premium_ui.dart';
import 'package:dhanda_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:dhanda_app/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:dhanda_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:dhanda_app/features/settings/presentation/screens/settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppTheme uses muted low-saturation palette and light surfaces', () {
    final theme = AppTheme.lightTheme;

    expect(theme.scaffoldBackgroundColor, AppTheme.backgroundColor);
    expect(theme.colorScheme.primary, const Color(0xFF4A5899));
    expect(theme.appBarTheme.backgroundColor, Colors.white);
    expect(theme.appBarTheme.foregroundColor, AppTheme.textPrimary);
  });

  testWidgets('PremiumUI cards, pills, and app bar render without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            appBar: buildPremiumAppBar(
              context,
              title: 'Dhanda Studio',
              subtitle: 'Local SEO Workspace',
            ),
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TonalHeroCard(
                    child: Text('Hero Content'),
                  ),
                  SizedBox(height: 12),
                  SurfaceCard(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SoftIconBadge(icon: Icons.storefront_rounded),
                        SizedBox(width: 8),
                        StatusPill(
                          label: 'Connected',
                          textColor: AppTheme.success,
                          backgroundColor: AppTheme.successSoft,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dhanda Studio'), findsOneWidget);
    expect(find.text('Hero Content'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('OnboardingScreen advances slides and toggles language', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => LanguageCubit(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grow Your Business'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('AI Powered Content'), findsOneWidget);

    await tester.tap(find.text('हिंदी'));
    await tester.pumpAndSettle();
    expect(find.text('AI से ऑटोमैटिक कंटेंट'), findsOneWidget);
  });

  testWidgets('SettingsTab switches language via RadioGroup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => LanguageCubit(),
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('हिंदी (Hindi)'));
    await tester.pumpAndSettle();
    expect(find.text('सेटिंग्स'), findsOneWidget);
  });

  testWidgets('PhoneAuthScreen renders 4-digit Pinput on OTP step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(create: (_) => AuthCubit()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PhoneAuthScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '9899152923');
    await tester.tap(find.text('Send OTP'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Verify OTP'), findsNWidgets(2)); // title + button
    expect(find.text('Enter 4-digit OTP (+91 9899152923)'), findsOneWidget);
    final pinputFinder = find.byType(Pinput);
    expect(pinputFinder, findsOneWidget);
    expect(tester.widget<Pinput>(pinputFinder).length, 4);
  });
}
