import 'package:buyer/core/constants/app_colors.dart';
import 'package:buyer/core/theme/theme_manager.dart';
import 'package:flutter/material.dart';

/// A reusable expandable section with a title and list of label-value pairs.
/// Each item has left-aligned label, right-aligned value, 47px height, and horizontal dividers.
/// Used for Technical & Infrastructure, Interior & Workspace, Data Center Suitability, etc.
class ExpandableLabelValueSection extends StatelessWidget {
  /// Section title (e.g., "Technical & Infrastructure")
  final String title;

  /// List of label-value pairs
  final List<MapEntry<String, String>> items;

  /// Labels whose values should be rendered as a badge (e.g., "Availability" -> "Ready to Move")
  final Set<String>? badgeLabels;

  /// Whether the section is expanded
  final bool isExpanded;

  /// Called when the section header is tapped
  final VoidCallback onToggle;

  final ThemeManager themeManager;

  /// Item height for each label-value row (default 47px per spec)
  static const double itemHeight = 47.0;

  const ExpandableLabelValueSection({
    super.key,
    required this.title,
    required this.items,
    this.badgeLabels,
    required this.isExpanded,
    required this.onToggle,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray20, width: 1),
        color: AppColors.backgroundWhite,
        boxShadow: [BoxShadow(color: AppColors.overlayBlack06, blurRadius: 24, offset: const Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title, style: themeManager.expandableLabelValueSectionTitleStyle)),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textDark),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.borderGray20, thickness: 1, height: 1),
          if (isExpanded && items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    _LabelValueRow(
                      label: items[i].key,
                      value: items[i].value,
                      themeManager: themeManager,
                      isBadge: badgeLabels?.contains(items[i].key) ?? false,
                    ),
                    if (i < items.length - 1) Divider(color: AppColors.borderGray20, thickness: 1, height: 1),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeManager themeManager;
  final bool isBadge;

  const _LabelValueRow({
    required this.label,
    required this.value,
    required this.themeManager,
    this.isBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 47),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LABEL (takes only needed width)
            Text(label, style: themeManager.expandableLabelValueSectionLabelStyle, softWrap: true),

            const SizedBox(width: 12),

            // VALUE (takes remaining width) - plain text or badge
            Expanded(
              child: isBadge ? _buildBadgeValue() : _buildPlainValue(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainValue() {
    return Text(
      value,
      style: themeManager.expandableLabelValueSectionValueStyle,
      textAlign: TextAlign.right,
      softWrap: true,
    );
  }

  Widget _buildBadgeValue() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.approvedTagBgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: themeManager.expandableLabelValueBadgeTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
