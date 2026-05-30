import 'package:flutter/material.dart';

import '../../services/live_chat_service.dart';

/// 透明弹幕层：底部左侧半透明滚动列表，新弹幕自动滚到底部。
class DanmuOverlay extends StatefulWidget {
  const DanmuOverlay({super.key, required this.stream});

  final Stream<List<LiveDanmu>> stream;

  @override
  State<DanmuOverlay> createState() => _DanmuOverlayState();
}

class _DanmuOverlayState extends State<DanmuOverlay> {
  final ScrollController _scroll = ScrollController();

  /// 是否贴底：用户上滑查看历史时为 false，不再强制自动滚动。
  bool _pinned = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    _pinned = pos.pixels >= pos.maxScrollExtent - 40;
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_pinned) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LiveDanmu>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <LiveDanmu>[];
        _jumpToBottom();
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            controller: _scroll,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (context, i) => _DanmuBubble(danmu: items[i]),
          ),
        );
      },
    );
  }
}

class _DanmuBubble extends StatelessWidget {
  const _DanmuBubble({required this.danmu});

  final LiveDanmu danmu;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6, right: 60),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, height: 1.2),
          children: [
            TextSpan(
              text: '${danmu.sender}：',
              style: TextStyle(
                color: danmu.isMe
                    ? const Color(0xFFFFD24D)
                    : const Color(0xFF8AB4FF),
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: danmu.text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
