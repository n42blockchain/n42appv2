import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

Future<DateTime?> showScheduledSendPicker(BuildContext context) {
  final l10n = S.of(context);
  final now = DateTime.now();

  return showModalBottomSheet<DateTime>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.scheduledSendTitle ?? 'Schedule message',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ScheduledSendOption(
              icon: Icons.schedule,
              label: l10n?.scheduledSendInOneHour ?? 'In 1 hour',
              scheduledAt: now.add(const Duration(hours: 1)),
            ),
            _ScheduledSendOption(
              icon: Icons.nightlight_round,
              label: l10n?.scheduledSendTonight ?? 'Tonight (8:00 PM)',
              scheduledAt: DateTime(now.year, now.month, now.day, 20, 0),
            ),
            _ScheduledSendOption(
              icon: Icons.wb_sunny,
              label:
                  l10n?.scheduledSendTomorrowMorning ??
                  'Tomorrow morning (9:00 AM)',
              scheduledAt: DateTime(now.year, now.month, now.day + 1, 9, 0),
            ),
            const Divider(),
            const _ScheduledSendOption(
              icon: Icons.calendar_today,
              label: 'Custom',
              scheduledAt: null,
              isCustom: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

class _ScheduledSendOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? scheduledAt;
  final bool isCustom;

  const _ScheduledSendOption({
    required this.icon,
    required this.label,
    required this.scheduledAt,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final optionLabel = isCustom
        ? (l10n?.scheduledSendCustom ?? 'Pick a date & time')
        : label;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(optionLabel),
      onTap: () async {
        if (!isCustom) {
          Navigator.pop(context, scheduledAt);
          return;
        }

        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(hours: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate == null || !context.mounted) {
          return;
        }

        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime == null || !context.mounted) {
          return;
        }

        final nextDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (nextDateTime.isAfter(DateTime.now())) {
          Navigator.pop(context, nextDateTime);
        }
      },
    );
  }
}
