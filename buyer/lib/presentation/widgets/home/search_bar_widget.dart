import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../widgets/common/app_svg_icon.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.hintText,
    this.onTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: themeManager.searchBarHeight,
        padding: themeManager.searchBarPadding,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(themeManager.searchBarBorderRadius),
          border: Border.all(color: AppColors.borderGrayLight),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Center(
                child: AppSvgIcon(
                  assetPath: 'assets/images/search.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.bluePrimary,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  hintText,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGrayLight,
                  ),
                ),
              ),
            ),
            Container(height: 24, width: 1, color: AppColors.borderGrayLight),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onFilterTap,
              child: AppSvgIcon(
                assetPath: 'assets/images/filter.svg',
                width: 22,
                height: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
