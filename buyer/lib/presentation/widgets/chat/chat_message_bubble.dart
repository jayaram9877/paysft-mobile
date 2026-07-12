import 'package:flutter/material.dart';
import '../../../domain/entities/message.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_string_constants.dart';
import '../../../core/theme/theme_manager.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final String? timestamp;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: message.isSent
                ? AppColors.chatSentMessageBubble
                : AppColors.chatReceivedMessageBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(7.5),
              topRight: const Radius.circular(7.5),
              bottomLeft: Radius.circular(message.isSent ? 7.5 : 0),
              bottomRight: Radius.circular(message.isSent ? 0 : 7.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: themeManager.bodyStyle.copyWith(
                  color: message.isSent
                        ? AppColors.chatSentMessageText
                        : AppColors.chatReceivedMessageText,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              if (timestamp != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    timestamp!,
                    style: themeManager.labelStyle.copyWith(
                      fontSize: 11,
                      color: message.isSent
                            ? AppColors.chatSentMessageTimestamp
                            : AppColors.chatReceivedMessageTimestamp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}