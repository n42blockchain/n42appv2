import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/quick_reply_entity.dart';
import '../../widgets/common/common_widgets.dart';

/// 快捷回复管理页面
class QuickRepliesPage extends StatefulWidget {
  final PreferencesDataSource storageDataSource;

  const QuickRepliesPage({super.key, required this.storageDataSource});

  @override
  State<QuickRepliesPage> createState() => _QuickRepliesPageState();
}

class _QuickRepliesPageState extends State<QuickRepliesPage> {
  List<QuickReplyEntity> _replies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    try {
      final data = await widget.storageDataSource.getQuickReplies();
      if (!mounted) return;
      setState(() {
        _replies = data.map((e) => QuickReplyEntity.fromJson(e)).toList();
        _replies.sort((a, b) => a.order.compareTo(b.order));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _replies = QuickReplyEntity.createDefaultReplies();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReplies() async {
    final data = _replies.map((e) => e.toJson()).toList();
    await widget.storageDataSource.saveQuickReplies(data);
  }

  void _addReply() {
    _showEditDialog(null);
  }

  void _editReply(QuickReplyEntity reply) {
    _showEditDialog(reply);
  }

  void _deleteReply(QuickReplyEntity reply) {
    final l10n = S.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.settingsDeleteQuickReply ?? 'Delete Quick Reply'),
        content: Text('Delete "${reply.content}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _replies.removeWhere((r) => r.id == reply.id);
              });
              _saveReplies();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n?.commonDelete ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(QuickReplyEntity? reply) {
    final l10n = S.of(context);
    final controller = TextEditingController(text: reply?.content);
    final isEditing = reply != null;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isEditing
              ? (l10n?.settingsEditQuickReply ?? 'Edit Quick Reply')
              : (l10n?.settingsAddQuickReply ?? 'Add Quick Reply'),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: l10n?.settingsQuickReply ?? 'Quick Reply',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final content = controller.text.trim();
              if (content.isEmpty) return;

              Navigator.pop(ctx);

              setState(() {
                if (isEditing) {
                  // 编辑现有回复
                  final index = _replies.indexWhere((r) => r.id == reply.id);
                  if (index != -1) {
                    _replies[index] = reply.copyWith(content: content);
                  }
                } else {
                  // 添加新回复
                  final newReply = QuickReplyEntity(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    content: content,
                    order: _replies.length,
                    isSystem: false,
                    createdAt: DateTime.now(),
                  );
                  _replies.add(newReply);
                }
              });
              _saveReplies();
            },
            child: Text(l10n?.commonSave ?? 'Save'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _resetToDefaults() {
    final l10n = S.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will remove all custom quick replies and restore defaults. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _replies = QuickReplyEntity.createDefaultReplies();
              });
              _saveReplies();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: N42AppBar(
        title: l10n?.settingsManageQuickReplies ?? 'Manage Quick Replies',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addReply,
            tooltip: l10n?.settingsAddQuickReply ?? 'Add',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                _resetToDefaults();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset to Defaults'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? N42Loading(message: l10n?.commonLoading ?? 'Loading...')
          : _replies.isEmpty
          ? _buildEmptyState(isDark, l10n)
          : _buildReplyList(isDark),
    );
  }

  Widget _buildEmptyState(bool isDark, S? l10n) {
    return N42EmptyState.noData(
      title: l10n?.settingsNoQuickReplies ?? 'No quick replies',
      description:
          l10n?.settingsDefaultQuickReplies ??
          'Default quick replies will be shown',
      buttonText: l10n?.settingsAddQuickReply ?? 'Add Quick Reply',
      onButtonPressed: _addReply,
    );
  }

  Widget _buildReplyList(bool isDark) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _replies.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _replies.removeAt(oldIndex);
          _replies.insert(newIndex, item);
          // 更新顺序
          for (var i = 0; i < _replies.length; i++) {
            _replies[i] = _replies[i].copyWith(order: i);
          }
        });
        _saveReplies();
      },
      itemBuilder: (context, index) {
        final reply = _replies[index];
        return _buildReplyItem(reply, isDark, index);
      },
    );
  }

  Widget _buildReplyItem(QuickReplyEntity reply, bool isDark, int index) {
    return Container(
      key: ValueKey(reply.id),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ),
        title: Text(
          reply.content,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: reply.isSystem
            ? Text(
                'Default',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!reply.isSystem)
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                onPressed: () => _editReply(reply),
              ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              onPressed: () => _deleteReply(reply),
            ),
          ],
        ),
      ),
    );
  }
}
