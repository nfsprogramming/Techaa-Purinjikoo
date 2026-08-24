import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/chat_message.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatBubbleWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isYou = message.sender == SenderType.you;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isYou ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isYou) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderMuted),
              ),
              child: Center(
                child: Text(
                  message.avatarEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              decoration: BoxDecoration(
                color: isYou ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isYou ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isYou ? const Radius.circular(4) : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isYou ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderMuted,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isYou ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.speakerName.isNotEmpty) ...[
                    Text(
                      message.speakerName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isYou ? AppColors.primary : AppColors.tertiary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isYou) ...[
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  message.avatarEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
