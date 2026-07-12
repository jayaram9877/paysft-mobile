import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/core/utils/input_validator.dart';
import 'package:buyer/presentation/providers/pay_token_provider.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NomineeDetailsStep extends StatefulWidget {
  const NomineeDetailsStep({super.key});

  @override
  State<NomineeDetailsStep> createState() => _NomineeDetailsStepState();
}

class _NomineeDetailsStepState extends State<NomineeDetailsStep> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PayTokenProvider>(context, listen: false);
      provider.setNomineeDetailsFormKey(_formKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final provider = Provider.of<PayTokenProvider>(context);

    // Placeholder data - in real app would come from provider controllers
    const propertyInfo = "Sobha Dream Acres";
    const amount = "₹5,00,000";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Escrow Protected Transaction Card (With integrated Payment Summary) - The "Top Section"
        _buildEscrowInfoCard(themeManager, propertyInfo, amount),
        const SizedBox(height: 24),

        // 2. Form Title
        Text(AppStrings.nomineeDetails, style: themeManager.titleMediumStyle),
        const SizedBox(height: 16),

        // 3. Form Fields
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
                  label: AppStrings.nomineeFullName,
                  controller: provider.nomineeNameController,
                  hint: AppStrings.enterNomineeName,
                  validator: (value) => InputValidator.validateRequired(value, AppStrings.nomineeFullName),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.relationshipWithNominee,
                  controller: provider.nomineeRelationController,
                  hint: AppStrings.enterRelationship,
                  validator: (value) => InputValidator.validateRequired(value, AppStrings.relationshipWithNominee),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.nomineePhoneNumber,
                  controller: provider.nomineePhoneController,
                  hint: "+91 98765 43210",
                  keyboardType: TextInputType.phone,
                  validator: InputValidator.validatePhoneNumber,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  themeManager,
                  label: AppStrings.nomineeEmail,
                  controller: provider.nomineeEmailController,
                  hint: "nominee@email.com",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    return InputValidator.validateEmail(value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 4. Why Nominee Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlueVeryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blueLight.withOpacity(0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSvgIcon(assetPath: "assets/images/nominee_alert_info_icon.svg", width: 28, height: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.whyNominee,
                      style: themeManager.bodySmallStyle.copyWith(
                        color: AppColors.darkBlueTitle,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.whyNomineeDesc,
                      style: themeManager.captionSmallStyle.copyWith(color: AppColors.darkBlueTitle, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEscrowInfoCard(ThemeManager themeManager, String propertyInfo, String amount) {
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

          // Integrated Payment Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrayMedium),
            ),
            child: Column(
              children: [
                _buildSummaryRow(AppStrings.property, propertyInfo, themeManager, isBold: true),
                const SizedBox(height: 12),
                _buildSummaryRow(AppStrings.paymentType, AppStrings.tokenPayment, themeManager, isBold: true),
                const SizedBox(height: 12),
                _buildSummaryRow(AppStrings.amount, amount, themeManager, isBold: true, isAmount: true),
              ],
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
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: themeManager.formLabelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: themeManager.formInputTextStyle,
          decoration: themeManager
              .textFieldDecoration(hintText: hint, borderColor: AppColors.borderGrayMedium)
              .copyWith(fillColor: Colors.white),
        ),
      ],
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
}
