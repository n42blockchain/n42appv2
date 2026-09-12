import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/notifications/notification_filter_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/notification_filter_rules.dart';
import '../../../n42_chat.dart';
import '../../widgets/common/common_widgets.dart';

/// 智能通知过滤设置页
///
/// 管理优先关键词 / 屏蔽关键词 / 优先发送者：
/// - 优先：命中即强制通知（绕过仅提及/静音/免打扰）；
/// - 屏蔽：命中即抑制通知。
/// 规则保存到 [NotificationFilterStore] 并即时应用到运行中的推送服务。
class NotificationFilterPage extends StatefulWidget {
  final NotificationFilterStore? store;

  const NotificationFilterPage({super.key, this.store});

  @override
  State<NotificationFilterPage> createState() => _NotificationFilterPageState();
}

class _NotificationFilterPageState extends State<NotificationFilterPage> {
  late final NotificationFilterStore _store;
  NotificationFilterRules _rules = NotificationFilterRules.empty;
  bool _loaded = false;
  bool _loadFailed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? NotificationFilterStore();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loaded = false;
      _loadFailed = false;
    });
    try {
      final rules = await _store.load();
      if (mounted) setState(() => _rules = rules);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _apply(NotificationFilterRules rules) async {
    if (!mounted || _isSaving) return;
    final previous = _rules;
    setState(() {
      _rules = rules;
      _isSaving = true;
    });
    try {
      await _store.save(rules);
      N42Chat.pushService?.setFilterRules(rules);
    } catch (_) {
      if (mounted) {
        setState(() => _rules = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.commonSaveFailed ?? 'Failed to save'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<String> _addEntry(List<String> list, String value) {
    final v = value.trim();
    if (v.isEmpty || list.contains(v)) return list;
    return [...list, v];
  }

  Future<void> _promptAdd({
    required String title,
    required String hint,
    required void Function(String) onAdd,
  }) async {
    var input = '';
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text(title, style: TextStyle(color: context.textPrimary)),
        content: TextField(
          onChanged: (value) => input = value,
          autofocus: true,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, input),
            child: Text(S.of(context)?.commonAdd ?? 'Add'),
          ),
        ],
      ),
    );
    if (mounted && result != null && result.trim().isNotEmpty) {
      onAdd(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.settingsSmartFilter ?? 'Smart Filter',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _loadFailed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context)?.commonLoadFailed ?? 'Failed to load'),
                  TextButton(
                    onPressed: _load,
                    child: Text(S.of(context)?.commonRetry ?? 'Retry'),
                  ),
                ],
              ),
            )
          : AbsorbPointer(
              absorbing: _isSaving,
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  _buildHeaderNote(
                    'Priority rules always notify (bypassing mute, '
                    'mentions-only and Do Not Disturb). Muted keywords '
                    'suppress notifications.',
                  ),
                  const SizedBox(height: 8),
                  _buildKeywordSection(
                    title: 'Priority keywords',
                    icon: Icons.priority_high,
                    iconColor: AppColors.primary,
                    entries: _rules.priorityKeywords,
                    hint: 'e.g. urgent',
                    onAdd: (v) => _apply(
                      _rules.copyWith(
                        priorityKeywords: _addEntry(_rules.priorityKeywords, v),
                      ),
                    ),
                    onRemove: (v) => _apply(
                      _rules.copyWith(
                        priorityKeywords: _rules.priorityKeywords
                            .where((e) => e != v)
                            .toList(),
                      ),
                    ),
                  ),
                  _buildKeywordSection(
                    title: 'Muted keywords',
                    icon: Icons.notifications_off_outlined,
                    iconColor: AppColors.warning,
                    entries: _rules.mutedKeywords,
                    hint: 'e.g. spam',
                    onAdd: (v) => _apply(
                      _rules.copyWith(
                        mutedKeywords: _addEntry(_rules.mutedKeywords, v),
                      ),
                    ),
                    onRemove: (v) => _apply(
                      _rules.copyWith(
                        mutedKeywords: _rules.mutedKeywords
                            .where((e) => e != v)
                            .toList(),
                      ),
                    ),
                  ),
                  _buildKeywordSection(
                    title: 'Priority senders',
                    icon: Icons.person_outline,
                    iconColor: AppColors.info,
                    entries: _rules.prioritySenders,
                    hint: '@user:server.com',
                    onAdd: (v) => _apply(
                      _rules.copyWith(
                        prioritySenders: _addEntry(_rules.prioritySenders, v),
                      ),
                    ),
                    onRemove: (v) => _apply(
                      _rules.copyWith(
                        prioritySenders: _rules.prioritySenders
                            .where((e) => e != v)
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: context.surfaceColor,
                    child: SwitchListTile(
                      title: Text(
                        'Case sensitive',
                        style: TextStyle(color: context.textPrimary),
                      ),
                      value: _rules.caseSensitive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) =>
                          _apply(_rules.copyWith(caseSensitive: v)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: context.textSecondary),
      ),
    );
  }

  Widget _buildKeywordSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> entries,
    required String hint,
    required void Function(String) onAdd,
    required void Function(String) onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: S.of(context)?.commonAdd ?? 'Add',
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  onPressed: () =>
                      _promptAdd(title: title, hint: hint, onAdd: onAdd),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: entries.isEmpty
                ? Text(
                    'None',
                    style: TextStyle(color: context.textTertiary, fontSize: 13),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entries
                        .map(
                          (e) => Chip(
                            label: Text(e),
                            onDeleted: () => onRemove(e),
                            deleteIconColor: context.textSecondary,
                            backgroundColor: context.pageBackground,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
