import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/chat_folder_entity.dart';
import '../../blocs/chat_folder/chat_folder_bloc.dart';
import '../../blocs/chat_folder/chat_folder_event.dart';
import '../../blocs/chat_folder/chat_folder_state.dart';
import '../../widgets/common/common_widgets.dart';

/// 聊天文件夹管理页面
///
/// 支持创建、编辑、删除自定义文件夹
class ChatFolderManagementPage extends StatelessWidget {
  const ChatFolderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.chatFolderManagement ?? 'Manage Folders',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22),
            onPressed: () => _showCreateDialog(context, l10n),
          ),
        ],
      ),
      body: BlocBuilder<ChatFolderBloc, ChatFolderState>(
        builder: (context, state) {
          return ListView(
            children: [
              // 系统文件夹
              _buildSectionHeader(
                context,
                isDark,
                l10n?.chatFolderSystem ?? 'System Folders',
              ),
              ...state.systemFolders.map(
                (folder) =>
                    _buildFolderTile(context, isDark, folder, isSystem: true),
              ),

              const SizedBox(height: 16),

              // 自定义文件夹
              _buildSectionHeader(
                context,
                isDark,
                l10n?.chatFolderCustom ?? 'Custom Folders',
              ),
              if (state.customFolders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 48,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.chatFolderEmpty ?? 'No custom folders yet',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...state.customFolders.map(
                  (folder) => _buildFolderTile(
                    context,
                    isDark,
                    folder,
                    isSystem: false,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildFolderTile(
    BuildContext context,
    bool isDark,
    ChatFolderEntity folder, {
    required bool isSystem,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Text(
          folder.icon ?? '📁',
          style: const TextStyle(fontSize: 20),
        ),
        title: Text(
          folder.name,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: isSystem
            ? Text(
                _getFilterDescription(folder.filter),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              )
            : null,
        trailing: isSystem
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    onPressed: () => _showEditDialog(context, folder),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmDelete(context, folder),
                  ),
                ],
              ),
      ),
    );
  }

  String _getFilterDescription(ChatFolderFilter filter) {
    final parts = <String>[];
    if (filter.unreadOnly) parts.add('Unread only');
    if (filter.mutedOnly) parts.add('Muted only');
    if (!filter.includeDirectMessages) parts.add('No DMs');
    if (!filter.includeGroups) parts.add('No groups');
    if (!filter.includeChannels) parts.add('No channels');
    return parts.isEmpty ? 'All chats' : parts.join(', ');
  }

  void _showCreateDialog(BuildContext context, S? l10n) {
    final nameController = TextEditingController();
    String selectedIcon = '📁';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n?.chatFolderCreate ?? 'Create Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: l10n?.chatFolderNameHint ?? 'Folder name',
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              // 图标选择
              Wrap(
                spacing: 8,
                children: ['📁', '⭐', '💼', '🏠', '🎮', '📚', '🎵', '💬']
                    .map(
                      (icon) => GestureDetector(
                        onTap: () => setState(() => selectedIcon = icon),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: icon == selectedIcon
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: icon == selectedIcon
                                ? Border.all(color: AppColors.primary)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n?.commonCancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  context.read<ChatFolderBloc>().add(
                    CreateChatFolder(name: name, icon: selectedIcon),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(l10n?.commonSend ?? 'Create'),
            ),
          ],
        ),
      ),
    ).whenComplete(nameController.dispose);
  }

  void _showEditDialog(BuildContext context, ChatFolderEntity folder) {
    final nameController = TextEditingController(text: folder.name);
    final l10n = S.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.chatFolderEdit ?? 'Edit Folder'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: l10n?.chatFolderNameHint ?? 'Folder name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                context.read<ChatFolderBloc>().add(
                  UpdateChatFolder(folder.copyWith(name: name)),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).whenComplete(nameController.dispose);
  }

  void _confirmDelete(BuildContext context, ChatFolderEntity folder) {
    final l10n = S.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.commonDelete ?? 'Delete'),
        content: Text('Delete folder "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatFolderBloc>().add(DeleteChatFolder(folder.id));
              Navigator.pop(dialogContext);
            },
            child: Text(
              l10n?.commonDelete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
