import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/core/utils/input_validator.dart';
import 'package:buyer/presentation/providers/pay_token_provider.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalDetailsStep extends StatefulWidget {
  const PersonalDetailsStep({super.key});

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Store form key in provider when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PayTokenProvider>(context, listen: false);
      provider.setPersonalDetailsFormKey(_formKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final provider = Provider.of<PayTokenProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Escrow Info Card
        _buildEscrowInfoCard(themeManager),
        const SizedBox(height: 16),

        // 3. Personal Details Form Header
        Text(AppStrings.personalDetails, style: themeManager.titleMediumStyle),
        const SizedBox(height: 16),

        // 4. Form Fields
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrayMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  themeManager,
                  label: '${AppStrings.fullNameLabel} *',
                  controller: provider.nameController,
                  isLocked: false,
                  hint: AppStrings.fullNameLabel,
                  validator: (value) => InputValidator.validateRequired(value, AppStrings.fullNameLabel),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: '${AppStrings.emailAddress} *',
                  controller: provider.emailController,
                  isLocked: false,
                  hint: "abc@email.com",
                  validator: InputValidator.validateEmail,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.phoneNumberLabel,
                  controller: provider.phoneController,
                  isLocked: true,
                  hint: "+91 98765 43210",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.panNumber,
                  controller: provider.panController,
                  isLocked: false,
                  hint: "ABCDE1234F",
                  validator: InputValidator.validatePAN,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.aadhaarNumber,
                  controller: provider.aadhaarController,
                  isLocked: false,
                  hint: "1234 5678 9012",
                  validator: InputValidator.validateAadhaar,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.residentialAddress,
                  controller: provider.addressController,
                  isLocked: false,
                  hint: AppStrings.enterCompleteAddress,
                  maxLines: 3,
                  validator: InputValidator.validateAddress,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 5. KYC Verification Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWarningLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warningOrange.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(assetPath: "assets/images/kyc_alert_info_icon.svg", width: 24, height: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.kycVerification,
                      style: themeManager.bodySmallStyle.copyWith(
                        color: AppColors.kycTitle,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.kycVerificationDesc,
                      style: themeManager.captionSmallStyle.copyWith(color: AppColors.kycDescription, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80), // Bottom padding for FAB
      ],
    );
  }

  Widget _buildEscrowInfoCard(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlueVeryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueLight.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(assetPath: "assets/images/escrow_protection_icon.svg", width: 28, height: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.escrowProtectedTransaction,
                  style: themeManager.titleMediumStyle.copyWith(
                    color: AppColors.darkBlueTitle,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.escrowProtectedDesc,
            style: themeManager.captionSmallStyle.copyWith(color: AppColors.textGray, fontSize: 12),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.blueLight),
          ),
          _buildPaymentSummaryCard(themeManager),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blueLight.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(AppStrings.property, "Sobha Dream Acres", themeManager, isBold: true),
          const SizedBox(height: 12),
          _buildSummaryRow(AppStrings.paymentType, AppStrings.tokenPayment, themeManager, isBold: true),
          const SizedBox(height: 12),
          _buildSummaryRow(AppStrings.amount, "₹5,00,000", themeManager, isBold: true, isAmount: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ThemeManager themeManager, {
    bool isBold = false,
    bool isAmount = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrayMedium),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: themeManager.captionSmallStyle.copyWith(color: AppColors.textGray, fontSize: 14)),
          Text(
            value,
            style: themeManager.bodySmallStyle.copyWith(
              color: AppColors.textBlack,
              fontSize: isAmount ? 16 : 14,
              fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    ThemeManager themeManager, {
    required String label,
    required TextEditingController controller,
    required bool isLocked,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: themeManager.captionSmallStyle.copyWith(
            color: AppColors.textGray90,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 14 / 15,
            letterSpacing: -0.15,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isLocked,
          maxLines: maxLines,
          validator: isLocked ? null : validator,
          style: themeManager.bodySmallStyle.copyWith(
            color: isLocked ? AppColors.textGray : AppColors.textGray79,
            fontSize: 17,
            fontWeight: FontWeight.w400,
            height: 1,
          ),
          decoration: themeManager
              .textFieldDecoration(
                hintText: hint,
                suffixIcon: isLocked
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AppSvgIcon(
                          assetPath: "assets/images/textfield_suffix_lock.svg",
                          width: 16,
                          height: 16,
                          color: AppColors.gray400,
                        ),
                      )
                    : null,
                borderColor: isLocked ? AppColors.gray200 : AppColors.borderGrayMedium,
              )
              .copyWith(fillColor: isLocked ? AppColors.gray50 : Colors.white),
        ),
      ],
    );
  }
}
