import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

import '../../core/theme/theme_manager.dart';

class PrimaryGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? borderRadius;
  final IconData? icon;
  final bool isEnabled;
  final bool showShadow;

  const PrimaryGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.borderRadius,
    this.icon,
    this.isEnabled = true,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final radius = borderRadius ?? 14; // Default to 14 if not provided

    final bool disabled = !isEnabled;
    final Color disabledBg = AppColors.ultramarine50.withOpacity(0.6);
    final Color disabledText = AppColors.textWhite.withOpacity(0.7);
    final Widget? leadingIcon = icon != null
        ? Icon(icon, color: disabled ? disabledText : AppColors.buttonTextLight, size: 20)
        : null;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: disabled
            ? null
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.primaryCyan, AppColors.primaryPurpleBright],
              ),
        color: disabled ? disabledBg : null,
        border: Border.all(color: (disabled ? disabledBg : AppColors.borderGrey).withOpacity(0.9), width: 1.2),
        boxShadow: !disabled && showShadow
            ? [
                BoxShadow(
                  color: AppColors.primaryPurpleBright.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.buttonTextLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[leadingIcon, const SizedBox(width: 8)],
              Text(
                text,
                style: themeManager.labelStyle.copyWith(
                  color: disabled ? disabledText : AppColors.buttonTextLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
