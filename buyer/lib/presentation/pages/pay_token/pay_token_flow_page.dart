import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/pages/pay_token/steps/bank_details_step.dart';
import 'package:buyer/presentation/pages/pay_token/steps/nominee_details_step.dart';
import 'package:buyer/presentation/pages/pay_token/steps/personal_details_step.dart';
import 'package:buyer/presentation/pages/pay_token/pages/escrow_account_created_page.dart';
import 'package:buyer/presentation/pages/pay_token/steps/review_step.dart';
import 'package:buyer/presentation/providers/pay_token_provider.dart';
import 'package:buyer/presentation/widgets/pay_token/custom_stepper.dart';
import 'package:buyer/presentation/widgets/primary_blue_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/injection_container.dart' as di;

class PayTokenFlowPage extends StatelessWidget {
  const PayTokenFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<PayTokenProvider>(),
      child: Consumer<PayTokenProvider>(
        builder: (context, provider, _) {
          final themeManager = ThemeManager();
          return Scaffold(
            backgroundColor: AppColors.backgroundGrayLight,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(AppStrings.escrowAccount, style: themeManager.titleMediumStyle),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textBlack),
                onPressed: () => provider.previousStep(context),
              ),
            ),
            body: Column(
              children: [
                CustomStepper(currentStep: provider.currentStep),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(padding: const EdgeInsets.all(16.0), child: _buildStepContent(provider.currentStep)),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              color: Colors.white,
              child: Row(
                children: [
                  if (provider.currentStep > 0 && provider.currentStep == 2)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => provider.previousStep(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.borderGrayMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          AppStrings.back,
                          style: themeManager.buttonTextStyle.copyWith(color: AppColors.textGray),
                        ),
                      ),
                    )
                  else if (provider.currentStep > 0)
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => provider.previousStep(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AppColors.borderGrayMedium),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textBlack),
                      ),
                    ),
                  if (provider.currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryGradientButton(
                      text: provider.currentStep == 3 ? AppStrings.createEscrowAccount : AppStrings.continueButton,
                      onTap: () {
                        if (provider.currentStep < 3) {
                          provider.nextStep();
                        } else {
                          // Navigate to Escrow Account Created Page
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const EscrowAccountCreatedPage()));
                        }
                      },
                      borderRadius: 12,
                      showShadow: provider.currentStep == 3,
                      isEnabled: provider.currentStep == 0
                          ? provider.isPersonalDetailsStepValid()
                          : provider.currentStep == 1
                          ? provider.isNomineeDetailsStepValid()
                          : provider.currentStep == 2
                          ? provider.isBankDetailsStepValid()
                          : provider.currentStep == 3
                          ? provider.isReviewStepValid()
                          : true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const PersonalDetailsStep();
      case 1:
        return const NomineeDetailsStep();
      case 2:
        return const BankDetailsStep();
      case 3:
        return const ReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }
}
