import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';

class SecondaryGrayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool showBottomBorder;
  final Color? backgroundColor;
  final Color? textColor;

  const SecondaryGrayButton({
    super.key,
    required this.text,
    required this.onTap,
    this.showBottomBorder = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return SizedBox(
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.backgroundWhite.withOpacity(0),
          border: Border(
            top: const BorderSide(color: AppColors.buttonBorderGray, width: 1.2),
            left: const BorderSide(color: AppColors.buttonBorderGray, width: 1.2),
            right: const BorderSide(color: AppColors.buttonBorderGray, width: 1.2),
            bottom: showBottomBorder
                ? const BorderSide(color: AppColors.buttonBorderGray, width: 1.2)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.backgroundWhite.withOpacity(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
            foregroundColor: AppColors.buttonTextDark,
          ),
          child: Text(
            text,
            style: themeManager.labelStyle.copyWith(
              color: textColor ?? AppColors.buttonTextDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
