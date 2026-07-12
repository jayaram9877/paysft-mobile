import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/broker_auth_provider.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';
import '../widgets/common/app_loader_widget.dart';
import 'email_signup_page.dart';
import 'mobile_login_otp_page.dart';

/// Passwordless mobile login: enter mobile number → request an SMS code →
/// the next screen verifies it and signs in.
class MobileLoginPage extends StatefulWidget {
  const MobileLoginPage({super.key});

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrokerAuthProvider>().clearError();
    });
    _mobileController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      BrokerAuthProvider.isValidMobile(_mobileController.text.trim());

  Future<void> _handleContinue() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<BrokerAuthProvider>();
    final mobile = _mobileController.text.trim();
    final ok = await auth.requestMobileLoginOtp(mobile);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MobileLoginOtpPage(phoneNumber: '+91 $mobile'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not send code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    final isLoading = context.watch<BrokerAuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leadingWidth: 120,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.primaryBlueIOS),
              SizedBox(width: 4),
              Text(
                AppStrings.back,
                style: TextStyle(
                  fontSize: 17,
                  color: AppColors.primaryBlueIOS,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Login with mobile',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your registered mobile number and we'll send you a "
              'verification code.',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            _label(AppStrings.mobileLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              cursorColor: theme.primaryPurple,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: '9876543210',
                hintStyle: const TextStyle(color: AppColors.grey600),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Text(
                    '+91',
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                filled: true,
                fillColor: AppColors.backgroundWhite,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.grey300, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: _canSubmit
                  ? PrimaryGradientButton(
                      text: 'Send Code',
                      onTap: _handleContinue,
                    )
                  : SecondaryGrayButton(
                      text: 'Send Code',
                      onTap: _handleContinue,
                      backgroundColor: AppColors.buttonDisabledBackground,
                      textColor: AppColors.buttonDisabledText,
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmailSignupPage()),
                ),
                child: Text.rich(
                  TextSpan(
                    text: AppStrings.dontHaveAccount,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: AppStrings.signUpLink,
                        style: TextStyle(
                          color: theme.primaryPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: AppLoaderWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
}
