import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/pages/contact_support_page.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: Colors.white, // As per design
      appBar: AppBar(
        title: Text("Payment", style: themeManager.titleMediumStyle.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Prevent back button to processing
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Success Circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.05), shape: BoxShape.circle),
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), shape: BoxShape.circle),
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.successGreen, width: 3),
                  ),
                  child: const Icon(Icons.check, color: AppColors.successGreen, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.paymentSuccessful, style: themeManager.titleStyle.copyWith(color: AppColors.textBlack)),
            const SizedBox(height: 8),
            Text(
              AppStrings.paymentSuccessDesc,
              textAlign: TextAlign.center,
              style: themeManager.captionSmallStyle.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 32),

            // 2. Receipt Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGrayMedium),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.bluePrimary.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.amountPaid,
                          style: themeManager.bodySmallStyle.copyWith(
                            color: AppColors.bluePrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "₹5,00,000",
                          style: themeManager.titleMediumStyle.copyWith(color: AppColors.bluePrimary, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildReceiptRow(AppStrings.transactionId, "TXN1766473984783", themeManager),
                        const SizedBox(height: 12),
                        _buildReceiptRow("Payment For", "Token Payment", themeManager),
                        const SizedBox(height: 12),
                        _buildReceiptRow("Property", "Sobha Dream Acres", themeManager),
                        const SizedBox(height: 12),
                        _buildReceiptRow("Payment Method", "UPI", themeManager),
                        const SizedBox(height: 12),
                        _buildReceiptRow("Date & Time", "23rd Dec 2025, 12:43 PM", themeManager),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 3. What's Next
            Align(
              alignment: Alignment.centerLeft,
              child: Text(AppStrings.whatsNext, style: themeManager.titleMediumStyle.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGrayMedium),
              ),
              child: Column(
                children: [
                  _buildNextStep("1", AppStrings.nextStep1Title, AppStrings.nextStep1Desc, themeManager),
                  const SizedBox(height: 20),
                  _buildNextStep("2", AppStrings.nextStep2Title, AppStrings.nextStep2Desc, themeManager),
                  const SizedBox(height: 20),
                  _buildNextStep("3", AppStrings.nextStep3Title, AppStrings.nextStep3Desc, themeManager),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 18, color: AppColors.textGray),
                    label: Text(AppStrings.receipt, style: themeManager.captionSmallStyle),
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

            // Contact Support
            Container(
              width: double.infinity, // 👈 This is required
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
                    "Have questions about your payment?",
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
                      "Contact Support",
                      style: themeManager.bodySmallStyle.copyWith(
                        color: AppColors.bluePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            PrimaryGradientButton(
              text: AppStrings.backToHome,
              icon: Icons.home_outlined,
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              borderRadius: 12,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, ThemeManager themeManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: themeManager.captionSmallStyle),
        Text(value, style: themeManager.bodySmallStyle.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNextStep(String number, String title, String desc, ThemeManager themeManager) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: AppColors.bluePrimary.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
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
}
