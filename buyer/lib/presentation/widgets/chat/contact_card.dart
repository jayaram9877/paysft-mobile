import 'package:flutter/material.dart';
import '../../../domain/entities/message.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

class ContactCard extends StatelessWidget {
  final SharedContact contact;
  final bool isSent;

  const ContactCard({
    super.key,
    required this.contact,
    required this.isSent,
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
          // Contact header with avatar and name
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.avatarBackground,
                  backgroundImage: contact.avatarUrl != null
                      ? NetworkImage(contact.avatarUrl!)
                      : null,
                  child: contact.avatarUrl == null
                      ? Text(
                          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                          style: themeManager.titleMediumStyle.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Text(
                    contact.name,
                    style: themeManager.bodyMediumStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 1, color: AppColors.borderDivider),
          // Phone number
          if (contact.primaryPhone != null || contact.phoneNumbers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.textSecondaryGray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contact.primaryPhone ?? contact.phoneNumbers.first,
                      style: themeManager.captionStyle.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

