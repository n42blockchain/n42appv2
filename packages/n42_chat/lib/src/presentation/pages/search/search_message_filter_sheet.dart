import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/search_result_entity.dart';

Future<MessageSearchFilter?> showMessageSearchFilterSheet(
  BuildContext context, {
  required MessageSearchFilter currentFilter,
}) {
  return showModalBottomSheet<MessageSearchFilter?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return _SearchMessageFilterSheet(currentFilter: currentFilter);
    },
  );
}

class _SearchMessageFilterSheet extends StatefulWidget {
  final MessageSearchFilter currentFilter;

  const _SearchMessageFilterSheet({required this.currentFilter});

  @override
  State<_SearchMessageFilterSheet> createState() =>
      _SearchMessageFilterSheetState();
}

class _SearchMessageFilterSheetState extends State<_SearchMessageFilterSheet> {
  late final TextEditingController _senderController;
  late MessageType? _messageType;
  late bool _onlyFromMe;
  late bool _hasMediaOnly;
  late _RelativeDateFilter _relativeDate;

  @override
  void initState() {
    super.initState();
    _senderController = TextEditingController(
      text: widget.currentFilter.senderId ?? '',
    );
    _messageType = widget.currentFilter.messageType;
    _onlyFromMe = widget.currentFilter.onlyFromMe;
    _hasMediaOnly = widget.currentFilter.hasMediaOnly;
    _relativeDate = _RelativeDateFilter.fromSentAfter(
      widget.currentFilter.sentAfter,
    );
  }

  @override
  void dispose() {
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Message Filters',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _senderController,
                  decoration: const InputDecoration(
                    labelText: 'Sender User ID',
                    hintText: '@alice:example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip(context, null, 'Any'),
                    _buildTypeChip(context, MessageType.text, 'Text'),
                    _buildTypeChip(context, MessageType.image, 'Image'),
                    _buildTypeChip(context, MessageType.video, 'Video'),
                    _buildTypeChip(context, MessageType.audio, 'Audio'),
                    _buildTypeChip(context, MessageType.file, 'File'),
                    _buildTypeChip(context, MessageType.poll, 'Poll'),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _RelativeDateFilter.values.map((value) {
                    final selected = value == _relativeDate;
                    return ChoiceChip(
                      label: Text(value.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _relativeDate = value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Only my messages'),
                  value: _onlyFromMe,
                  onChanged: (value) => setState(() => _onlyFromMe = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Media only'),
                  value: _hasMediaOnly,
                  onChanged: (value) => setState(() => _hasMediaOnly = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _apply,
                    child: const Text(
                      'Apply',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, MessageType? type, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _messageType == type,
      onSelected: (_) => setState(() => _messageType = type),
    );
  }

  void _clearAll() {
    setState(() {
      _senderController.clear();
      _messageType = null;
      _onlyFromMe = false;
      _hasMediaOnly = false;
      _relativeDate = _RelativeDateFilter.anytime;
    });
  }

  void _apply() {
    final now = DateTime.now();
    DateTime? sentAfter;
    switch (_relativeDate) {
      case _RelativeDateFilter.anytime:
        sentAfter = null;
        break;
      case _RelativeDateFilter.last24Hours:
        sentAfter = now.subtract(const Duration(hours: 24));
        break;
      case _RelativeDateFilter.last7Days:
        sentAfter = now.subtract(const Duration(days: 7));
        break;
      case _RelativeDateFilter.last30Days:
        sentAfter = now.subtract(const Duration(days: 30));
        break;
    }

    final senderId = _senderController.text.trim();
    final filter = MessageSearchFilter(
      senderId: senderId.isEmpty ? null : senderId,
      messageType: _messageType,
      sentAfter: sentAfter,
      onlyFromMe: _onlyFromMe,
      hasMediaOnly: _hasMediaOnly,
    );

    Navigator.of(context).pop(filter.isEmpty ? null : filter);
  }
}

enum _RelativeDateFilter {
  anytime('Any time'),
  last24Hours('24h'),
  last7Days('7d'),
  last30Days('30d');

  final String label;

  const _RelativeDateFilter(this.label);

  static _RelativeDateFilter fromSentAfter(DateTime? sentAfter) {
    if (sentAfter == null) {
      return _RelativeDateFilter.anytime;
    }

    final delta = DateTime.now().difference(sentAfter);
    if (delta <= const Duration(hours: 24)) {
      return _RelativeDateFilter.last24Hours;
    }
    if (delta <= const Duration(days: 7)) {
      return _RelativeDateFilter.last7Days;
    }
    if (delta <= const Duration(days: 30)) {
      return _RelativeDateFilter.last30Days;
    }
    return _RelativeDateFilter.anytime;
  }
}
