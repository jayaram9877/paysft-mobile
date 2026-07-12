import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../providers/broker_auth_provider.dart';
import 'auth_gate_page.dart';
import 'package:broker/presentation/widgets/common/app_loader_widget.dart';

/// Verifies the SMS login code for passwordless mobile login.
class MobileLoginOtpPage extends StatefulWidget {
  final String phoneNumber;
  const MobileLoginOtpPage({super.key, required this.phoneNumber});

  @override
  State<MobileLoginOtpPage> createState() => _MobileLoginOtpPageState();
}

class _MobileLoginOtpPageState extends State<MobileLoginOtpPage> {
  String _otp = '';
  bool _isApiInitiated = false;

  void _onKeypadPressed(String value) {
    if (value == 'backspace') {
      if (_otp.isNotEmpty) _otp = _otp.substring(0, _otp.length - 1);
    } else if (RegExp(r'^\d$').hasMatch(value) && _otp.length < 6) {
      _otp += value;
    }
    setState(() {});
    if (_otp.length == 6 && !_isApiInitiated) {
      _isApiInitiated = true;
      Future.microtask(_handleVerify);
    }
  }

  Future<void> _handleVerify() async {
    if (_otp.length != 6) return;
    final auth = context.read<BrokerAuthProvider>();
    final success = await auth.verifyMobileLoginOtp(_otp);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGatePage()),
        (route) => false,
      );
      _isApiInitiated = false;
    } else {
      setState(() {
        _otp = '';
        _isApiInitiated = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? AppStrings.invalidOtp)),
      );
    }
  }

  Widget _buildOtpBox(int index) {
    final hasValue = index < _otp.length;
    final isCursor = index == _otp.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: (MediaQuery.of(context).size.width - 40 - (12 * 6)) / 6,
      height: 64,
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
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey600, width: 2),
                ),
              )
            : Text(
                _otp[index],
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
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
    final auth = context.watch<BrokerAuthProvider>();
    final bool isVerifying = auth.isLoading;

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
                    const SizedBox(height: 10),
                    const Text(
                      'Enter the 6-digit code sent to your mobile',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.phoneNumber,
                      style: TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontFamily: AppStrings.fontFamilyMedium,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(6, (i) => _buildOtpBox(i)),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                color: AppColors.primaryBlueIOS,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final a = context.read<BrokerAuthProvider>();
                                  final ok = await a.resendMobileLoginOtp();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? AppStrings.otpResent
                                            : (a.errorMessage ??
                                                'Could not resend code')),
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
