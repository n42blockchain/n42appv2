import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/quick_reply_entity.dart';

/// 快捷回复选择弹窗
class QuickReplySheet extends StatefulWidget {
  /// 选择回复后的回调
  final void Function(String content) onSelect;

  /// 跳转到管理页面的回调
  final VoidCallback? onManage;

  /// 安全存储数据源
  final PreferencesDataSource storageDataSource;

  /// AI 智能回复建议加载器
  final Future<List<String>> Function()? smartReplyLoader;

  const QuickReplySheet({
    super.key,
    required this.onSelect,
    this.onManage,
    required this.storageDataSource,
    this.smartReplyLoader,
  });

  @override
  State<QuickReplySheet> createState() => _QuickReplySheetState();
}

class _QuickReplySheetState extends State<QuickReplySheet> {
  List<QuickReplyEntity> _replies = [];
  List<String> _smartReplies = [];
  bool _isLoading = true;
  bool _isLoadingSmartReplies = false;

  @override
  void initState() {
    super.initState();
    _loadReplies();
    _loadSmartReplies();
  }

  Future<void> _loadReplies() async {
    try {
      final data = await widget.storageDataSource.getQuickReplies();
      if (!mounted) return;
      setState(() {
        _replies = data.map((e) => QuickReplyEntity.fromJson(e)).toList();
        // 按使用频率和顺序排序
        _replies.sort((a, b) {
          // 最近使用的排前面
          if (a.lastUsed != null && b.lastUsed != null) {
            return b.lastUsed!.compareTo(a.lastUsed!);
          }
          if (a.lastUsed != null) return -1;
          if (b.lastUsed != null) return 1;
          // 然后按顺序
          return a.order.compareTo(b.order);
        });
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

  Future<void> _loadSmartReplies() async {
    final loader = widget.smartReplyLoader;
    if (loader == null) {
      return;
    }
    setState(() => _isLoadingSmartReplies = true);
    try {
      final replies = await loader();
      if (!mounted) return;
      setState(() {
        _smartReplies = replies
            .map((reply) => reply.trim())
            .where((reply) => reply.isNotEmpty)
            .toList();
        _isLoadingSmartReplies = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSmartReplies = false);
    }
  }

  void _onSelectReply(QuickReplyEntity reply) {
    // 更新最后使用时间
    widget.storageDataSource.updateQuickReplyLastUsed(reply.id);
    // 关闭弹窗
    Navigator.pop(context);
    // 回调
    widget.onSelect(reply.content);
  }

  void _onSelectSmartReply(String reply) {
    Navigator.pop(context);
    widget.onSelect(reply);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dividerOf(isDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.settingsQuickReply ?? 'Quick Reply',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(isDark),
                  ),
                ),
                if (widget.onManage != null)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onManage?.call();
                    },
                    child: Text(
                      l10n?.settingsManageQuickReplies ?? 'Manage',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 快捷回复列表
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _replies.isEmpty
                ? _buildSmartReplyAwareEmptyState(isDark, l10n)
                : _buildReplyList(isDark, l10n),
          ),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, S? l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flash_on_outlined,
            size: 48,
            color: AppColors.textTertiaryOf(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.settingsNoQuickReplies ?? 'No quick replies',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textTertiaryOf(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyList(bool isDark, S? l10n) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (_isLoadingSmartReplies)
          _buildSectionHeader(
            isDark,
            title: 'AI Suggestions',
            trailing: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_smartReplies.isNotEmpty) ...[
          _buildSectionHeader(isDark, title: 'AI Suggestions'),
          ..._smartReplies.map((reply) => _buildSmartReplyItem(reply, isDark)),
        ],
        if (_smartReplies.isNotEmpty && _replies.isNotEmpty)
          const Divider(height: 16),
        if (_replies.isNotEmpty) ...[
          _buildSectionHeader(
            isDark,
            title: l10n?.settingsQuickReply ?? 'Quick Reply',
          ),
          ..._replies.map((reply) => _buildReplyItem(reply, isDark)),
        ],
      ],
    );
  }

  Widget _buildSmartReplyAwareEmptyState(bool isDark, S? l10n) {
    if (_smartReplies.isNotEmpty || _isLoadingSmartReplies) {
      return _buildReplyList(isDark, l10n);
    }
    return _buildEmptyState(isDark, l10n);
  }

  Widget _buildSectionHeader(
    bool isDark, {
    required String title,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiaryOf(isDark),
            ),
          ),
          const Spacer(),
          ...?switch (trailing) {
            final widget? => [widget],
            _ => null,
          },
        ],
      ),
    );
  }

  Widget _buildReplyItem(QuickReplyEntity reply, bool isDark) {
    return InkWell(
      onTap: () => _onSelectReply(reply),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reply.content,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimaryOf(isDark),
                ),
              ),
            ),
            if (reply.isSystem)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white12
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiaryOf(isDark),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartReplyItem(String reply, bool isDark) {
    return InkWell(
      onTap: () => _onSelectSmartReply(reply),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reply,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimaryOf(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示快捷回复弹窗
Future<void> showQuickReplySheet({
  required BuildContext context,
  required void Function(String content) onSelect,
  VoidCallback? onManage,
  required PreferencesDataSource storageDataSource,
  Future<List<String>> Function()? smartReplyLoader,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => QuickReplySheet(
      onSelect: onSelect,
      onManage: onManage,
      storageDataSource: storageDataSource,
      smartReplyLoader: smartReplyLoader,
    ),
  );
}
