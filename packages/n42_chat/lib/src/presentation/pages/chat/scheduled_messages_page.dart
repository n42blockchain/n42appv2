import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/scheduled_message_draft.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';

class ScheduledMessagesPage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ScheduledMessagesPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ScheduledMessagesPage> createState() => _ScheduledMessagesPageState();
}

class _ScheduledMessagesPageState extends State<ScheduledMessagesPage> {
  final PreferencesDataSource _preferences = getIt<PreferencesDataSource>();

  bool _isLoading = true;
  List<ScheduledMessageDraft> _drafts = const [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    try {
      final drafts = (await _preferences.getScheduledMessages(
        widget.roomId,
      )).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      if (!mounted) return;
      setState(() {
        _drafts = drafts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ScheduledMessagesPage._loadDrafts error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelDraft(ScheduledMessageDraft draft) async {
    try {
      context.read<ChatBloc>().add(CancelScheduledMessage(draft.messageId));
    } catch (_) {
      await _preferences.removeScheduledMessage(widget.roomId, draft.messageId);
    }

    if (!mounted) return;
    setState(() {
      _drafts = _drafts
          .where((item) => item.messageId != draft.messageId)
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scheduled message cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Scheduled Messages',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            AppIcons.back,
            color: context.textPrimary,
            size: 20,
          ),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDrafts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_drafts.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _drafts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final draft = _drafts[index];
                        return _buildDraftCard(draft);
                      },
                    )),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(
          Icons.schedule_send_outlined,
          size: 56,
          color: context.textSecondary,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No scheduled messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Long press Send, Photos, Files, a GIF, or a sticker to schedule follow-ups and reminders.',
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraftCard(ScheduledMessageDraft draft) {
    final cardColor = context.surfaceColor;
    final secondaryColor = context.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForDraft(draft), size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatScheduledAt(draft.scheduledAt),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _cancelDraft(draft),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildChip(label: draft.typeLabel),
          const SizedBox(height: 10),
          Text(
            draft.text,
            style: TextStyle(
              fontSize: 15,
              color: context.textPrimary,
            ),
          ),
          if (draft.pollOptions.isNotEmpty ||
              draft.mentionsRoom ||
              draft.mentionedUserIds.isNotEmpty ||
              draft.selfDestructAfter != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (draft.pollOptions.isNotEmpty)
                  _buildChip(
                    label: '${draft.pollOptions.length} options',
                  ),
                if (draft.mentionsRoom)
                  _buildChip(label: '@all'),
                if (draft.mentionedUserIds.isNotEmpty)
                  _buildChip(
                    label: '@${draft.mentionedUserIds.length} members',
                  ),
                if (draft.selfDestructAfter != null)
                  _buildChip(
                    label: 'Auto-delete ${draft.selfDestructAfter}s',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Created ${DateFormat('yyyy-MM-dd HH:mm').format(draft.createdAt)}',
            style: TextStyle(fontSize: 12, color: secondaryColor),
          ),
        ],
      ),
    );
  }

  IconData _iconForDraft(ScheduledMessageDraft draft) {
    if (draft.isGif) {
      return Icons.gif_box_outlined;
    }

    switch (draft.type) {
      case MessageType.poll:
        return Icons.poll_outlined;
      case MessageType.sticker:
        return Icons.emoji_emotions_outlined;
      default:
        return Icons.schedule;
    }
  }

  Widget _buildChip({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: context.textPrimary,
        ),
      ),
    );
  }

  String _formatScheduledAt(DateTime scheduledAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDay = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );

    if (scheduledDay == today) {
      return 'Today ${DateFormat('HH:mm').format(scheduledAt)}';
    }
    if (scheduledDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${DateFormat('HH:mm').format(scheduledAt)}';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(scheduledAt);
  }
}
