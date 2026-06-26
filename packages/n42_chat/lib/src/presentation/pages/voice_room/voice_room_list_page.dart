import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/voice_room_entity.dart';
import '../../../domain/repositories/voice_room_repository.dart';
import '../../../services/voip/voice_room_service.dart';
import '../../blocs/voice_room/voice_room_bloc.dart';
import '../../blocs/voice_room/voice_room_event.dart';
import '../../blocs/voice_room/voice_room_state.dart';

/// 活跃语音房间列表页
class VoiceRoomListPage extends StatelessWidget {
  const VoiceRoomListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VoiceRoomBloc(
        repository: getIt<IVoiceRoomRepository>(),
        voiceRoomService: getIt<VoiceRoomService>(),
      )..add(const LoadActiveVoiceRooms()),
      child: const _VoiceRoomListView(),
    );
  }
}

class _VoiceRoomListView extends StatelessWidget {
  const _VoiceRoomListView();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s?.voiceRoomTitle ?? 'Voice Rooms')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<VoiceRoomBloc, VoiceRoomState>(
        builder: (context, state) {
          if (state.isLoading && state.activeRooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.activeRooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic_none,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s?.voiceRoomNoActive ?? 'No active voice rooms',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.activeRooms.length,
            itemBuilder: (context, index) {
              final room = state.activeRooms[index];
              return _VoiceRoomCard(room: room);
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final bloc = context.read<VoiceRoomBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider<VoiceRoomBloc>.value(
        value: bloc,
        child: _CreateVoiceRoomDialog(parentContext: context),
      ),
    );
  }
}

class _CreateVoiceRoomDialog extends StatefulWidget {
  final BuildContext parentContext;

  const _CreateVoiceRoomDialog({required this.parentContext});

  @override
  State<_CreateVoiceRoomDialog> createState() => _CreateVoiceRoomDialogState();
}

class _CreateVoiceRoomDialogState extends State<_CreateVoiceRoomDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _topicController;
  bool _submitStarted = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _topicController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocListener<VoiceRoomBloc, VoiceRoomState>(
      listenWhen: (previous, current) {
        if (!_submitStarted) return false;
        return previous.isLoading != current.isLoading ||
            previous.isConnected != current.isConnected ||
            previous.error != current.error;
      },
      listener: (context, state) {
        if (!_submitStarted) return;

        if (state.isConnected && state.room != null) {
          final parentContext = widget.parentContext;
          if (!parentContext.mounted) return;
          Navigator.of(context).pop();
          parentContext.push(Routes.voiceRoomPath(state.room!.roomId));
          return;
        }

        if (!state.isLoading && state.error != null) {
          setState(() {
            _submitStarted = false;
            _inlineError = state.error;
          });
        }
      },
      child: AlertDialog(
        title: Text(s?.voiceRoomCreate ?? 'Create Voice Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: s?.voiceRoomName ?? 'Room name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: s?.voiceRoomTopic ?? 'Topic (optional)',
                border: const OutlineInputBorder(),
              ),
            ),
            if (_inlineError != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _inlineError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _submitStarted
                ? null
                : () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          BlocBuilder<VoiceRoomBloc, VoiceRoomState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading ||
                previous.error != current.error,
            builder: (context, state) {
              final isSubmitting = _submitStarted && state.isLoading;
              return FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        final name = _nameController.text.trim();
                        if (name.isEmpty) return;

                        setState(() {
                          _submitStarted = true;
                          _inlineError = null;
                        });
                        context.read<VoiceRoomBloc>().add(
                          CreateVoiceRoom(
                            name: name,
                            topic: _topicController.text.trim().isEmpty
                                ? null
                                : _topicController.text.trim(),
                          ),
                        );
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(s?.voiceRoomCreate ?? 'Create'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VoiceRoomCard extends StatelessWidget {
  final VoiceRoomEntity room;

  const _VoiceRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push(Routes.voiceRoomPath(room.roomId));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 直播标识
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s?.voiceRoomLive ?? 'LIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (room.topic != null) ...[
                const SizedBox(height: 6),
                Text(
                  room.topic!,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.participantCount}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.mic,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.speakers.length + room.hosts.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    s?.voiceRoomJoin ?? 'Join',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
