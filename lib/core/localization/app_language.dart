import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi }

class LanguageState {
  final AppLanguage language;
  const LanguageState(this.language);

  bool get isHindi => language == AppLanguage.hindi;
  String get code => isHindi ? 'hi' : 'en';
}

class LanguageCubit extends Cubit<LanguageState> {
  static const String _prefKey = 'app_language_code';

  LanguageCubit() : super(const LanguageState(AppLanguage.english)) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code == 'hi') {
        emit(const LanguageState(AppLanguage.hindi));
      } else {
        emit(const LanguageState(AppLanguage.english));
      }
    } catch (_) {}
  }

  Future<void> changeLanguage(AppLanguage language) async {
    emit(LanguageState(language));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language == AppLanguage.hindi ? 'hi' : 'en');
    } catch (_) {}
  }
}

class AppStrings {
  final AppLanguage lang;

  AppStrings(this.lang);

  static AppStrings of(LanguageState state) => AppStrings(state.language);

  bool get isHindi => lang == AppLanguage.hindi;

  // App Title
  String get appTitle => isHindi ? 'धंधा ऐप' : 'Dhanda App';
  String get tagLine => isHindi ? 'आपके बिज़नेस का डिजिटल साथी' : 'Your Digital Business Companion';

  // Onboarding
  String get onboardingTitle1 => isHindi ? 'अपना बिज़नेस बढ़ाएं' : 'Grow Your Business';
  String get onboardingSub1 => isHindi ? 'सोशल मीडिया पोस्ट्स, बैनर्स और पोस्टर्स आसानी से बनाएं' : 'Create social media posts, banners, and posters with ease';

  String get onboardingTitle2 => isHindi ? 'AI से ऑटोमैटिक कंटेंट' : 'AI Powered Content';
  String get onboardingSub2 => isHindi ? 'Gemini AI से आकर्षक कैप्शंस और पोस्ट आइडियाज़ पाएं' : 'Get engaging captions and post ideas using Gemini AI';

  String get onboardingTitle3 => isHindi ? 'एक क्लिक में शेयर करें' : 'Share in 1-Click';
  String get onboardingSub3 => isHindi ? 'WhatsApp, Instagram aur Facebook par turant share karein' : 'Share instantly on WhatsApp, Instagram, and Facebook';

  String get getStarted => isHindi ? 'शुरू करें' : 'Get Started';
  String get next => isHindi ? 'आगे बढ़ें' : 'Next';
  String get skip => isHindi ? 'छोड़ें' : 'Skip';

  // Auth
  String get welcomeBack => isHindi ? 'स्वागत है!' : 'Welcome!';
  String get loginSubtitle => isHindi ? 'जारी रखने के लिए अपना फ़ोन नंबर दर्ज करें' : 'Enter your phone number to continue';
  String get phoneAuth => isHindi ? 'फ़ोन नंबर से लॉगिन' : 'Phone Login';
  String get enterPhone => isHindi ? 'फ़ोन नंबर दर्ज करें' : 'Enter Phone Number';
  String get sendOTP => isHindi ? 'OTP भेजें' : 'Send OTP';
  String get verifyOTP => isHindi ? 'OTP सत्यापित करें' : 'Verify OTP';
  String get enter6DigitOTP => isHindi ? '6 अंकों का OTP दर्ज करें' : 'Enter 6-digit OTP';
  String get googleSignIn => isHindi ? 'गूगल से साइन इन करें' : 'Sign in with Google';

  // Business Setup
  String get setupBusinessTitle => isHindi ? 'बिज़नेस प्रोफ़ाइल सेटअप' : 'Business Profile Setup';
  String get setupBusinessSub => isHindi ? 'अपने बिज़नेस की जानकारी भरें' : 'Enter your business details';
  String get businessName => isHindi ? 'बिज़नेस का नाम' : 'Business Name';
  String get businessCategory => isHindi ? 'कैटेगरी (श्रेणी)' : 'Business Category';
  String get city => isHindi ? 'शहर / स्थान' : 'City / Location';
  String get phoneNumber => isHindi ? 'बिज़नेस फोन नंबर' : 'Business Phone Number';
  String get website => isHindi ? 'वेबसाइट / लिंक (ऐच्छिक)' : 'Website / Link (Optional)';
  String get uploadLogo => isHindi ? 'बिज़नेस लोगो चुनें' : 'Select Business Logo';
  String get saveAndContinue => isHindi ? 'सहेजें और आगे बढ़ें' : 'Save & Continue';

  // Dashboard & Bottom Nav
  String get navHome => isHindi ? 'होम' : 'Home';
  String get navPosts => isHindi ? 'पोस्ट्स' : 'Posts';
  String get navBusiness => isHindi ? 'प्रोफ़ाइल' : 'Profile';
  String get navSettings => isHindi ? 'सेटिंग्स' : 'Settings';

  String get dashboardGreeting => isHindi ? 'नमस्ते!' : 'Hello!';
  String get quickActions => isHindi ? 'त्वरित कार्य' : 'Quick Actions';
  String get createPost => isHindi ? 'नया पोस्ट बनाएं' : 'Create New Post';
  String get businessCards => isHindi ? 'डिजिटल विज़िटिंग कार्ड' : 'Digital Business Card';
  String get aiPosterGenerator => isHindi ? 'AI पोस्टर जनरेटर' : 'AI Poster Generator';
  String get recentDesigns => isHindi ? 'हाल के डिजाइन' : 'Recent Designs';
  String get noRecentDesigns => isHindi ? 'अभी कोई डिजाइन नहीं है' : 'No designs created yet';

  // Settings
  String get settingsTitle => isHindi ? 'सेटिंग्स' : 'Settings';
  String get languageSelection => isHindi ? 'भाषा चुनें' : 'Select Language';
  String get english => 'English';
  String get hindi => 'हिंदी';
  String get editBusinessProfile => isHindi ? 'बिज़नेस प्रोफ़ाइल बदलें' : 'Edit Business Profile';
  String get logout => isHindi ? 'लॉगआउट' : 'Logout';
}
