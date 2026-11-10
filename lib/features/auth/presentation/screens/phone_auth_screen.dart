import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_ui.dart';
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
  bool _hasOtpError = false;
  String _verificationId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submitOtp({bool isLoading = false}) {
    if (isLoading) return;
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _hasOtpError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 4-digit OTP (Default: 1234)'),
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyOTP(
          verificationId: _verificationId,
          smsCode: otp,
          phoneNumber: '+91${_phoneController.text.trim()}',
        );
  }

  Widget _buildOtpPinput(bool isLoading) {
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 1.2),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: AppTheme.primaryColor, width: 1.6),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppTheme.primarySoft,
      border: Border.all(color: AppTheme.primaryBorder, width: 1.3),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      color: AppTheme.dangerSoft,
      border: Border.all(color: AppTheme.danger, width: 1.4),
    );

    return Pinput(
      length: 4,
      controller: _otpController,
      autofocus: true,
      enabled: !isLoading,
      forceErrorState: _hasOtpError,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      separatorBuilder: (_) => const SizedBox(width: 10),
      cursor: Container(
        width: 2,
        height: 22,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      onChanged: (_) {
        if (_hasOtpError) {
          setState(() => _hasOtpError = false);
        }
      },
      onCompleted: (_) => _submitOtp(isLoading: isLoading),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is OTPSentState) {
            setState(() {
              _isOtpSent = true;
              _hasOtpError = false;
              _verificationId = state.verificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('OTP Sent! Default OTP: 1234'),
                  ],
                ),
                backgroundColor: AppTheme.success,
              ),
            );
          } else if (state is AuthenticatedState) {
            context.go(AppRouter.businessSetup);
          } else if (state is AuthErrorState) {
            if (_isOtpSent) {
              setState(() => _hasOtpError = true);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final langState = context.watch<LanguageCubit>().state;
          final strings = AppStrings.of(langState);
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: Stack(
              children: [
                // Soft, airy top gradient wash instead of heavy dark slab
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: screenSize.height * 0.36,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEEF1F9), Color(0xFFF7F8FB)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Subtle architectural decorative circles
                Positioned(
                  top: -50,
                  right: -40,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withValues(alpha: 0.04),
                    ),
                  ),
                ),
                Positioned(
                  top: 70,
                  left: -60,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withValues(alpha: 0.03),
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // Top Header Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.borderColor),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  strings.appTitle,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),

                            InkWell(
                              onTap: () {
                                context.read<LanguageCubit>().changeLanguage(
                                      langState.isHindi ? AppLanguage.english : AppLanguage.hindi,
                                    );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                                      color: AppTheme.primaryColor,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      langState.isHindi ? 'English' : 'हिंदी',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Centered Scrollable Auth Card
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SurfaceCard(
                                      borderRadius: 24,
                                      padding: const EdgeInsets.all(26),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SoftIconBadge(
                                            icon: _isOtpSent
                                                ? Icons.mark_email_read_rounded
                                                : Icons.phone_android_rounded,
                                            size: 32,
                                            padding: 18,
                                            borderRadius: 20,
                                          ),
                                          const SizedBox(height: 20),

                                          Text(
                                            _isOtpSent ? strings.verifyOTP : strings.welcomeBack,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 6),

                                          Text(
                                            _isOtpSent
                                                ? '${strings.enter4DigitOTP} (+91 ${_phoneController.text.trim()})'
                                                : strings.loginSubtitle,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondary,
                                              height: 1.45,
                                            ),
                                          ),
                                          const SizedBox(height: 28),

                                          if (!_isOtpSent) ...[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppTheme.surfaceMuted,
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(color: AppTheme.borderColor),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 15,
                                                    ),
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        right: BorderSide(color: AppTheme.borderColor),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          '+91',
                                                          style: TextStyle(
                                                            fontSize: 15.5,
                                                            fontWeight: FontWeight.w700,
                                                            color: AppTheme.textPrimary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: _phoneController,
                                                      keyboardType: TextInputType.phone,
                                                      maxLength: 10,
                                                      style: const TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 1.8,
                                                        color: AppTheme.textPrimary,
                                                      ),
                                                      decoration: const InputDecoration(
                                                        hintText: '98765 43210',
                                                        hintStyle: TextStyle(
                                                          color: AppTheme.textMuted,
                                                          letterSpacing: 1,
                                                          fontSize: 15.5,
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                        counterText: '',
                                                        filled: false,
                                                        border: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 22),

                                            ElevatedButton(
                                              onPressed: isLoading
                                                  ? null
                                                  : () {
                                                      final phone = _phoneController.text.trim();
                                                      if (phone.length < 10) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Please enter valid 10 digit phone number',
                                                            ),
                                                            backgroundColor: AppTheme.warning,
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      context.read<AuthCubit>().sendOTP('+91$phone');
                                                    },
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.2,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(strings.sendOTP),
                                                        const SizedBox(width: 8),
                                                        const Icon(Icons.arrow_forward_rounded, size: 18),
                                                      ],
                                                    ),
                                            ),
                                          ] else ...[
                                            Center(
                                              child: _buildOtpPinput(isLoading),
                                            ),
                                            const SizedBox(height: 24),

                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.success,
                                              ),
                                              onPressed: isLoading
                                                  ? null
                                                  : () => _submitOtp(isLoading: isLoading),
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.2,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(strings.verifyOTP),
                                                        const SizedBox(width: 8),
                                                        const Icon(
                                                          Icons.check_circle_outline_rounded,
                                                          size: 18,
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                            const SizedBox(height: 12),

                                            TextButton.icon(
                                              onPressed: () {
                                                _otpController.clear();
                                                setState(() {
                                                  _isOtpSent = false;
                                                  _hasOtpError = false;
                                                });
                                              },
                                              icon: const Icon(Icons.edit_rounded, size: 15),
                                              label: Text(
                                                langState.isHindi ? 'नंबर बदलें' : 'Change Phone Number',
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.verified_user_rounded,
                                          size: 16,
                                          color: AppTheme.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          langState.isHindi
                                              ? '100% सुरक्षित और 1-क्लिक ओटीपी लॉगिन'
                                              : '100% Secure & Fast OTP Sign In',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textSecondary,
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
      ),
    );
  }
}
