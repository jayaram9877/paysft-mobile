import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/pages/pay_token/pages/payment_processing_page.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  // 0 = Net Banking, 1 = Card, 2 = Wallet
  int _selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Scaffold(
      backgroundColor: AppColors.backgroundGrayLight,
      appBar: AppBar(
        title: Text("Payment", style: themeManager.titleMediumStyle.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Payment Summary
            Text(AppStrings.paymentSummary, style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.tokenPayment, style: themeManager.captionSmallStyle),
                            const SizedBox(height: 4),
                            Text(
                              "Sobha Dream Acres",
                              style: themeManager.bodySmallStyle.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bluePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppSvgIcon(
                          assetPath: "assets/images/building_icon.svg",
                          width: 20,
                          color: AppColors.bluePrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.amountToPay, style: themeManager.captionSmallStyle.copyWith(fontSize: 13)),
                      Text("₹5,00,000", style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Choose Payment Method
            Text(AppStrings.choosePaymentMethod, style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              index: 0,
              icon: Icons.account_balance,
              title: AppStrings.netBanking,
              subtitle: AppStrings.allMajorBanks,
              color: Colors.blue.shade100,
              iconColor: Colors.blue,
              themeManager: themeManager,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              index: 1,
              icon: Icons.credit_card,
              title: AppStrings.creditDebitCard,
              subtitle: AppStrings.cardsDesc,
              color: Colors.green.shade100,
              iconColor: Colors.green,
              themeManager: themeManager,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodTile(
              index: 2,
              icon: Icons.account_balance_wallet,
              title: AppStrings.wallets,
              subtitle: AppStrings.walletsDesc,
              color: Colors.orange.shade100,
              iconColor: Colors.orange,
              themeManager: themeManager,
            ),
            const SizedBox(height: 24),

            // 3. Secure Payment Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.successGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.securePayment,
                          style: themeManager.bodySmallStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.paymentSecureDesc,
                          style: themeManager.captionSmallStyle.copyWith(
                            fontSize: 11,
                            color: AppColors.successGreen,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Terms Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrayMedium),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: true,
                      onChanged: (v) {},
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      activeColor: AppColors.bluePrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: themeManager.captionSmallStyle.copyWith(fontSize: 12, height: 1.4),
                        children: [
                          const TextSpan(text: "I agree to the "),
                          TextSpan(
                            text: AppStrings.termsAndConditions,
                            style: const TextStyle(color: AppColors.bluePrimary, decoration: TextDecoration.underline),
                          ),
                          const TextSpan(text: " and "),
                          TextSpan(
                            text: AppStrings.privacyPolicy,
                            style: const TextStyle(color: AppColors.bluePrimary, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Payment Breakdown
            Text(AppStrings.paymentBreakdown, style: themeManager.titleMediumStyle.copyWith(fontSize: 16)),
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
                  _buildBreakdownRow(AppStrings.baseAmount, "₹5,00,000", themeManager),
                  const SizedBox(height: 12),
                  _buildBreakdownRow(
                    AppStrings.paymentGatewayCharges,
                    "₹0",
                    themeManager,
                    valueColor: AppColors.successGreen,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildBreakdownRow(AppStrings.totalPayable, "₹5,00,000", themeManager, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 6. Pay Button
            PrimaryGradientButton(
              text: "${AppStrings.proceedToPay} ₹5,00,000",
              icon: Icons.lock_outline,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentProcessingPage()));
              },
              borderRadius: 12,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required ThemeManager themeManager,
  }) {
    bool isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.bluePrimary : AppColors.borderGrayMedium,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.bluePrimary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: themeManager.bodySmallStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: themeManager.captionSmallStyle.copyWith(fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.radio_button_checked, color: AppColors.bluePrimary, size: 24)
            else
              const Icon(Icons.radio_button_off, color: AppColors.borderGrayMedium, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    ThemeManager themeManager, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: themeManager.captionSmallStyle.copyWith(
            color: isBold ? AppColors.textBlack : AppColors.textGray,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: themeManager.bodySmallStyle.copyWith(
            color: valueColor ?? AppColors.textBlack,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
