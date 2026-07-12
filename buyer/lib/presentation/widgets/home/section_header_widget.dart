import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../widgets/common/app_svg_icon.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onActionTap;
  final String? actionText;
  final EdgeInsetsGeometry? padding;

  const SectionHeaderWidget({super.key, required this.title, this.onActionTap, this.actionText, this.padding});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: themeManager.sectionHeaderTitleStyle),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.translucent,
              child: Row(
                children: [
                  Text(actionText!, style: themeManager.sectionHeaderActionStyle),
                  const SizedBox(width: 4),
                  AppSvgIcon(
                    assetPath: 'assets/images/arrow_right.svg',
                    width: 24,
                    height: 24,
                    color: AppColors.blueInfo,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
