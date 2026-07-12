import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/entities/message.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

class DocumentCard extends StatelessWidget {
  final SharedDocument document;
  final bool isSent;

  const DocumentCard({
    super.key,
    required this.document,
    required this.isSent,
  });

  IconData _getFileIcon(String fileType) {
    final extension = fileType.toLowerCase();
    if (extension.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (extension.contains('doc') || extension.contains('docx')) {
      return Icons.description;
    } else if (extension.contains('xls') || extension.contains('xlsx')) {
      return Icons.table_chart;
    } else if (extension.contains('ppt') || extension.contains('pptx')) {
      return Icons.slideshow;
    } else if (extension.contains('txt')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSent ? AppColors.chatSentMessageBubble : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // File icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(document.fileType),
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    document.fileName,
                    style: themeManager.bodySmallStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        document.fileType.toUpperCase(),
                        style: themeManager.labelStyle.copyWith(
                          color: AppColors.textSecondaryGray,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: themeManager.labelStyle.copyWith(
                          color: AppColors.textSecondaryGray,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatFileSize(document.fileSize),
                        style: themeManager.labelStyle.copyWith(
                          color: AppColors.textSecondaryGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Download/Open icon
            Icon(
              Icons.download,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

