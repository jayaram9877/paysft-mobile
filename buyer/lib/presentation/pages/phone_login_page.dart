import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:buyer/presentation/widgets/secondary_gray_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/utils/input_validator.dart';
import '../../core/utils/phone_input_formatter.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/gradient_border_input.dart';
import 'otp_page.dart';
import 'signup_page.dart';
import 'package:buyer/presentation/widgets/common/app_loader_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TapGestureRecognizer _termsTapRecognizer;

  bool _hasError = false;
  String? _errorText;
  bool _isLoading = false; // added loading state

  @override
  void initState() {
    super.initState();
    _termsTapRecognizer = TapGestureRecognizer();

    // Auto-focus input field and show keyboard when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _termsTapRecognizer.dispose();
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isValidNumber() {
    final cleaned = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) {
      return false; // 10 digits
    }

    // Use comprehensive validation
    final validationError = InputValidator.validateIndianPhoneNumber(cleaned);
    return validationError == null;
  }

  // ---------------------------------------------------------------------------
  // HANDLE CONTINUE
  // ---------------------------------------------------------------------------
  Future<void> _handleContinue() async {
    if (_isLoading) return; // prevent duplicate taps while request in-flight
    FocusScope.of(context).unfocus();

    final cleaned = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) {
      setState(() {
        _hasError = true;
        _errorText = AppStrings.phoneNumberMustHave10Digits;
      });
      return;
    }

    final phoneNumber = cleaned;
    final validationError = InputValidator.validateIndianPhoneNumber(phoneNumber);
    if (validationError != null) {
      setState(() {
        _hasError = true;
        _errorText = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true; // show loader
    });

    final phone = phoneNumber;

    final auth = context.read<AuthProvider>();
    final success = await auth.sendOTPToUser(phone);

    if (!mounted) return;

    setState(() {
      _isLoading = false; // hide loader
    });

    if (!success) {
      setState(() {
        _hasError = true;
        _errorText = auth.errorMessage ?? AppStrings.somethingWentWrong;
      });
      return;
    }

    final displayPhoneNumber = '${AppStrings.countryCodeIndia}${_phoneController.text}'.trimRight();
    Navigator.push(context, MaterialPageRoute(builder: (_) => OTPPage(phoneNumber: displayPhoneNumber)));
  }

  void _navigateToHome() => _handleContinue();

  // ---------------------------------------------------------------------------
  // TERMS & CONDITIONS MODAL
  // ---------------------------------------------------------------------------
  void _showTermsAndConditions(BuildContext context) {
    // Unfocus to hide keyboard temporarily
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        final themeManager = ThemeManager();
        final screenHeight = MediaQuery.of(context).size.height;
        final modalHeight = screenHeight * 0.8;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            height: modalHeight,
            decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                // Header with title and close button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.borderGrayMedium, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.termsAndConditions,
                          textAlign: TextAlign.left,
                          style: themeManager.termsAndConditionsTitleStyle,
                        ),
                      ),
                      ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 27.18, sigmaY: 27.18),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.systemBackgroundLightSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: AppColors.closeButtonIconColor, size: 18),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                // Reactivate keyboard after closing
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted && !_focusNode.hasFocus) {
                                    _focusNode.requestFocus();
                                  }
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Text(_getTermsAndConditionsText(), style: themeManager.termsAndConditionsDescriptionStyle),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Reactivate keyboard after dialog closes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  String _getTermsAndConditionsText() {
    return '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.

Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.

Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.

At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.

Similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio.

Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus.

Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus.
''';
  }

  // ---------------------------------------------------------------------------
  // UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>();
    // Border is active when: focused, has content, or is valid
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
              Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primaryBlueIOS),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/images/call_outline.svg'),
                  const SizedBox(height: 12),
                  Text(AppStrings.yourPhoneNumber, style: theme.phoneLoginTitleStyle),
                  const SizedBox(height: 10),
                  Text(AppStrings.phoneNumberDescription, style: theme.phoneLoginDescriptionStyle),
                  const SizedBox(height: 32),

                  // PHONE FIELD
                  GradientBorderInput(
                    borderRadius: 12,
                    hasError: _hasError,
                    focusNode: _focusNode,
                    child: TextField(
                      controller: _phoneController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.phone,
                      showCursor: true,
                      cursorColor: theme.primaryPurple,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        IndiaMobileNumberFormatter(),
                      ],
                      onChanged: (_) {
                        // Validate using comprehensive Indian phone number validation
                        final cleanedDigits = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
                        final userNumber = cleanedDigits;

                        if (userNumber.isNotEmpty) {
                          // While typing (<10 digits), do NOT show error state.
                          // Showing error changes the input wrapper tree and can cause
                          // some Android keyboards to drop focus on the first digit.
                          if (userNumber.length < 10) {
                            if (_hasError || _errorText != null) {
                              setState(() {
                                _hasError = false;
                                _errorText = null;
                              });
                            }
                            return;
                          }

                          final validationError = InputValidator.validateIndianPhoneNumber(userNumber);
                          if (validationError != null) {
                            setState(() {
                              _hasError = true;
                              _errorText = validationError;
                            });
                          } else {
                            setState(() {
                              _hasError = false;
                              _errorText = null;
                            });
                          }
                        } else {
                          setState(() {
                            _hasError = false;
                            _errorText = null;
                          });
                        }
                      },
                      style: theme.phoneLoginInputTextStyle,
                      decoration: InputDecoration(
                        prefixText: AppStrings.countryCodeIndia,
                        prefixStyle: theme.phoneLoginInputTextStyle,
                        suffixIcon: _hasError ? Icon(Icons.info_outline, color: AppColors.errorRed) : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        filled: true,
                        fillColor: AppColors.backgroundWhite,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(_errorText!, style: theme.phoneLoginErrorTextStyle),
                    ),

                  // GAP + LOADING INDICATOR
                  const SizedBox(height: 100),
                  if (_isLoading) const Center(child: SizedBox(width: 40, height: 40, child: AppLoaderWidget())),
                ],
              ),
            ),
          ),

          // Button section above keyboard (with 20px gap)
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              // Keep a fixed gap above the system keyboard so that
              // the main content remains visible when the keyboard opens.
              bottom: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Terms & Conditions Label
                Center(
                  child: Builder(
                    builder: (context) {
                      _termsTapRecognizer.onTap = () => _showTermsAndConditions(context);
                      return RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.phoneLoginTermsTextStyle,
                          children: [
                            TextSpan(text: AppStrings.byContinuingAcceptTerms),
                            TextSpan(
                              text: AppStrings.termsAndConditions,
                              style: theme.phoneLoginTermsLinkStyle,
                              recognizer: _termsTapRecognizer,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: _isValidNumber() && !_hasError
                      ? PrimaryGradientButton(text: AppStrings.continueButton, onTap: _navigateToHome)
                      : SecondaryGrayButton(
                          text: AppStrings.continueButton,
                          onTap: _navigateToHome,
                          backgroundColor: AppColors.buttonDisabledBackground,
                          textColor: AppColors.buttonDisabledText.withOpacity(0.3),
                        ),
                ),
                const SizedBox(height: 14),

                // New user -> self signup (email + password + mobile)
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.phoneLoginTermsTextStyle,
                      children: [
                        TextSpan(text: AppStrings.dontHaveAccount),
                        TextSpan(
                          text: AppStrings.signUp,
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
