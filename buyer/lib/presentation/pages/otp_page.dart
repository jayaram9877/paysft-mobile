import 'package:buyer/presentation/pages/select_location_type_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../providers/auth_provider.dart';
import 'package:buyer/presentation/widgets/common/app_loader_widget.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  const OTPPage({super.key, required this.phoneNumber});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isVerifying = false;
  bool _isApiInitiated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOTPForUser(otp, widget.phoneNumber);

    if (!mounted) return;

    setState(() => _isVerifying = false);

    if (success) {
      Navigator.of(
        context,
      ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SelectLocatioTypePage()), (route) => false);
      _isApiInitiated = false;
    } else {
      final message = authProvider.errorMessage ?? AppStrings.invalidOtp;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _isApiInitiated = false;
    }
  }

  Widget _buildIOSOtpBox(int index, ThemeManager themeManager) {
    final text = _otpController.text.replaceAll(RegExp(r'[^\d]'), '');
    final hasValue = index < text.length;
    final isActive =
        index == text.length && text.length < 6; // The next box to be filled is active (only if not all filled)

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: (MediaQuery.of(context).size.width - 40 - (12 * 6)) / 6,
      height: 64,
      child: isActive
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [AppColors.primaryCyan, AppColors.primaryPurpleBright],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(2), // Border width
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.backgroundWhite),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey600, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: hasValue ? AppColors.primaryBlueIOS : AppColors.grey300, width: 2),
                color: AppColors.backgroundWhite,
              ),
              child: Center(
                child: !hasValue
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.grey600, width: 2),
                        ),
                      )
                    : Text(hasValue ? text[index] : "", style: themeManager.otpBoxTextStyle),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    String formatted = widget.phoneNumber;

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
              Text(AppStrings.back, style: themeManager.phoneLoginBackButtonTextStyle),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    SvgPicture.asset("assets/images/shield.svg", width: 40, height: 40),
                    const SizedBox(height: 20),
                    Text(AppStrings.enterCode, style: themeManager.otpPageTitleStyle),
                    const SizedBox(height: 10),
                    Text(AppStrings.otpDescription, style: themeManager.otpPageDescriptionStyle),
                    const SizedBox(height: 4),
                    Text(formatted, style: themeManager.otpPagePhoneNumberStyle),
                    const SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: () => _otpFocusNode.requestFocus(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(6, (i) => _buildIOSOtpBox(i, themeManager)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: AppStrings.dontReceiveCode,
                              style: TextStyle(color: AppColors.textTertiary, fontSize: 15),
                              children: [
                                TextSpan(
                                  text: AppStrings.sendAgain,
                                  style: TextStyle(
                                    color: themeManager.textLinks,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final authProvider = context.read<AuthProvider>();
                                      if (widget.phoneNumber.isNotEmpty) {
                                        await authProvider.sendOTPToUser(widget.phoneNumber);
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(const SnackBar(content: Text(AppStrings.otpResent)));
                                        }
                                      }
                                    },
                                ),
                              ],
                            ),
                          ),
                          if (_isVerifying) ...[
                            const SizedBox(height: 100),
                            const SizedBox(width: 40, height: 40, child: AppLoaderWidget()),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          ),
          // Hidden TextField to trigger system numeric keyboard for OTP entry
          Offstage(
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (value) {
                setState(() {});
                if (value.length == 6 && !_isApiInitiated) {
                  _isApiInitiated = true;
                  Future.microtask(_handleVerify);
                } else if (value.length < 6) {
                  _isApiInitiated = false;
                }
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}
