import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../pages/email_login_page.dart';
import '../pages/mobile_login_page.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';

/// "Login or sign up" method selector shown after onboarding, before the
/// mobile/email auth screens.
class LoginOptionsPage extends StatelessWidget {
  const LoginOptionsPage({super.key});

  // Property image behind the sheet (same source style as onboarding).
  static const String _bgImage =
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800';

  void _continueWithPhone(BuildContext context) {
    // "Continue with Phone" is passwordless login: enter mobile → verify the
    // SMS code → signed in. New users sign up via the "Sign up" link there.
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MobileLoginPage()),
    );
  }

  void _continueWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmailLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.network(
              _bgImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.grey300),
            ),
          ),

          // Bottom sheet card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Close button (top-left)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEFEFF1),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        AppStrings.loginOrSignUp,
                        textAlign: TextAlign.center,
                        style: theme.headingStyle.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        AppStrings.loginDescription,
                        textAlign: TextAlign.center,
                        style: theme.bodyStyle.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Continue with Phone (gradient)
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryGradientButton(
                          text: AppStrings.continueWithPhone,
                          onTap: () => _continueWithPhone(context),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Continue with Email (outlined)
                      SizedBox(
                        width: double.infinity,
                        child: SecondaryGrayButton(
                          text: AppStrings.continueWithEmail,
                          onTap: () => _continueWithEmail(context),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Terms & privacy
                      _buildTermsText(theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText(ThemeManager theme) {
    final baseStyle = theme.bodyStyle.copyWith(
      color: AppColors.textTertiary,
      fontSize: 13,
      height: 1.4,
    );
    final linkStyle = baseStyle.copyWith(
      color: AppColors.textSecondary,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'If you are creating a new account,\n'),
          TextSpan(text: AppStrings.termsAndConditions, style: linkStyle),
          const TextSpan(text: ' and '),
          TextSpan(text: AppStrings.privacyPolicy, style: linkStyle),
          const TextSpan(text: ' will apply'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
