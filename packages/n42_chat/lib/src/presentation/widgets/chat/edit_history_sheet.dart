import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../data/datasources/matrix/matrix_reaction_datasource.dart';

/// 编辑历史 BottomSheet
///
/// 点击 "已编辑" 标签后弹出，显示消息的所有编辑历史版本
class EditHistorySheet extends StatefulWidget {
  final String roomId;
  final String messageId;

  const EditHistorySheet({
    super.key,
    required this.roomId,
    required this.messageId,
  });

  @override
  State<EditHistorySheet> createState() => _EditHistorySheetState();
}

class _EditHistorySheetState extends State<EditHistorySheet> {
  List<EditHistoryEntry>? _entries;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEditHistory();
  }

  Future<void> _loadEditHistory() async {
    try {
      final datasource = MatrixReactionDataSource(MatrixClientManager.instance);
      final entries = await datasource.getEditHistory(
        widget.roomId,
        widget.messageId,
      );
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final s = S.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // 拖拽手柄
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  s?.chatEditHistory ?? 'Edit History',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(isDark),
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: context.dividerColor,
              ),
              // 内容
              Expanded(
                child: _buildContent(scrollController, isDark, s),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    ScrollController scrollController,
    bool isDark,
    S? s,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final entries = _entries;
    if (entries == null || entries.isEmpty) {
      return Center(
        child: Text(
          s?.chatEditHistory ?? 'No edit history',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // 反转列表，最新的编辑在上面
    final reversed = entries.reversed.toList();

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reversed.length,
      separatorBuilder: (_, _) => Divider(
        height: 0.5,
        indent: 16,
        endIndent: 16,
        color: context.dividerColor,
      ),
      itemBuilder: (context, index) {
        final entry = reversed[index];
        return _buildHistoryItem(entry, isDark, s);
      },
    );
  }

  Widget _buildHistoryItem(
    EditHistoryEntry entry,
    bool isDark,
    S? s,
  ) {
    final timeStr = _formatTime(entry.editedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间标签
          Row(
            children: [
              if (entry.isOriginal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    s?.chatOriginalMessage ?? 'Original',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.edit,
                  size: 12,
                  color: context.textTertiary,
                ),
              if (!entry.isOriginal) const SizedBox(width: 4),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12,
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 消息内容
          Text(
            entry.content,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimaryOf(isDark),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    if (messageDay == today) {
      return '$hour:$minute';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday $hour:$minute';
    } else {
      return '${time.month}/${time.day} $hour:$minute';
    }
  }
}
