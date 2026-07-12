import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../widgets/common/app_svg_icon.dart';

class PropertyTypeCardWidget extends StatelessWidget {
  final String iconPath;
  final int count;
  final String label;

  const PropertyTypeCardWidget({
    super.key,
    required this.iconPath,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray20),
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            assetPath: iconPath,
            width: 48,
            height: 48,
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: themeManager.propertyTypeCountStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Shrink the label to fit one line so long names (e.g. "Commercial")
          // are never clipped or wrapped mid-word.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: themeManager.propertyTypeLabelStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
