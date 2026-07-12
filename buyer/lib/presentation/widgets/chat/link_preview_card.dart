import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

class LinkPreviewCard extends StatelessWidget {
  final String url;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final bool isSent;

  const LinkPreviewCard({
    super.key,
    required this.url,
    this.title,
    this.description,
    this.thumbnailUrl,
    required this.isSent,
  });

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.couldNotOpenLink),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return GestureDetector(
      onTap: () => _openLink(context),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail (if available)
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  thumbnailUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Domain
                  Text(
                    _getDomain(url),
                    style: themeManager.labelStyle.copyWith(
                      color: AppColors.textSecondaryGray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title
                  if (title != null && title!.isNotEmpty)
                    Text(
                      title!,
                      style: themeManager.bodySmallStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (title != null && title!.isNotEmpty) const SizedBox(height: 4),
                  // Description
                  if (description != null && description!.isNotEmpty)
                    Text(
                      description!,
                      style: themeManager.captionSmallStyle.copyWith(
                        color: AppColors.textSecondaryGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // URL
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 14,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          url,
                          style: themeManager.captionSmallStyle.copyWith(
                            color: AppColors.primaryBlue,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

