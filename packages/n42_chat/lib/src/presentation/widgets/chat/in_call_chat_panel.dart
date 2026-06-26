import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../services/voip/livekit_service.dart';

/// 通话中聊天面板
///
/// 在群组通话界面中以底部滑出面板形式显示
/// 使用 LiveKit DataChannel 在参与者间传递文本消息
class InCallChatPanel extends StatefulWidget {
  final LiveKitService liveKitService;

  const InCallChatPanel({super.key, required this.liveKitService});

  @override
  State<InCallChatPanel> createState() => _InCallChatPanelState();
}

class _InCallChatPanelState extends State<InCallChatPanel> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<InCallChatMessage>? _messageSub;

  @override
  void initState() {
    super.initState();
    _messageSub = widget.liveKitService.onChatMessage.listen((_) {
      if (mounted) {
        setState(() {});
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final rawText = _textController.text;
    if (rawText.trim().isEmpty) return;

    widget.liveKitService.sendChatMessage(rawText);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.liveKitService.chatMessages;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 顶部手柄
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context)?.callInCallChat ?? 'In-Call Chat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  S.of(context)?.callMessagesCount(messages.length) ??
                      '${messages.length} messages',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // 消息列表
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      S.of(context)?.callNoMessagesYet ??
                          'No messages yet.\nSend a message to get started.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(messages[index]);
                    },
                  ),
          ),

          // 输入栏
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText:
                          S.of(context)?.callTypeMessage ?? 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.greenAccent),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(InCallChatMessage message) {
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发送者标记
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: message.isLocal
                  ? Colors.greenAccent.withValues(alpha: 0.2)
                  : Colors.blueAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: message.isLocal
                      ? Colors.greenAccent
                      : Colors.blueAccent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.isLocal
                          ? (S.of(context)?.callYouSender ?? 'You')
                          : message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: message.isLocal
                            ? Colors.greenAccent
                            : Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  message.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
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
