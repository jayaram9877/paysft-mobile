import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';
import '../providers/signup_provider.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/app_loader_widget.dart';
import '../widgets/primary_blue_button.dart';
import '../widgets/secondary_gray_button.dart';
import 'select_location_type_page.dart';

/// Second step of buyer signup — verifies the email OTP and the mobile OTP
/// (the backend sends both). Uses the [SignupProvider] instance created on the
/// signup screen. On success the user is logged in and continues to the
/// location step, same as phone login.
class VerifyContactPage extends StatefulWidget {
  const VerifyContactPage({super.key});

  @override
  State<VerifyContactPage> createState() => _VerifyContactPageState();
}

class _VerifyContactPageState extends State<VerifyContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOtpController = TextEditingController();
  final _mobileOtpController = TextEditingController();

  @override
  void dispose() {
    _emailOtpController.dispose();
    _mobileOtpController.dispose();
    super.dispose();
  }

  String? _validateOtp(String? value) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) return AppStrings.otpRequired;
    if (cleaned.length != 6) return AppStrings.otpMustHave6Digits;
    return null;
  }

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SignupProvider>();
    final success = await provider.verify(
      emailOtp: _emailOtpController.text.trim(),
      mobileOtp: _mobileOtpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SelectLocatioTypePage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? AppStrings.somethingWentWrong),
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    final provider = context.read<SignupProvider>();
    final error = await provider.resend();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? AppStrings.codesResent)),
    );
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
                    SvgPicture.asset('assets/images/shield.svg',
                        width: 40, height: 40),
                    const SizedBox(height: 20),
                    Text(AppStrings.verifyDetailsTitle,
                        style: theme.otpPageTitleStyle),
                    const SizedBox(height: 10),
                    Text(AppStrings.verifyDetailsSubtitle,
                        style: theme.otpPageDescriptionStyle),
                    const SizedBox(height: 6),
                    if (provider.email.isNotEmpty)
                      Text(provider.email,
                          style: theme.otpPagePhoneNumberStyle),
                    if (provider.mobile.isNotEmpty)
                      Text(
                        '${AppStrings.countryCodeIndia}${provider.mobile}',
                        style: theme.otpPagePhoneNumberStyle,
                      ),
                    const SizedBox(height: 28),

                    Text(AppStrings.emailCodeLabel,
                        style: theme.phoneLoginDescriptionStyle),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _emailOtpController,
                      hintText: '••••••',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateOtp,
                    ),
                    const SizedBox(height: 12),

                    Text(AppStrings.mobileCodeLabel,
                        style: theme.phoneLoginDescriptionStyle),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _mobileOtpController,
                      hintText: '••••••',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateOtp,
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.dontReceiveCode,
                          style: const TextStyle(
                              color: AppColors.textTertiary, fontSize: 15),
                          children: [
                            TextSpan(
                              text: AppStrings.sendAgain,
                              style: TextStyle(
                                color: theme.textLinks,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = provider.isBusy ? null : _handleResend,
                            ),
                          ],
                        ),
                      ),
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
                          text: AppStrings.verifyButton,
                          onTap: () {},
                          backgroundColor: AppColors.buttonDisabledBackground,
                          textColor:
                              AppColors.buttonDisabledText.withOpacity(0.3),
                        )
                      : PrimaryGradientButton(
                          text: AppStrings.verifyButton,
                          onTap: _handleVerify,
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
