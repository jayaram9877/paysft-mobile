import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import '../common/app_svg_icon.dart';

/// A reusable grid section displaying property info cards.
/// Each card shows: Icon (left), Value (top), Label (bottom).
/// Matches Unit Details layout but with value-above-label order.
class PropertyInfoGridSection extends StatelessWidget {
  final List<PropertyInfoGridItem> items;
  final ThemeManager themeManager;

  const PropertyInfoGridSection({
    super.key,
    required this.items,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _PropertyInfoCard(
          iconPath: item.iconPath,
          value: item.value,
          label: item.label,
          themeManager: themeManager,
        );
      },
    );
  }
}

/// Model for a single property info grid item
class PropertyInfoGridItem {
  final String iconPath;
  final String value;
  final String label;

  const PropertyInfoGridItem({
    required this.iconPath,
    required this.value,
    required this.label,
  });
}

class _PropertyInfoCard extends StatelessWidget {
  final String iconPath;
  final String value;
  final String label;
  final ThemeManager themeManager;

  const _PropertyInfoCard({
    required this.iconPath,
    required this.value,
    required this.label,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.borderGrayMedium),
        color: AppColors.backgroundWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: AppSvgIcon(assetPath: iconPath, width: 32, height: 32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: themeManager.propertyInfoCardValueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: themeManager.propertyInfoCardLabelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
