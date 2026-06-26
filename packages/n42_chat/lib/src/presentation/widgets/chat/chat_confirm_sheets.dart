import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';

class ChatDeleteConfirmSheet extends StatelessWidget {
  const ChatDeleteConfirmSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final separatorColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主要内容
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      S.of(context)?.chatDeleteThisMessage ?? 'Delete this message?',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textTertiary,
                      ),
                    ),
                  ),

                  // 分隔线
                  Container(height: 0.5, color: separatorColor),

                  // 删除按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, true),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          S.of(context)?.commonDelete ?? 'Delete',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFFFF3B30), // iOS red
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 取消按钮
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context, false),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      S.of(context)?.commonCancel ?? 'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Colors.white : const Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 消息操作菜单
class ChatMessageMenuSheet extends StatelessWidget {
  final MessageEntity message;
  final VoidCallback? onCopy;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;

  const ChatMessageMenuSheet({
    super.key,
    required this.message,
    this.onCopy,
    this.onReply,
    this.onForward,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (message.type == MessageType.text)
              _buildMenuItem(
                context,
                icon: Icons.copy,
                title: S.of(context)?.chatCopy ?? 'Copy',
                onTap: onCopy,
              ),
            _buildMenuItem(
              context,
              icon: Icons.reply,
              title: S.of(context)?.chatReply ?? 'Reply',
              onTap: onReply,
            ),
            if (onForward != null)
              _buildMenuItem(
                context,
                icon: Icons.forward,
                title: S.of(context)?.commonForward ?? 'Forward',
                onTap: onForward,
              ),
            if (onDelete != null)
              _buildMenuItem(
                context,
                icon: Icons.delete_outline,
                title: S.of(context)?.chatRecall ?? 'Recall',
                color: AppColors.error,
                onTap: onDelete,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    VoidCallback? onTap,
  }) {
    final textColor = color ?? context.textPrimary;

    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
