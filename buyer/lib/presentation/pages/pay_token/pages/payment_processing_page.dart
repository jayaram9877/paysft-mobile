import 'dart:async';
import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/pages/pay_token/payment_success_page.dart';
import 'package:flutter/material.dart';

class PaymentProcessingPage extends StatefulWidget {
  const PaymentProcessingPage({super.key});

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage> {
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    // Step 1: Verifying details
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 1);

    // Step 2: Connecting to bank
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 2);

    // Step 3: Processing
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 3); // Finished

    // Navigate to Success
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PaymentSuccessPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // White background for cleaner look as per design
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Empty app bar just for status bar handling or back button if needed (usually disable back here)
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big Blue Shield Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: AppColors.bluePrimary.withOpacity(0.1), shape: BoxShape.circle),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 60, color: AppColors.bluePrimary),
                    // If we want a checkmark inside, we can layer it, but the icon is sufficient
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(AppStrings.processingPayment, style: themeManager.titleStyle.copyWith(color: AppColors.textBlack)),
              const SizedBox(height: 12),
              Text(
                AppStrings.processingDesc,
                textAlign: TextAlign.center,
                style: themeManager.bodySmallStyle.copyWith(color: AppColors.textGray),
              ),
              const SizedBox(height: 48),

              // Steps
              _buildStepItem(0, AppStrings.verifyingDetails, themeManager),
              const SizedBox(height: 16),
              _buildStepItem(1, AppStrings.connectingToBank, themeManager),
              const SizedBox(height: 16),
              _buildStepItem(2, AppStrings.processingTransaction, themeManager),

              const SizedBox(height: 48),
              // Spinner
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(color: AppColors.bluePrimary, strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int index, String text, ThemeManager themeManager) {
    bool isActive = _currentStep == index;
    bool isCompleted = _currentStep > index;

    Color iconColor = isCompleted
        ? AppColors.successGreen
        : (isActive ? AppColors.bluePrimary : AppColors.textGray.withOpacity(0.3));
    Color textColor = isCompleted || isActive ? AppColors.textBlack : AppColors.textGray;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: themeManager.bodySmallStyle.copyWith(color: textColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
