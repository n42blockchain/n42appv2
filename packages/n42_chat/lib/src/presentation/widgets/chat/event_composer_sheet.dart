import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/event_message_data.dart';

/// 弹出日程/事件编辑面板，返回填好的 [EventMessageData]（取消返回 null）。
Future<EventMessageData?> showEventComposerSheet(BuildContext context) {
  return showModalBottomSheet<EventMessageData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EventComposerSheet(),
  );
}

class _EventComposerSheet extends StatefulWidget {
  const _EventComposerSheet();

  @override
  State<_EventComposerSheet> createState() => _EventComposerSheetState();
}

class _EventComposerSheetState extends State<_EventComposerSheet> {
  final _titleC = TextEditingController();
  final _locationC = TextEditingController();
  final _descC = TextEditingController();

  DateTime _start = _roundedNow();
  DateTime? _end;
  String? _error;

  static DateTime _roundedNow() {
    final now = DateTime.now().add(const Duration(hours: 1));
    return DateTime(now.year, now.month, now.day, now.hour);
  }

  @override
  void dispose() {
    _titleC.dispose();
    _locationC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 5),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submit() {
    final title = _titleC.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    if (_end != null && !_end!.isAfter(_start)) {
      setState(() => _error = 'End time must be after start');
      return;
    }
    Navigator.pop(
      context,
      EventMessageData(
        title: title,
        startsAt: _start,
        endsAt: _end,
        location: _locationC.text.trim(),
        description: _descC.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'New Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleC,
              autofocus: true,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _dateTile(
              label: 'Starts',
              value: EventMessageData.formatLocal(_start),
              onTap: () async {
                final picked = await _pickDateTime(_start);
                if (picked != null) {
                  setState(() {
                    _start = picked;
                    if (_end != null && !_end!.isAfter(_start)) _end = null;
                  });
                }
              },
            ),
            _dateTile(
              label: 'Ends',
              value: _end != null
                  ? EventMessageData.formatLocal(_end!)
                  : 'Optional',
              onTap: () async {
                final picked = await _pickDateTime(_end ??
                    _start.add(const Duration(hours: 1)));
                if (picked != null) setState(() => _end = picked);
              },
              onClear: _end != null ? () => setState(() => _end = null) : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationC,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descC,
              maxLines: 3,
              style: TextStyle(color: context.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Send Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 18, color: context.textSecondary),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(fontSize: 15, color: context.textPrimary)),
            const Spacer(),
            Text(value,
                style: TextStyle(fontSize: 14, color: context.textSecondary)),
            if (onClear != null)
              IconButton(
                icon: Icon(Icons.close, size: 16, color: context.textTertiary),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
