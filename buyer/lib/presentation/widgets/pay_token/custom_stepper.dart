import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/constants/app_string_constants.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:buyer/presentation/widgets/common/app_svg_icon.dart';
import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const CustomStepper({
    super.key,
    required this.currentStep,
    this.steps = const [AppStrings.stepPersonal, AppStrings.stepNominee, AppStrings.stepBank, AppStrings.stepReview],
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepItem(0, AppStrings.stepPersonal, themeManager, isFirst: true),
          _buildDivider(0),
          _buildStepItem(1, AppStrings.stepNominee, themeManager),
          _buildDivider(1),
          _buildStepItem(2, AppStrings.stepBank, themeManager),
          _buildDivider(2),
          _buildStepItem(3, AppStrings.stepReview, themeManager, isLast: true),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int index,
    String title,
    ThemeManager themeManager, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final bool isCompleted = index < currentStep;
    final bool isCurrent = index == currentStep;

    // Define colors based on state
    final Color circleColor = isCompleted || isCurrent ? AppColors.bluePrimary : AppColors.gray200;
    final Color textColor = isCompleted || isCurrent ? AppColors.textBlack : AppColors.textGray;
    final FontWeight fontWeight = isCurrent ? FontWeight.w600 : FontWeight.w500;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
            child: isCompleted
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AppSvgIcon(assetPath: "assets/images/stepper_success.svg", color: Colors.white),
                  )
                : Center(
                    child: Text(
                      "${index + 1}",
                      style: themeManager.captionStyle.copyWith(
                        color: isCurrent ? Colors.white : AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: themeManager.captionSmallStyle.copyWith(
              fontSize: 11,
              color: textColor,
              fontWeight: fontWeight,
              fontFamily: AppStrings.fontFamilyText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(int index) {
    final bool isActive = currentStep > index;

    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.bluePrimary : AppColors.gray200,
        margin: const EdgeInsets.only(bottom: 20),
      ),
    );
  }
}
