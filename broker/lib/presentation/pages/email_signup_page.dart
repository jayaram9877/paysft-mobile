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
import 'otp_page.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({super.key});

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrokerAuthProvider>().clearError();
    });
    for (final c in [
      _nameController,
      _emailController,
      _mobileController,
      _passwordController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      BrokerAuthProvider.isValidEmail(_emailController.text) &&
      BrokerAuthProvider.isValidMobile(_mobileController.text) &&
      BrokerAuthProvider.isValidPassword(_passwordController.text);

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    final brokerAuth = context.read<BrokerAuthProvider>();
    final success = await brokerAuth.signupWithEmail(
      fullName: _nameController.text,
      email: _emailController.text,
      tenDigitMobile: _mobileController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OTPPage(phoneNumber: '+91 ${_mobileController.text}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(brokerAuth.errorMessage ?? 'Sign up failed')),
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
              AppStrings.signupTitle,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.signupSubtitle,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            _label(AppStrings.fullNameLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              cursorColor: theme.primaryPurple,
              decoration: _fieldDecoration(theme, hint: 'John Doe'),
            ),
            const SizedBox(height: 18),

            _label(AppStrings.emailLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              cursorColor: theme.primaryPurple,
              decoration: _fieldDecoration(theme, hint: 'you@example.com'),
            ),
            const SizedBox(height: 18),

            _label(AppStrings.mobileLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: theme.primaryPurple,
              decoration: _fieldDecoration(
                theme,
                hint: '9876543210',
                counterText: '',
                prefix: const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Text(
                    '+91',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            _label(AppStrings.passwordLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              cursorColor: theme.primaryPurple,
              decoration: _fieldDecoration(
                theme,
                hint: 'At least 8 characters',
                suffix: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey600,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: _canSubmit
                  ? PrimaryGradientButton(
                      text: AppStrings.signupButton,
                      onTap: _handleSignup,
                    )
                  : SecondaryGrayButton(
                      text: AppStrings.signupButton,
                      onTap: _handleSignup,
                      backgroundColor: AppColors.buttonDisabledBackground,
                      textColor: AppColors.buttonDisabledText,
                    ),
            ),

            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text.rich(
                  TextSpan(
                    text: AppStrings.alreadyHaveAccount,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: AppStrings.loginLink,
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

  InputDecoration _fieldDecoration(
    ThemeManager theme, {
    required String hint,
    Widget? suffix,
    Widget? prefix,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey600),
      suffixIcon: suffix,
      prefixIcon: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                widthFactor: 1,
                alignment: Alignment.centerLeft,
                child: prefix,
              ),
            ),
      counterText: counterText,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      filled: true,
      fillColor: AppColors.backgroundWhite,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryPurple, width: 2),
      ),
    );
  }
}
