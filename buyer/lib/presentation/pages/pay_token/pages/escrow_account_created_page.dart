import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/pages/pay_token/pages/payment_method_page.dart';
import 'package:buyer/presentation/pages/contact_support_page.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';

class EscrowAccountCreatedPage extends StatelessWidget {
  const EscrowAccountCreatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrayLight,
      appBar: AppBar(
        title: Text(AppStrings.escrowAccount, style: themeManager.titleMediumStyle.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Success Banner
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      // Add gentle shadow/gradient if possible
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      children: [
                        // Shield Icon
                        Center(child: AppSvgIcon(assetPath: "assets/images/account_created_secure_image.svg")),
                        const SizedBox(height: 16),
                        Text("ESCROW Account Created", style: themeManager.titleMediumStyle),
                        const SizedBox(height: 8),
                        Text(
                          "Your secure payment account is ready for\ntransaction",
                          textAlign: TextAlign.center,
                          style: themeManager.captionSmallStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Review & Accepts Terms Details
                Text("Review & Accepts Terms", style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGrayMedium),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AppSvgIcon(assetPath: "assets/images/escrow_acc_number_icon.svg"),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ESCROW Account Number",
                                style: themeManager.captionSmallStyle.copyWith(fontSize: 10),
                              ),
                              Text(
                                "ESC6474633449",
                                style: themeManager.bodySmallStyle.copyWith(
                                  color: AppColors.bluePrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildDetailRow("Account Holder", "Ramesh Kumar", themeManager),
                      const SizedBox(height: 8),
                      _buildDetailRow("Property", "Sobha Dream Acres", themeManager),
                      const SizedBox(height: 8),
                      _buildDetailRow("Created on", "23rd Dec 2025", themeManager),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status", style: themeManager.captionSmallStyle),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Active",
                              style: themeManager.labelStyle.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Pending Deposit
                Text(AppStrings.pendingDeposit, style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warningOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      AppSvgIcon(assetPath: "assets/images/token_payment_alert_info_icon.svg"),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tokenPayment,
                              style: themeManager.bodySmallStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF964B00),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.tokenPaymentDesc,
                              style: themeManager.captionSmallStyle.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF964B00),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.amountToDeposit,
                                  style: themeManager.captionSmallStyle.copyWith(
                                    fontSize: 11,
                                    color: const Color(0xFF964B00),
                                  ),
                                ),
                                Text(
                                  "₹5,00,000",
                                  style: themeManager.bodySmallStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF964B00),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. How ESCROWS Works
                Text(AppStrings.howEscrowWorks, style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _buildStepRow("1", AppStrings.step1Title, AppStrings.step1Desc, themeManager),
                      const SizedBox(height: 20),
                      _buildStepRow("2", AppStrings.step2Title, AppStrings.step2Desc, themeManager),
                      const SizedBox(height: 20),
                      _buildStepRow("3", AppStrings.step3Title, AppStrings.step3Desc, themeManager),
                      const SizedBox(height: 20),
                      _buildStepRow(
                        null,
                        AppStrings.completeProtection,
                        AppStrings.completeProtectionDesc,
                        themeManager,
                        isCheck: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Account Features Grid
                Text(AppStrings.accountFeatures, style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        "assets/images/rera_protected.svg",
                        AppStrings.reraProtected,
                        AppStrings.reraProtectedSub,
                        themeManager,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        "assets/images/full_transparency.svg",
                        AppStrings.fullTransparency,
                        AppStrings.fullTransparencySub,
                        themeManager,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        "assets/images/interest_earning.svg",
                        AppStrings.interestEarning,
                        AppStrings.interestEarningSub,
                        themeManager,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFeatureCard(
                        "assets/images/24by7.svg",
                        AppStrings.access247,
                        AppStrings.access247Sub,
                        themeManager,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 6. Important Information (Blue Box)
                Text(
                  AppStrings.importantInformation,
                  style: themeManager.titleMediumStyle.copyWith(color: AppColors.bluePrimary, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlueVeryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.blueLight.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      _buildBulletPoint(AppStrings.importantInfo1, themeManager),
                      _buildBulletPoint(AppStrings.importantInfo2, themeManager),
                      _buildBulletPoint(AppStrings.importantInfo3, themeManager),
                      _buildBulletPoint(AppStrings.importantInfo4, themeManager),
                      _buildBulletPoint(AppStrings.importantInfo5, themeManager),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Action Button
                PrimaryGradientButton(
                  text: "${AppStrings.proceedToDeposit} ₹5,00,000",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodPage()));
                  },
                  borderRadius: 12,
                ),
                const SizedBox(height: 16),

                // 8. Download / Share Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 18, color: AppColors.textGray),
                        label: Text(AppStrings.download, style: themeManager.captionSmallStyle),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.borderGrayMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textGray),
                        label: Text(AppStrings.share, style: themeManager.captionSmallStyle),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.borderGrayMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 9. Contact Support (with 16px horizontal gap already from main padding)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      AppSvgIcon(assetPath: "assets/images/contact_support.svg"),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.haveQuestionsEscrow,
                        textAlign: TextAlign.center,
                        style: themeManager.captionSmallStyle,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ContactSupportPage()),
                          );
                        },
                        child: Text(
                          AppStrings.contactEscrowSupport,
                          style: themeManager.bodySmallStyle.copyWith(
                            color: AppColors.bluePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeManager themeManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: themeManager.captionSmallStyle),
        Text(value, style: themeManager.bodySmallStyle.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStepRow(String? number, String title, String desc, ThemeManager themeManager, {bool isCheck = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCheck ? AppColors.successGreen.withOpacity(0.1) : AppColors.bluePrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCheck
                ? const Icon(Icons.check, size: 14, color: AppColors.successGreen)
                : Text(
                    number!,
                    style: themeManager.captionStyle.copyWith(
                      color: AppColors.bluePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: themeManager.bodySmallStyle.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(desc, style: themeManager.captionSmallStyle.copyWith(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String assetPath, String title, String sub, ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrayMedium),
      ),
      child: Column(
        children: [
          AppSvgIcon(assetPath: assetPath, color: AppColors.bluePrimary, width: 24, height: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: themeManager.captionSmallStyle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
            textAlign: TextAlign.center,
          ),
          Text(sub, style: themeManager.captionSmallStyle.copyWith(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, ThemeManager themeManager) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(color: AppColors.bluePrimary, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: themeManager.captionSmallStyle.copyWith(color: AppColors.bluePrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
