import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';

class SegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  const SegmentedControl({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundGrayMedium,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.backgroundWhite : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: isSelected ? themeManager.bedRoomsSelectedStyle : themeManager.bedRoomsUnselectedStyle,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
