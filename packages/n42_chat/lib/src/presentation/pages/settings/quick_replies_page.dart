import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';
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
  bool _isSaving = false;

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

  Future<void> _saveReplies(List<QuickReplyEntity> replies) async {
    final data = replies.map((e) => e.toJson()).toList();
    await widget.storageDataSource.saveQuickReplies(data);
  }

  Future<void> _applyRepliesUpdate(
    List<QuickReplyEntity> Function(List<QuickReplyEntity> current) update,
  ) async {
    if (_isSaving) {
      return;
    }

    final previousReplies = List<QuickReplyEntity>.from(_replies);
    final messenger = ScaffoldMessenger.of(context);
    final saveFailedMessage = S.of(context)?.commonSaveFailed ?? 'Save failed';
    final nextReplies = update(List<QuickReplyEntity>.from(_replies));

    setState(() {
      _isSaving = true;
      _replies = nextReplies;
    });

    try {
      await _saveReplies(nextReplies);
    } catch (e) {
      debugLog('QuickRepliesPage: Failed to save replies: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _replies = previousReplies;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(saveFailedMessage),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
              _applyRepliesUpdate((current) {
                current.removeWhere((r) => r.id == reply.id);
                return current;
              });
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

              _applyRepliesUpdate((current) {
                if (isEditing) {
                  // 编辑现有回复
                  final index = current.indexWhere((r) => r.id == reply.id);
                  if (index != -1) {
                    current[index] = reply.copyWith(content: content);
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
                  current.add(newReply);
                }
                return current;
              });
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
              _applyRepliesUpdate(
                (_) => QuickReplyEntity.createDefaultReplies(),
              );
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
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: l10n?.settingsManageQuickReplies ?? 'Manage Quick Replies',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isSaving ? null : _addReply,
            tooltip: l10n?.settingsAddQuickReply ?? 'Add',
          ),
          PopupMenuButton<String>(
            enabled: !_isSaving,
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
          ? _buildEmptyState(l10n)
          : _buildReplyList(),
    );
  }

  Widget _buildEmptyState(S? l10n) {
    return N42EmptyState.noData(
      title: l10n?.settingsNoQuickReplies ?? 'No quick replies',
      description:
          l10n?.settingsDefaultQuickReplies ??
          'Default quick replies will be shown',
      buttonText: l10n?.settingsAddQuickReply ?? 'Add Quick Reply',
      onButtonPressed: _addReply,
    );
  }

  Widget _buildReplyList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _replies.length,
      // onReorderItem 取代 onReorder（Flutter 3.41 后弃用）：新回调已按"移除
      // oldIndex 后"的下标给出 newIndex，故不再需要 newIndex -= 1 的补偿。
      onReorderItem: (oldIndex, newIndex) {
        _applyRepliesUpdate((current) {
          final item = current.removeAt(oldIndex);
          current.insert(newIndex, item);
          // 更新顺序
          for (var i = 0; i < current.length; i++) {
            current[i] = current[i].copyWith(order: i);
          }
          return current;
        });
      },
      itemBuilder: (context, index) {
        final reply = _replies[index];
        return _buildReplyItem(reply, index);
      },
    );
  }

  Widget _buildReplyItem(QuickReplyEntity reply, int index) {
    return Container(
      key: ValueKey(reply.id),
      color: context.surfaceColor,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: IgnorePointer(
          ignoring: _isSaving,
          child: ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_handle,
              color: context.textTertiary,
            ),
          ),
        ),
        title: Text(
          reply.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            color: context.textPrimary,
          ),
        ),
        subtitle: reply.isSystem
            ? Text(
                'Default',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: context.textTertiary,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!reply.isSystem)
              IconButton(
                tooltip: S.of(context)?.commonEdit ?? 'Edit',
                icon: Icon(
                  Icons.edit_outlined,
                  color: context.textTertiary,
                ),
                onPressed: _isSaving ? null : () => _editReply(reply),
              ),
            IconButton(
              tooltip: S.of(context)?.commonDelete ?? 'Delete',
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              onPressed: _isSaving ? null : () => _deleteReply(reply),
            ),
          ],
        ),
      ),
    );
  }
}
