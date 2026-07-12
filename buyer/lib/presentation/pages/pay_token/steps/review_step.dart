import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/providers/pay_token_provider.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewStep extends StatefulWidget {
  const ReviewStep({super.key});

  @override
  State<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends State<ReviewStep> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PayTokenProvider>(context, listen: false);
      provider.setReviewFormKey(_formKey);
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
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Escrow Protected Transaction Card (With integrated Payment Summary)
              _buildEscrowInfoCard(themeManager, propertyInfo, amount),
              const SizedBox(height: 24),

              // 3. Review & Accepts Terms Header
              Text(AppStrings.reviewAndTerms, style: themeManager.titleMediumStyle),
              const SizedBox(height: 16),

              // 4. Personal Details Summary
              _buildDetailsCard(themeManager, AppStrings.personalDetails, [
                _buildDetailRow(
                  AppStrings.accountHolder,
                  provider.nameController.text.isNotEmpty ? provider.nameController.text : "Ramesh Kumar",
                  themeManager,
                ),
                _buildDetailRow(
                  "PAN",
                  provider.panController.text.isNotEmpty ? provider.panController.text : "ABCDE1234F",
                  themeManager,
                ),
                _buildDetailRow(
                  "Aadhaar",
                  provider.aadhaarController.text.isNotEmpty ? provider.aadhaarController.text : "1234 5678 9012",
                  themeManager,
                ),
                _buildDetailRow(
                  AppStrings.phone,
                  provider.phoneController.text.isNotEmpty ? provider.phoneController.text : "+91 98765 43210",
                  themeManager,
                ),
                _buildDetailRow(
                  AppStrings.emailLabel,
                  provider.emailController.text.isNotEmpty ? provider.emailController.text : "ramesh.kumar@example.com",
                  themeManager,
                ),
              ]),
              const SizedBox(height: 16),

              // 5. Nominee Details Summary
              _buildDetailsCard(themeManager, AppStrings.nomineeDetails, [
                _buildDetailRow(
                  "Nominee",
                  provider.nomineeNameController.text.isNotEmpty ? provider.nomineeNameController.text : "Suresh Kumar",
                  themeManager,
                ),
                _buildDetailRow(
                  AppStrings.phone,
                  provider.nomineePhoneController.text.isNotEmpty ? provider.nomineePhoneController.text : "+91 98765 43210",
                  themeManager,
                ),
                _buildDetailRow(
                  AppStrings.emailLabel,
                  provider.nomineeEmailController.text.isNotEmpty
                      ? provider.nomineeEmailController.text
                      : "nominee@example.com",
                  themeManager,
                ),
              ]),
              const SizedBox(height: 16),

              // 6. Bank Details Summary
              _buildDetailsCard(themeManager, AppStrings.bankDetails, [
                _buildDetailRow(
                  "Bank",
                  provider.bankNameController.text.isNotEmpty ? provider.bankNameController.text : "HDFC",
                  themeManager,
                ),
                _buildDetailRow(
                  "Account",
                  provider.accountNumberController.text.isNotEmpty ? provider.accountNumberController.text : "987654321098",
                  themeManager,
                ),
                _buildDetailRow(
                  "IFSC",
                  provider.ifscController.text.isNotEmpty ? provider.ifscController.text : "HDFC0001234",
                  themeManager,
                ),
              ]),
              const SizedBox(height: 24),

              // 7. Terms (single container)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGray20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.terms,
                      style: themeManager.reviewSectionTitleStyle,
                    ),
                    const SizedBox(height: 8),
                    _buildCheckboxRow(
                      value: provider.agreedToTerms,
                      onChanged: (v) => provider.setAgreedToTerms(v ?? false),
                      text: "",
                      isLink: true,
                      themeManager: themeManager,
                    ),
                    _buildCheckboxRow(
                      value: provider.authorizedAccount,
                      onChanged: (v) => provider.setAuthorizedAccount(v ?? false),
                      text: AppStrings.authorizePaySft,
                      themeManager: themeManager,
                    ),
                    _buildCheckboxRow(
                      value: provider.acknowledgedRera,
                      onChanged: (v) => provider.setAcknowledgedRera(v ?? false),
                      text: AppStrings.acknowledgeRera,
                      themeManager: themeManager,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 8. ESCROW Account Benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.bluePrimary, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.escrowBenefits,
                      style: themeManager.bodySmallStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem(AppStrings.benefit1, themeManager),
                    _buildBenefitItem(AppStrings.benefit2, themeManager),
                    _buildBenefitItem(AppStrings.benefit3, themeManager),
                    _buildBenefitItem(AppStrings.benefit4, themeManager),
                    _buildBenefitItem(AppStrings.benefit5, themeManager),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 9. Secure Banking Info (Green)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreenLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSvgIcon(assetPath: "assets/images/secure_banking_alert_info_icon.svg", width: 28, height: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.secureBanking,
                            style: themeManager.bodySmallStyle.copyWith(
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.secureBankingDesc,
                            style: themeManager.captionSmallStyle.copyWith(color: AppColors.successGreen, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
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
              const AppSvgIcon(assetPath: "assets/images/escrow_protection_icon.svg", width: 28, height: 28),
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

  Widget _buildDetailsCard(ThemeManager themeManager, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: themeManager.reviewSectionTitleStyle),
          const SizedBox(height: 12),
          ..._buildChildrenWithDividers(children),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(List<Widget> children) {
    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(const SizedBox(height: 8));
        result.add(const Divider(color: AppColors.borderGrayMedium));
        result.add(const SizedBox(height: 8));
      }
    }
    return result;
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

  Widget _buildDetailRow(String label, String value, ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: themeManager.bodySmallStyle.copyWith(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: themeManager.bodySmallStyle.copyWith(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required bool value,
    required Function(bool?) onChanged,
    required String text,
    required ThemeManager themeManager,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.bluePrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLink
                ? RichText(
                    text: TextSpan(
                      style: themeManager.captionSmallStyle.copyWith(
                        color: AppColors.textGray,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: AppStrings.agreeTerms),
                        TextSpan(
                          text: AppStrings.escrowTermsConditions,
                          style: const TextStyle(color: AppColors.bluePrimary, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: AppStrings.agreeTermsSuffix),
                      ],
                    ),
                  )
                : Text(
                    text,
                    style: themeManager.captionSmallStyle.copyWith(
                      color: AppColors.textGray,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text, ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: themeManager.captionSmallStyle.copyWith(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
