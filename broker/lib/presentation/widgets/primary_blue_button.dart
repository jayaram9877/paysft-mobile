import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_manager.dart';

class PrimaryGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? borderRadius;

  const PrimaryGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final radius = borderRadius ?? 14; // Default to 14 if not provided
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primaryCyan, AppColors.primaryPurpleBright],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Text(
              text,
              style: themeManager.labelStyle.copyWith(
                color: AppColors.backgroundWhite,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
