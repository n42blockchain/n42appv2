import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../pages/red_packet/send_red_packet_page.dart';

class SendRedPacketDialog extends StatefulWidget {
  final String receiverName;
  final bool isGroup;
  final int memberCount;
  final Future<bool> Function(
    String amount,
    String token,
    String greeting,
    int count,
    bool isLucky,
  )
  onSend;

  const SendRedPacketDialog({
    super.key,
    required this.receiverName,
    this.isGroup = false,
    this.memberCount = 1,
    required this.onSend,
  });

  @override
  State<SendRedPacketDialog> createState() => _SendRedPacketDialogState();
}

class _SendRedPacketDialogState extends State<SendRedPacketDialog> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigated || !mounted) return;
      _navigated = true;
      final navigator = Navigator.of(context);
      navigator.pop();
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => SendRedPacketPage(
            receiverName: widget.receiverName,
            isGroup: widget.isGroup,
            memberCount: widget.memberCount,
            onSend: widget.onSend,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// 开红包弹窗
///
/// [onOpen] fires when user taps the gold button (before result transition).
/// [onViewDetails] navigates to the full detail page.
/// [onGrabViralMessage] returns a string to broadcast in the chat room after
///   claiming — enabling WeChat-style social virality. Pass `null` to opt out.
class OpenRedPacketDialog extends StatefulWidget {
  final String senderName;
  final String? senderAvatar;
  final String? greeting;
  final OpenRedPacketStatus status;
  final String? claimedAmount;
  final String token;
  final VoidCallback? onOpen;
  final VoidCallback? onViewDetails;

  /// If non-null, called after the result transition to get a message that will
  /// be posted to the group chat (e.g. "🧧 grabbed a red packet • 3.5 CNY").
  final String? Function()? onGrabViralMessage;

  /// Whether the current user's claim is the "best luck" (highest amount).
  final bool isBestLuck;

  const OpenRedPacketDialog({
    super.key,
    required this.senderName,
    this.senderAvatar,
    this.greeting,
    this.status = OpenRedPacketStatus.canOpen,
    this.claimedAmount,
    this.token = 'CNY',
    this.onOpen,
    this.onViewDetails,
    this.onGrabViralMessage,
    this.isBestLuck = false,
  });

  @override
  State<OpenRedPacketDialog> createState() => _OpenRedPacketDialogState();
}

class _OpenRedPacketDialogState extends State<OpenRedPacketDialog>
    with TickerProviderStateMixin {
  late AnimationController _openController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isOpening = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();

    // Open: burst scale 1.0 → 1.2 → 0 (packet "explodes")
    _openController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_openController);

    // Shimmer for "best luck" gold text
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(_shimmerController);

    if (widget.status == OpenRedPacketStatus.opened) {
      _showResult = true;
    }
  }

  @override
  void dispose() {
    _openController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _openRedPacket() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    unawaited(HapticFeedback.mediumImpact());
    await _openController.forward();
    widget.onOpen?.call();
    widget.onGrabViralMessage?.call();

    if (mounted) setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _showResult ? _buildResultView(context) : _buildOpenView(context),
    );
  }

  // ─── Open view ─────────────────────────────────────────────────────────────

  Widget _buildOpenView(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE64340), Color(0xFFD63030)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.white70, size: 24),
              ),
            ),
          ),

          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            backgroundImage: widget.senderAvatar != null
                ? NetworkImage(widget.senderAvatar!)
                : null,
            child: widget.senderAvatar == null
                ? Text(
                    widget.senderName.isNotEmpty ? widget.senderName[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),

          Text(
            S.of(context)?.commonSenderRedPacket(widget.senderName) ??
                "${widget.senderName}'s Red Packet",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            widget.greeting ??
                S.of(context)?.commonRedPacketDefaultGreeting ??
                'Best wishes',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),

          if (widget.status == OpenRedPacketStatus.canOpen)
            AnimatedBuilder(
              animation: _openController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value.abs(),
                  child: GestureDetector(
                    onTap: _openRedPacket,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          S.of(context)?.commonOpenRedPacket ?? 'Open',
                          style: const TextStyle(
                            color: Color(0xFFB8860B),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            _buildStatusMessage(context),

          const SizedBox(height: 32),

          // Bottom branding
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'N42 Red Packet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(BuildContext context) {
    String message;
    switch (widget.status) {
      case OpenRedPacketStatus.opened:
        message = S.of(context)?.commonClaimed ?? 'Claimed';
      case OpenRedPacketStatus.empty:
        message =
            S.of(context)?.commonRedPacketAllClaimed ??
            'Red packet all claimed';
      case OpenRedPacketStatus.expired:
        message = S.of(context)?.commonRedPacketExpired ?? 'Red packet expired';
      default:
        message = '';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  // ─── Result view ────────────────────────────────────────────────────────────

  Widget _buildResultView(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red top section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE64340), Color(0xFFD63030)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ),

                Text(
                  S.of(context)?.commonSenderRedPacket(widget.senderName) ??
                      "${widget.senderName}'s Red Packet",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Amount
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.claimedAmount ?? '0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            ' ${widget.token}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Best luck badge — shown when user snagged the highest amount
                if (widget.isBestLuck) ...[
                  const SizedBox(height: 12),
                  _BestLuckBanner(shimmerAnimation: _shimmerAnimation),
                ],
              ],
            ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextButton(
                  onPressed: widget.onViewDetails,
                  child: Text(
                    S.of(context)?.commonViewRedPacketDetails ??
                        'View Red Packet Details',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Best luck banner ────────────────────────────────────────────────────────

class _BestLuckBanner extends StatelessWidget {
  final Animation<double> shimmerAnimation;

  const _BestLuckBanner({required this.shimmerAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFFFD700),
                Colors.white,
                Color(0xFFFFD700),
              ],
              stops: [
                (shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                shimmerAnimation.value.clamp(0.0, 1.0),
                (shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              S.of(context)?.redPacketBestLuckCongrats ??
                  'Best Luck! You got the most!',
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status enum ─────────────────────────────────────────────────────────────

enum OpenRedPacketStatus { canOpen, opened, empty, expired }

/// 发转账页面（全屏，解决溢出问题）
