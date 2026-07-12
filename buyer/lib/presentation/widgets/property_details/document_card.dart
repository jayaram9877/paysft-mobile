import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/property_details_model.dart';
import '../common/app_svg_icon.dart';

/// Document card widget for land property documents
/// Follows the existing architecture pattern with theme-aware design
class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;

  const DocumentCard({super.key, required this.document, this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrayMedium, width: 1),
        ),
        child: Row(
          children: [
            // Document icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.successGreenLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: AppSvgIcon(
                  assetPath: 'assets/images/doc_icon.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.successGreenLight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Document details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.title, style: themeManager.bodyMediumStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(document.date, style: themeManager.captionStyle),
                ],
              ),
            ),
            // Download icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.backgroundBlueVeryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: AppSvgIcon(
                  assetPath: 'assets/images/download_button.svg',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
