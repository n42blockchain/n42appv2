import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_folder_entity.dart';

/// 聊天文件夹标签栏
///
/// 水平滑动的标签栏，显示在会话列表顶部
class ChatFolderTabBar extends StatelessWidget {
  /// 文件夹列表
  final List<ChatFolderEntity> folders;

  /// 当前选中的文件夹 ID
  final String selectedFolderId;

  /// 切换回调
  final void Function(String folderId)? onFolderSelected;

  /// 添加文件夹回调
  final VoidCallback? onAddFolder;

  /// 长按文件夹回调（编辑/删除）
  final void Function(ChatFolderEntity folder)? onFolderLongPress;

  const ChatFolderTabBar({
    super.key,
    required this.folders,
    required this.selectedFolderId,
    this.onFolderSelected,
    this.onAddFolder,
    this.onFolderLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: folders.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == folders.length) {
            return _buildAddButton(isDark);
          }
          return _buildTab(context, folders[index], isDark);
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, ChatFolderEntity folder, bool isDark) {
    final isSelected = folder.id == selectedFolderId;

    return GestureDetector(
      onTap: () => onFolderSelected?.call(folder.id),
      onLongPress: folder.isSystem ? null : () => onFolderLongPress?.call(folder),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (folder.icon != null) ...[
              Text(
                folder.icon!,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              folder.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
            if (folder.showUnreadBadge && folder.unreadChatsCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  folder.unreadChatsCount > 99
                      ? '99+'
                      : '${folder.unreadChatsCount}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: onAddFolder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Icon(
          Icons.add,
          size: 20,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }
}
