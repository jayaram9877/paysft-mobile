import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/theme/theme_manager.dart';
import '../../core/utils/input_validator.dart';
import '../providers/signup_provider.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/app_loader_widget.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';
import 'verify_contact_page.dart';

/// Buyer self-signup — collects the details the backend requires
/// (email + password + full name + mobile), then routes to the dual-OTP
/// verification screen. Shares one [SignupProvider] instance with that screen.
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignupProvider>(
      create: (_) => di.sl<SignupProvider>(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SignupProvider>();
    final success = await provider.submitSignup(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
      mobile: _mobileController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: const VerifyContactPage(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? AppStrings.somethingWentWrong),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    final provider = context.watch<SignupProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leadingWidth: 120,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.primaryBlueIOS),
              const SizedBox(width: 4),
              Text(AppStrings.back, style: theme.phoneLoginBackButtonTextStyle),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.createAccount,
                        style: theme.phoneLoginTitleStyle),
                    const SizedBox(height: 10),
                    Text(AppStrings.createAccountSubtitle,
                        style: theme.phoneLoginDescriptionStyle),
                    const SizedBox(height: 28),

                    AppTextFormField(
                      controller: _nameController,
                      labelText: AppStrings.fullNameFieldLabel,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => InputValidator.validateRequired(
                          v, AppStrings.fullNameFieldLabel),
                    ),
                    const SizedBox(height: 16),

                    AppTextFormField(
                      controller: _emailController,
                      labelText: AppStrings.emailFieldLabel,
                      keyboardType: TextInputType.emailAddress,
                      validator: InputValidator.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    AppTextFormField(
                      controller: _passwordController,
                      labelText: AppStrings.passwordFieldLabel,
                      obscureText: _obscurePassword,
                      validator: InputValidator.validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 16),

                    AppTextFormField(
                      controller: _mobileController,
                      labelText: AppStrings.phoneFieldLabel,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 4),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            AppStrings.countryCodeIndia.trim(),
                            style: theme.phoneLoginInputTextStyle,
                          ),
                        ),
                      ),
                      validator: InputValidator.validateIndianPhoneNumber,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isBusy) ...[
                  const SizedBox(
                      width: 40, height: 40, child: AppLoaderWidget()),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: provider.isBusy
                      ? SecondaryGrayButton(
                          text: AppStrings.createAccount,
                          onTap: () {},
                          backgroundColor: AppColors.buttonDisabledBackground,
                          textColor:
                              AppColors.buttonDisabledText.withOpacity(0.3),
                        )
                      : PrimaryGradientButton(
                          text: AppStrings.createAccount,
                          onTap: _handleSignup,
                        ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: provider.isBusy ? null : () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      style: theme.phoneLoginTermsTextStyle,
                      children: [
                        TextSpan(text: AppStrings.alreadyHaveAccount),
                        TextSpan(
                          text: AppStrings.logIn,
                          style: theme.phoneLoginTermsLinkStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
