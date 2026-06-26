import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../blocs/thread/thread_bloc.dart';
import '../../blocs/thread/thread_event.dart';
import '../../blocs/thread/thread_state.dart';

/// 线程详情页
///
/// 全屏展示线程根消息及所有回复，底部有回复输入栏。
class ThreadDetailPage extends StatelessWidget {
  final String roomId;
  final String threadRootEventId;

  const ThreadDetailPage({
    super.key,
    required this.roomId,
    required this.threadRootEventId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThreadBloc(messageRepository: getIt<IMessageRepository>())
        ..add(
          InitializeThread(
            roomId: roomId,
            threadRootEventId: threadRootEventId,
          ),
        ),
      child: const _ThreadDetailView(),
    );
  }
}

class _ThreadDetailView extends StatefulWidget {
  const _ThreadDetailView();

  @override
  State<_ThreadDetailView> createState() => _ThreadDetailViewState();
}

class _ThreadDetailViewState extends State<_ThreadDetailView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      context.read<ThreadBloc>().add(const LoadMoreThreadMessages());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s?.threadTitle ?? 'Thread'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ThreadBloc, ThreadState>(
        builder: (context, state) {
          if (state.isLoading && state.replies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.rootMessage == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(state.error!),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // 加载更多指示器
                    if (state.isLoading && state.replies.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),

                    // 根消息
                    if (state.rootMessage != null)
                      SliverToBoxAdapter(
                        child: _buildRootMessage(context, state.rootMessage!),
                      ),

                    // 分隔线 + 回复计数
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Text(
                              state.replies.length == 1
                                  ? (s?.threadReply ?? '1 reply')
                                  : (s?.threadReplies(state.replies.length) ??
                                        '${state.replies.length} replies'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 回复列表
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final reply = state.replies[index];
                        return _buildReplyItem(context, reply);
                      }, childCount: state.replies.length),
                    ),

                    // 底部留白
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),

              // 输入栏
              _buildInputBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRootMessage(BuildContext context, MessageEntity message) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 发送者信息
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: message.senderAvatarUrl != null
                    ? NetworkImage(message.senderAvatarUrl!)
                    : null,
                child: message.senderAvatarUrl == null
                    ? Text(
                        message.senderInitials,
                        style: const TextStyle(fontSize: 14),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.senderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      _formatTime(message.timestamp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 消息内容
          Text(message.content, style: const TextStyle(fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildReplyItem(BuildContext context, MessageEntity reply) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: reply.senderAvatarUrl != null
                ? NetworkImage(reply.senderAvatarUrl!)
                : null,
            child: reply.senderAvatarUrl == null
                ? Text(
                    reply.senderInitials,
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(reply.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(reply.content, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ThreadState state) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: s?.threadReplyPlaceholder ?? 'Reply in thread...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send,
              color: state.isSending
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                  : theme.colorScheme.primary,
            ),
            onPressed: state.isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final rawText = _textController.text;
    if (rawText.trim().isEmpty) return;

    context.read<ThreadBloc>().add(SendThreadTextMessage(rawText));
    _textController.clear();

    // 滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
