import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_stats_model.dart';
import '../../widgets/common/app_svg_icon.dart';

class QuickActionCardWidget extends StatelessWidget {
  final QuickActionModel action;
  final VoidCallback? onTap;

  const QuickActionCardWidget({super.key, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGray20),
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 14))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSvgIcon(assetPath: action.iconPath, width: 48, height: 48),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                action.name,
                style: themeManager.quickActionNameStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                action.tag,
                style: themeManager.quickActionTagStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
