import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

class FilterChipsWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const FilterChipsWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final categories = {
      AppStrings.categoryAll: Icons.select_all,
      AppStrings.residential: Icons.house_outlined,
      AppStrings.commercial: Icons.business_outlined,
      AppStrings.lands: Icons.landscape_outlined,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories.keys.elementAt(index);
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // ✅ removes extra height
              padding: EdgeInsets.zero, // ✅ remove internal ChoiceChip padding
              label: Container(
                alignment: Alignment.center, // ✅ center text vertically & horizontally
                padding: isSelected
                    ? const EdgeInsets.symmetric(horizontal: 4)
                    : const EdgeInsets.symmetric(horizontal: 12), // horizontal spacing
                height: 34, // match your SizedBox height
                child: Text(
                  category,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? themeManager.filterChipSelectedTextColor
                        : themeManager.filterChipUnselectedTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategorySelected(category);
                }
              },
              selectedColor: themeManager.filterChipSelectedColor,
              checkmarkColor: themeManager.filterChipSelectedTextColor,
              shape: StadiumBorder(
                side: isSelected
                    ? BorderSide(color: AppColors.blueInfo)
                    : BorderSide(color: AppColors.borderGrayLight),
              ),
              backgroundColor: themeManager.filterChipUnselectedColor,
            );
          },
        ),
      ),
    );
  }
}
