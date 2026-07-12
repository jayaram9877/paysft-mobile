import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';

class PropertyCategoryTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final ThemeManager themeManager;

  const PropertyCategoryTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 32.0; // 16 left + 16 right
    final availableWidth = screenWidth - horizontalPadding;
    final tabCount = tabs.length;
    const minTabWidth = 80.0; // Minimum width for readability
    final calculatedTabWidth = availableWidth / tabCount;
    final tabWidth = calculatedTabWidth < minTabWidth ? minTabWidth : calculatedTabWidth;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
      child: SizedBox(
        height: 48,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              tabCount,
              (index) => SizedBox(
                width: tabWidth,
                child: _PropertyCategoryTabItem(
                  label: tabs[index],
                  isSelected: selectedIndex == index,
                  onTap: () => onTabChanged(index),
                  themeManager: themeManager,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyCategoryTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeManager themeManager;

  const _PropertyCategoryTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: isSelected
                    ? themeManager.documentTabSelectedStyle
                    : themeManager.documentTabUnselectedStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Container(
                      height: 2,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.tabGradientStart, AppColors.tabGradientEnd],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    )
                  : const SizedBox(height: 2),
            ),
          ],
        ),
      ),
    );
  }
}

