import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/broker_auth_provider.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';
import '../widgets/common/app_loader_widget.dart';
import 'email_signup_page.dart';
import 'reset_password_page.dart';
import 'auth_gate_page.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Clear any stale auth error from a previous screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrokerAuthProvider>().clearError();
    });
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      BrokerAuthProvider.isValidEmail(_emailController.text) &&
      _passwordController.text.isNotEmpty;

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final brokerAuth = context.read<BrokerAuthProvider>();
    final success = await brokerAuth.loginWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGatePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(brokerAuth.errorMessage ?? 'Login failed'),
        ),
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
              AppStrings.emailLoginTitle,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.emailLoginSubtitle,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Email
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

            // Password
            _label(AppStrings.passwordLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              cursorColor: theme.primaryPurple,
              decoration: _fieldDecoration(
                theme,
                hint: '••••••••',
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
            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResetPasswordPage(
                      initialEmail: _emailController.text.trim().isEmpty
                          ? null
                          : _emailController.text.trim(),
                    ),
                  ),
                ),
                child: Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    color: theme.primaryPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              child: _canSubmit
                  ? PrimaryGradientButton(
                      text: AppStrings.loginButton,
                      onTap: _handleLogin,
                    )
                  : SecondaryGrayButton(
                      text: AppStrings.loginButton,
                      onTap: _handleLogin,
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

  InputDecoration _fieldDecoration(
    ThemeManager theme, {
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey600),
      suffixIcon: suffix,
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
