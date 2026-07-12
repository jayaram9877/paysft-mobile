import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_string_constants.dart';
import '../../core/theme/theme_manager.dart';

class RichContentCard extends StatelessWidget {
  final RichContent content;

  const RichContentCard({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(7.5),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on the left side
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(7.5),
              bottomLeft: Radius.circular(7.5),
            ),
            child: Image.network(
              content.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  color: AppColors.errorBackground,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          // Content on the right
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content.title,
                    style: themeManager.bodyStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondaryGray,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          content.location,
                          style: themeManager.bodySmallStyle.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondaryGray,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (content.linkText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      content.linkText!,
                      style: themeManager.bodySmallStyle.copyWith(
                        fontSize: 13,
                        color: AppColors.primaryBlueLink,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
