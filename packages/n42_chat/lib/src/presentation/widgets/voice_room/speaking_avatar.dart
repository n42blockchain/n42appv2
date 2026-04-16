import 'package:flutter/material.dart';

import '../../../domain/entities/voice_room_entity.dart';

/// 说话脉冲动画头像
class SpeakingAvatar extends StatefulWidget {
  final VoiceRoomParticipant participant;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SpeakingAvatar({
    super.key,
    required this.participant,
    this.radius = 30,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<SpeakingAvatar> createState() => _SpeakingAvatarState();
}

class _SpeakingAvatarState extends State<SpeakingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.participant.isSpeaking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SpeakingAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.participant.isSpeaking && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.participant.isSpeaking && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.participant.isSpeaking ? _animation.value : 1.0,
                child: Container(
                  width: widget.radius * 2 + 8,
                  height: widget.radius * 2 + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.participant.isSpeaking
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: widget.radius,
                        backgroundImage: widget.participant.avatarUrl != null
                            ? NetworkImage(widget.participant.avatarUrl!)
                            : null,
                        child: widget.participant.avatarUrl == null
                            ? Text(
                                _getInitials(widget.participant.displayName),
                                style: TextStyle(fontSize: widget.radius * 0.5),
                              )
                            : null,
                      ),
                      // 静音指示器
                      if (widget.participant.isMuted)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.mic_off,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      // 举手指示器
                      if (widget.participant.isHandRaised)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: const Text(
                              '✋',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: widget.radius * 2.5,
            child: Text(
              widget.participant.displayName,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static final RegExp _whitespacePattern = RegExp(r'\s+');

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(_whitespacePattern);
    if (words.length == 1) {
      return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    }
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
}
