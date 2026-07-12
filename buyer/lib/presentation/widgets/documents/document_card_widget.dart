import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../domain/entities/document_model.dart';
import '../common/app_svg_icon.dart';

class DocumentCardWidget extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback onDownload;

  const DocumentCardWidget({super.key, required this.document, required this.onDownload});

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDivider, width: 0.5),
        boxShadow: [BoxShadow(color: AppColors.textBlack.withOpacity(0.05), blurRadius: 8, offset: const Offset(1, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document icon
              AppSvgIcon(assetPath: 'assets/images/profile_documents.svg', width: 36, height: 36),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(document.title, style: themeManager.documentTitleStyle),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(document.fullPropertyName, style: themeManager.documentSubtitleStyle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Download icon (sharp, no background)
              GestureDetector(
                onTap: onDownload,
                child: const Icon(Icons.download_sharp, size: 24, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Divider from icon start to download icon end
          Divider(height: 1, thickness: 1, color: AppColors.borderDivider),

          const SizedBox(height: 16),
          // Bottom row: Date, size on left, PDF badge on right (aligned vertically)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date and size on left
              Text(_formatDate(document.date), style: themeManager.documentMetadataStyle),
              const SizedBox(width: 8),
              Text('•', style: themeManager.documentMetadataStyle),
              const SizedBox(width: 8),
              Text(document.fileSize, style: themeManager.documentMetadataStyle),
              const Spacer(),
              // PDF badge aligned with date/size
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondaryGray, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  document.fileTypeLabel,
                  style: themeManager.pdfBadgeTextStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
