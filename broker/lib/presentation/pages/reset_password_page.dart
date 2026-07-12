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

class ResetPasswordPage extends StatefulWidget {
  /// Optionally prefill the email (e.g. from the login screen).
  final String? initialEmail;
  const ResetPasswordPage({super.key, this.initialEmail});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _codeSent = false; // view state: stage 1 -> stage 2

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) _emailController.text = widget.initialEmail!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrokerAuthProvider>().clearError();
    });
    for (final c in [_emailController, _otpController, _passwordController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSendCode =>
      BrokerAuthProvider.isValidEmail(_emailController.text);

  bool get _canReset =>
      _otpController.text.length == 6 &&
      BrokerAuthProvider.isValidPassword(_passwordController.text);

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    final brokerAuth = context.read<BrokerAuthProvider>();
    final ok = await brokerAuth.requestPasswordReset(_emailController.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.otpResent)),
      );
    } else {
      _showError(brokerAuth.errorMessage);
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    final brokerAuth = context.read<BrokerAuthProvider>();
    final ok = await brokerAuth.confirmPasswordReset(
      email: _emailController.text,
      otp: _otpController.text,
      newPassword: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.resetPasswordSuccess)),
      );
      Navigator.of(context).pop(); // back to login
    } else {
      _showError(brokerAuth.errorMessage);
    }
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Something went wrong')),
    );
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
              AppStrings.resetPasswordTitle,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _codeSent
                  ? AppStrings.resetPasswordConfirmSubtitle
                  : AppStrings.resetPasswordRequestSubtitle,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Email (always shown; locked once the code is sent)
            _label(AppStrings.emailLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              enabled: !_codeSent,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              cursorColor: theme.primaryPurple,
              decoration: _fieldDecoration(theme, hint: 'you@example.com'),
            ),

            if (_codeSent) ...[
              const SizedBox(height: 18),
              _label(AppStrings.codeLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                cursorColor: theme.primaryPurple,
                decoration: _fieldDecoration(
                  theme,
                  hint: '6-digit code',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 18),
              _label(AppStrings.newPasswordLabel),
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
            ],

            const SizedBox(height: 32),

            // Primary action (changes by stage)
            SizedBox(
              width: double.infinity,
              child: _codeSent
                  ? (_canReset
                      ? PrimaryGradientButton(
                          text: AppStrings.resetPasswordButton,
                          onTap: _resetPassword,
                        )
                      : _disabledButton(AppStrings.resetPasswordButton, _resetPassword))
                  : (_canSendCode
                      ? PrimaryGradientButton(
                          text: AppStrings.sendCodeButton,
                          onTap: _sendCode,
                        )
                      : _disabledButton(AppStrings.sendCodeButton, _sendCode)),
            ),

            if (_codeSent) ...[
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: isLoading ? null : _sendCode,
                  child: Text.rich(
                    TextSpan(
                      text: AppStrings.dontReceiveCode,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: AppStrings.sendAgain,
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
            ],

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

  Widget _disabledButton(String text, VoidCallback onTap) => SecondaryGrayButton(
        text: text,
        onTap: onTap,
        backgroundColor: AppColors.buttonDisabledBackground,
        textColor: AppColors.buttonDisabledText,
      );

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
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey600),
      suffixIcon: suffix,
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200, width: 1.5),
      ),
    );
  }
}
