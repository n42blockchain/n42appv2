import 'package:flutter/material.dart';

/// 底部弹幕输入框（"说点什么…"）。内置发送节流，防止刷屏。
class DanmuInputBar extends StatefulWidget {
  const DanmuInputBar({
    super.key,
    required this.onSend,
    this.minInterval = const Duration(milliseconds: 800),
  });

  /// 发送回调。返回的 Future 完成前输入框保持禁用态。
  final Future<void> Function(String text) onSend;

  /// 两次发送之间的最小间隔（节流）。
  final Duration minInterval;

  @override
  State<DanmuInputBar> createState() => _DanmuInputBarState();
}

class _DanmuInputBarState extends State<DanmuInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  DateTime? _lastSentAt;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_sending) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    if (_lastSentAt != null &&
        now.difference(_lastSentAt!) < widget.minInterval) {
      // 命中节流：给出轻量提示而非静默吞掉，避免用户以为按钮失灵。
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('发送太快了，稍后再试'),
            duration: Duration(milliseconds: 700),
          ),
        );
      return;
    }

    setState(() => _sending = true);
    try {
      await widget.onSend(text);
      _lastSentAt = DateTime.now();
      _controller.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('发送失败，请重试')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: '说点什么…',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sending ? null : _handleSend,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
