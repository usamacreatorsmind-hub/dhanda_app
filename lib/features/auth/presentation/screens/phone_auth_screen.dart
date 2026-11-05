import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  String _verificationId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OTPSentState) {
          setState(() {
            _isOtpSent = true;
            _verificationId = state.verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('OTP Sent! Default OTP: 1234'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else if (state is AuthenticatedState) {
          context.go(AppRouter.businessSetup);
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final langState = context.watch<LanguageCubit>().state;
        final strings = AppStrings.of(langState);
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Stack(
            children: [
              // Decorative Top Background Gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenSize.height * 0.42,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                ),
              ),

              // Decorative Glowing Circles
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: -50,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top App Bar with Language Toggle Pill
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                strings.appTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          // Language Selector Pill Button
                          InkWell(
                            onTap: () {
                              context.read<LanguageCubit>().changeLanguage(
                                    langState.isHindi ? AppLanguage.english : AppLanguage.hindi,
                                  );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.translate_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    langState.isHindi ? 'English' : 'हिंदी',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Vertically Centered Scrollable Area
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Main Elevated Premium Card
                                  Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Icon Badge
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.primaryColor.withValues(alpha: 0.15),
                                                theme.primaryColor.withValues(alpha: 0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _isOtpSent ? Icons.mark_email_read_rounded : Icons.phone_android_rounded,
                                            size: 40,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Heading Title
                                        Text(
                                          _isOtpSent ? strings.verifyOTP : strings.welcomeBack,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1A1D1E),
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Subtitle
                                        Text(
                                          _isOtpSent
                                              ? '${strings.enter6DigitOTP} (+91 ${_phoneController.text.trim()})'
                                              : strings.loginSubtitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF75818F),
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 32),

                                        if (!_isOtpSent) ...[
                                          // Phone Input Field Container
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F5F9),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFFE2E7EE)),
                                            ),
                                            child: Row(
                                              children: [
                                                // Country Code Prefix Badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                                  decoration: const BoxDecoration(
                                                    border: Border(
                                                      right: BorderSide(color: Color(0xFFE2E7EE)),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: const [
                                                      Text('🇮🇳', style: TextStyle(fontSize: 20)),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        '+91',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF1A1D1E),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Phone Text Field
                                                Expanded(
                                                  child: TextField(
                                                    controller: _phoneController,
                                                    keyboardType: TextInputType.phone,
                                                    maxLength: 10,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 2,
                                                      color: Color(0xFF1A1D1E),
                                                    ),
                                                    decoration: const InputDecoration(
                                                      hintText: '98765 43210',
                                                      hintStyle: TextStyle(
                                                        color: Color(0xFFA5B0C0),
                                                        letterSpacing: 1,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                      counterText: '',
                                                      border: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 28),

                                          // Gradient CTA Submit Button
                                          Container(
                                            width: double.infinity,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF6A1B9A).withValues(alpha: 0.35),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: isLoading
                                                  ? null
                                                  : () {
                                                      final phone = _phoneController.text.trim();
                                                      if (phone.length < 10) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: const Text('Please enter valid 10 digit phone number'),
                                                            backgroundColor: Colors.deepOrange,
                                                            behavior: SnackBarBehavior.floating,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      context.read<AuthCubit>().sendOTP('+91$phone');
                                                    },
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          strings.sendOTP,
                                                          style: const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ] else ...[
                                          // OTP Input Field
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F5F9),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: const Color(0xFF6A1B9A), width: 1.5),
                                            ),
                                            child: TextField(
                                              controller: _otpController,
                                              keyboardType: TextInputType.number,
                                              maxLength: 4,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 16,
                                                color: Color(0xFF1A1D1E),
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: '1234',
                                                hintStyle: TextStyle(
                                                  color: Color(0xFFA5B0C0),
                                                  letterSpacing: 16,
                                                ),
                                                counterText: '',
                                                border: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 28),

                                          // Verify Button
                                          Container(
                                            width: double.infinity,
                                            height: 54,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: isLoading
                                                  ? null
                                                  : () {
                                                      final otp = _otpController.text.trim();
                                                      if (otp.isEmpty) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Please enter OTP (Default: 1234)')),
                                                        );
                                                        return;
                                                      }
                                                      context.read<AuthCubit>().verifyOTP(
                                                            verificationId: _verificationId,
                                                            smsCode: otp,
                                                            phoneNumber: '+91${_phoneController.text.trim()}',
                                                          );
                                                    },
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          strings.verifyOTP,
                                                          style: const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Change Number Button
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _isOtpSent = false;
                                              });
                                            },
                                            icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF6A1B9A)),
                                            label: Text(
                                              langState.isHindi ? 'नंबर बदलें' : 'Change Phone Number',
                                              style: const TextStyle(
                                                color: Color(0xFF6A1B9A),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Security Badge at Bottom
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.verified_user_rounded, size: 18, color: Color(0xFF2E7D32)),
                                      const SizedBox(width: 6),
                                      Text(
                                        langState.isHindi
                                            ? '100% सुरक्षित और 1-क्लिक ओटीपी लॉगिन'
                                            : '100% Secure & Fast OTP Sign In',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5A6E85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
  }
}
