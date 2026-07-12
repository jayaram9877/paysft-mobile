import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../providers/broker_auth_provider.dart';
import 'auth_gate_page.dart';
import 'package:broker/presentation/widgets/common/app_loader_widget.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  const OTPPage({super.key, required this.phoneNumber});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  // Two separate 6-digit codes: one sent to email, one sent over SMS.
  String _emailOtp = '';
  String _mobileOtp = '';
  // Which code the keypad currently types into: 0 = email, 1 = mobile.
  int _active = 0;
  // Guard so the auto-verify fires only once both codes are complete.
  bool _isApiInitiated = false;

  bool get _bothComplete => _emailOtp.length == 6 && _mobileOtp.length == 6;

  void _onKeypadPressed(String value) {
    if (value == 'backspace') {
      if (_active == 0 && _emailOtp.isNotEmpty) {
        _emailOtp = _emailOtp.substring(0, _emailOtp.length - 1);
      } else if (_active == 1 && _mobileOtp.isNotEmpty) {
        _mobileOtp = _mobileOtp.substring(0, _mobileOtp.length - 1);
      }
    } else if (RegExp(r'^\d$').hasMatch(value)) {
      if (_active == 0 && _emailOtp.length < 6) {
        _emailOtp += value;
        // Jump to the mobile field once the email code is filled.
        if (_emailOtp.length == 6 && _mobileOtp.length < 6) _active = 1;
      } else if (_active == 1 && _mobileOtp.length < 6) {
        _mobileOtp += value;
      }
    }
    setState(() {});

    if (_bothComplete && !_isApiInitiated) {
      _isApiInitiated = true;
      Future.microtask(_handleVerify);
    }
  }

  Future<void> _handleVerify() async {
    if (!_bothComplete) return;
    final brokerAuth = context.read<BrokerAuthProvider>();
    final success = await brokerAuth.verifyAndRegister(_emailOtp, _mobileOtp);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGatePage()),
        (route) => false,
      );
      _isApiInitiated = false;
    } else {
      setState(() {
        _emailOtp = '';
        _mobileOtp = '';
        _active = 0;
        _isApiInitiated = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(brokerAuth.errorMessage ?? AppStrings.invalidOtp),
        ),
      );
    }
  }

  Widget _buildOtpBox(String code, int index, bool rowActive) {
    final hasValue = index < code.length;
    final isCursor = rowActive && index == code.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: (MediaQuery.of(context).size.width - 40 - (10 * 6)) / 6,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: hasValue || isCursor
              ? AppColors.primaryBlueIOS
              : AppColors.grey300,
          width: 2,
        ),
        color: AppColors.backgroundWhite,
      ),
      child: Center(
        child: !hasValue
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey600, width: 2),
                ),
              )
            : Text(
                code[index],
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
      ),
    );
  }

  Widget _otpSection({
    required String label,
    required String destination,
    required String code,
    required int fieldIndex,
  }) {
    final rowActive = _active == fieldIndex;
    return GestureDetector(
      onTap: () => setState(() => _active = fieldIndex),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  destination,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (code.length == 6)
                const Icon(Icons.check_circle,
                    size: 18, color: AppColors.primaryBlueIOS),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children:
                List.generate(6, (i) => _buildOtpBox(code, i, rowActive)),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String value) {
    final isBackspace = value == 'backspace';
    final isSpecial = value == '+*#';
    return InkWell(
      onTap: () => _onKeypadPressed(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: isBackspace ? 60 : 80,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isBackspace ? AppColors.backgroundWhite : Colors.transparent,
        ),
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 24)
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: isSpecial ? 16 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildKeypadButton(k)).toList(),
    );
  }

  Widget _buildKeypadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildKeypadRow(['+*#', '0', 'backspace']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final brokerAuth = context.watch<BrokerAuthProvider>();
    final bool isVerifying = brokerAuth.isLoading;
    final email = brokerAuth.email.isNotEmpty ? brokerAuth.email : 'your email';
    final mobile = brokerAuth.mobile ?? widget.phoneNumber;

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
                    SvgPicture.asset("assets/images/shield.svg",
                        width: 40, height: 40),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.enterCode,
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We sent a 6-digit code to both your email and mobile. '
                      'Enter both to continue.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _otpSection(
                      label: 'Email',
                      destination: email,
                      code: _emailOtp,
                      fieldIndex: 0,
                    ),
                    const SizedBox(height: 24),
                    _otpSection(
                      label: 'Mobile',
                      destination: mobile,
                      code: _mobileOtp,
                      fieldIndex: 1,
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: AppStrings.dontReceiveCode,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: AppStrings.sendAgain,
                              style: TextStyle(
                                color: themeManager.primaryBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final auth =
                                      context.read<BrokerAuthProvider>();
                                  final ok = await auth.resend();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? AppStrings.otpResent
                                              : (auth.errorMessage ??
                                                  'Could not resend code'),
                                        ),
                                      ),
                                    );
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isVerifying) ...[
                      const SizedBox(height: 40),
                      const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: AppLoaderWidget(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (!isVerifying) _buildKeypadSection(),
          ],
        ),
      ),
    );
  }
}
