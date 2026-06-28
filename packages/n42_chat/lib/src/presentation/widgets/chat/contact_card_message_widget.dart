import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/a11y_l10n.dart';
import '../../widgets/common/common_widgets.dart';

/// 联系人名片消息组件
///
/// 微信风格名片卡片：头像 + 昵称 + "个人名片" 标签
class ContactCardMessageWidget extends StatelessWidget {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final bool isFromMe;
  final VoidCallback? onTap;

  const ContactCardMessageWidget({
    super.key,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.isFromMe = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: A11yL10n.of(context).contactCard(displayName),
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.dividerColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 名片内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  N42Avatar(
                    imageUrl: avatarUrl,
                    name: displayName,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userId,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 底部分隔线 + 标签
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.dividerColor,
                  ),
                ),
              ),
              child: Text(
                S.of(context)?.personalCard ?? 'Personal Card',
                style: TextStyle(
                  fontSize: 11,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
