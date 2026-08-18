// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/message_entity.dart';

/// 消息操作菜单
class MessageMenuSheet extends StatelessWidget {
  final MessageEntity message;
  final VoidCallback? onCopy;
  final VoidCallback? onReply;
  final VoidCallback? onForward;
  final VoidCallback? onDelete;
  final VoidCallback? onSpeak;
  final VoidCallback? onExport;

  const MessageMenuSheet({
    super.key,
    required this.message,
    this.onCopy,
    this.onReply,
    this.onForward,
    this.onDelete,
    this.onSpeak,
    this.onExport,
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
            // Copying self-destruct/view-once content would defeat its lifetime.
            if (message.type == MessageType.text && !message.isSelfDestructing)
              _buildMenuItem(
                context,
                icon: Icons.copy,
                title: S.of(context)?.chatCopy ?? 'Copy',
                onTap: onCopy,
              ),
            if (message.type == MessageType.text && onSpeak != null)
              _buildMenuItem(
                context,
                icon: Icons.volume_up,
                title: S.of(context)?.chatReadAloud ?? 'Read Aloud',
                onTap: onSpeak,
              ),
            _buildMenuItem(
              context,
              icon: Icons.reply,
              title: S.of(context)?.chatReply ?? 'Reply',
              onTap: onReply,
            ),
            if (onForward != null && !message.isSelfDestructing)
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
