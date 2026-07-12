import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/category_model.dart';
import '../../widgets/common/app_svg_icon.dart';

class CategoryItemWidget extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryItemWidget({super.key, required this.category, this.onTap});

  /// Leading icon per backend project_subtype (category.id).
  static IconData _iconFor(String id) {
    switch (id) {
      case 'apartment':
        return Icons.apartment;
      case 'villa':
        return Icons.villa;
      case 'gated_plots':
        return Icons.landscape;
      case 'independent_house':
        return Icons.house;
      case 'office':
        return Icons.business_center;
      case 'retail_shop':
        return Icons.storefront;
      default:
        return Icons.home_work;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: AppColors.backgroundGrayMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(themeManager.categoryItemBorderRadius)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Icon(_iconFor(category.id), size: 20, color: AppColors.bluePrimary),
              const SizedBox(width: 8),
              // Fixed text size across all chips; clip with ellipsis if too long.
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: themeManager.categoryItemTextStyle,
                ),
              ),
              const SizedBox(width: 8),
              AppSvgIcon(assetPath: 'assets/images/arrow_right.svg', width: 20, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
