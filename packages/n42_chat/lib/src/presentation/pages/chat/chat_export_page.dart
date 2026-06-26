import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/chat_export_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../widgets/common/common_widgets.dart';

/// 聊天记录导出页面
class ChatExportPage extends StatefulWidget {
  final String roomName;
  final String? roomId;
  final List<MessageEntity> messages;

  const ChatExportPage({
    super.key,
    required this.roomName,
    this.roomId,
    this.messages = const [],
  });

  @override
  State<ChatExportPage> createState() => _ChatExportPageState();
}

class _ChatExportPageState extends State<ChatExportPage> {
  ExportFormat _format = ExportFormat.html;
  ExportDateRange _dateRange = ExportDateRange.all;
  List<MessageEntity> _messages = const [];
  DateTime? _customStart;
  DateTime? _customEnd;
  bool _isLoadingMessages = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _messages = List<MessageEntity>.from(widget.messages);
    if (widget.roomId != null) {
      _loadMessagesForExport();
    }
  }

  List<MessageEntity> get _filteredMessages {
    return sortMessagesForExport(
      filterMessagesForExport(_messages, _dateRange, _customStart, _customEnd),
    );
  }

  int get _filteredCount => _filteredMessages.length;

  Future<void> _loadMessagesForExport() async {
    if (_isLoadingMessages || widget.roomId == null) return;

    setState(() => _isLoadingMessages = true);

    try {
      final repository = getIt<IMessageRepository>();
      var bestMessages = List<MessageEntity>.from(_messages);

      for (final limit in [200, 500, 1000, 2000]) {
        final fetchedMessages = await repository.getMessages(
          widget.roomId!,
          limit: limit,
        );
        if (fetchedMessages.length > bestMessages.length) {
          bestMessages = fetchedMessages;
        }
        if (fetchedMessages.length < limit) {
          break;
        }
      }

      if (mounted) {
        setState(() {
          _messages = bestMessages;
        });
      }
    } catch (_) {
      // 保留已传入的消息列表作为回退
    } finally {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  void _onDateRangeChanged(ExportDateRange range) {
    setState(() {
      _dateRange = range;
      if (range == ExportDateRange.custom) {
        final now = DateTime.now();
        _customStart ??= DateTime(now.year, now.month, now.day);
        _customEnd ??= DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      }
    });
  }

  Future<void> _pickCustomDate({required bool isStart}) async {
    final initialDate = isStart
        ? (_customStart ?? DateTime.now())
        : (_customEnd ?? _customStart ?? DateTime.now());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      if (isStart) {
        _customStart = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
        if (_customEnd != null && _customEnd!.isBefore(_customStart!)) {
          _customEnd = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            23,
            59,
            59,
            999,
          );
        }
      } else {
        _customEnd = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          23,
          59,
          59,
          999,
        );
      }
    });
  }

  Future<void> _export() async {
    var completedWithExit = false;
    setState(() => _isExporting = true);

    try {
      await ChatExportService.instance.exportAndShare(
        messages: _messages,
        roomName: widget.roomName,
        format: _format,
        dateRange: _dateRange,
        customStart: _customStart,
        customEnd: _customEnd,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatExportSuccess ?? 'Export successful',
            ),
          ),
        );
        completedWithExit = true;
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.chatExportFailed(e.toString()) ??
                  'Export failed: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted && !completedWithExit) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: N42AppBar(
        title: S.of(context)?.chatExportTitle ?? 'Export Chat',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          if (_isLoadingMessages)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Loading more chat history for export...',
                      style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),

          if (_isLoadingMessages) const SizedBox(height: 16),

          // 导出格式
          _buildSection(
            title: S.of(context)?.chatExportFormat ?? 'Export Format',
            isDark: isDark,
            child: RadioGroup<ExportFormat>(
              groupValue: _format,
              onChanged: (v) => setState(() => _format = v!),
              child: Column(
                children: [
                  _buildRadioTile(
                    title: 'HTML',
                    subtitle:
                        S.of(context)?.chatExportHtmlDesc ??
                        'Readable in any browser with styled layout',
                    value: ExportFormat.html,
                    isDark: isDark,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: context.dividerColor,
                  ),
                  _buildRadioTile(
                    title: 'JSON',
                    subtitle:
                        S.of(context)?.chatExportJsonDesc ??
                        'Machine-readable structured data format',
                    value: ExportFormat.json,
                    isDark: isDark,
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: context.dividerColor,
                  ),
                  _buildRadioTile(
                    title: 'TXT',
                    subtitle:
                        'Plain-text transcript for notes, backup, or compliance review',
                    value: ExportFormat.txt,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 日期范围
          _buildSection(
            title: S.of(context)?.chatExportDateRange ?? 'Date Range',
            isDark: isDark,
            child: RadioGroup<ExportDateRange>(
              groupValue: _dateRange,
              onChanged: (v) => _onDateRangeChanged(v!),
              child: Column(
                children: [
                  for (final range in [
                    (
                      ExportDateRange.all,
                      S.of(context)?.chatExportAll ?? 'All Messages',
                    ),
                    (
                      ExportDateRange.lastWeek,
                      S.of(context)?.chatExportLastWeek ?? 'Last 7 Days',
                    ),
                    (
                      ExportDateRange.lastMonth,
                      S.of(context)?.chatExportLastMonth ?? 'Last Month',
                    ),
                    (
                      ExportDateRange.last3Months,
                      S.of(context)?.chatExportLast3Months ?? 'Last 3 Months',
                    ),
                    (ExportDateRange.custom, 'Custom Range'),
                  ]) ...[
                    _buildRadioTile(
                      title: range.$2,
                      value: range.$1,
                      isDark: isDark,
                    ),
                    if (range.$1 != ExportDateRange.custom)
                      Divider(
                        height: 1,
                        indent: 56,
                        color: context.dividerColor,
                      ),
                  ],
                ],
              ),
            ),
          ),

          if (_dateRange == ExportDateRange.custom)
            Container(
              color: context.surfaceColor,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  _buildDateTile(
                    label: 'Start',
                    value: _customStart,
                    isDark: isDark,
                    onTap: () => _pickCustomDate(isStart: true),
                  ),
                  const SizedBox(height: 8),
                  _buildDateTile(
                    label: 'End',
                    value: _customEnd,
                    isDark: isDark,
                    onTap: () => _pickCustomDate(isStart: false),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 统计信息
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${S.of(context)?.chatExportMessageCount ?? "Messages to export"}: $_filteredCount / ${_messages.length}',
                    style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 导出按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed:
                  _isExporting || _isLoadingMessages || _filteredCount == 0
                  ? null
                  : _export,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      S.of(context)?.chatExportButton ?? 'Export & Share',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
        ),
        Container(
          color: context.surfaceColor,
          child: child,
        ),
      ],
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required bool isDark,
  }) {
    return RadioListTile<T>(
      title: Text(
        title,
        style: TextStyle(color: context.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: context.textSecondary,
              ),
            )
          : null,
      value: value,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.dividerColor,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: ${value != null ? _formatDate(value) : "Select date"}',
                style: TextStyle(
                  color: context.textPrimary,
                ),
              ),
            ),
            const Icon(AppIcons.chevron),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
