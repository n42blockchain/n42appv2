import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/self_destruct_service.dart';
import '../../../domain/entities/message_entity.dart';

/// 阅后即焚倒计时覆盖层
///
/// 在消息气泡上方显示剩余时间 badge，消息过期后显示 "已销毁" 占位符。
class SelfDestructOverlay extends StatefulWidget {
  final MessageEntity message;
  final Widget child;

  const SelfDestructOverlay({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  State<SelfDestructOverlay> createState() => _SelfDestructOverlayState();
}

class _SelfDestructOverlayState extends State<SelfDestructOverlay> {
  Timer? _ticker;
  int _remainingSeconds = 0;
  bool _isDestroyed = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    // 每秒刷新一次剩余时间
    if (widget.message.isDestructionStarted && !_isDestroyed) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining();
      });
    }
  }

  void _updateRemaining() {
    final remaining = widget.message.remainingDestructionSeconds;
    if (remaining != null && remaining <= 0) {
      setState(() {
        _isDestroyed = true;
        _remainingSeconds = 0;
      });
      _ticker?.cancel();
    } else {
      setState(() {
        _remainingSeconds = remaining ?? widget.message.selfDestructAfter ?? 0;
      });
    }
  }

  @override
  void didUpdateWidget(SelfDestructOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.destroyedAt != widget.message.destroyedAt) {
      _updateRemaining();
      if (widget.message.isDestructionStarted && _ticker == null && !_isDestroyed) {
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          _updateRemaining();
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDestroyed) {
      return _buildDestroyedPlaceholder(context);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          top: -4,
          right: widget.message.isFromMe ? null : -4,
          left: widget.message.isFromMe ? -4 : null,
          child: _buildCountdownBadge(context),
        ),
      ],
    );
  }

  Widget _buildCountdownBadge(BuildContext context) {
    final text = SelfDestructService.formatDuration(_remainingSeconds);
    final isUrgent = _remainingSeconds <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withValues(alpha: 0.9)
            : Colors.orange.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 10,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestroyedPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.grey.shade200.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withValues(alpha: 0.3)
              : Colors.grey.shade300.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_delete_outlined,
            size: 14,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            'Message destroyed',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 阅后即焚未启动时的定时器图标提示
class SelfDestructPendingIcon extends StatelessWidget {
  final int durationSeconds;

  const SelfDestructPendingIcon({
    super.key,
    required this.durationSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Self-destruct: ${SelfDestructService.formatDuration(durationSeconds)}',
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(
          Icons.timer_outlined,
          size: 12,
          color: Colors.orange.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
