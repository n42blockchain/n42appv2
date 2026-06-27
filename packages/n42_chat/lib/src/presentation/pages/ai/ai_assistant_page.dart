import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ai_assistant_entity.dart';
import '../../../domain/repositories/ai_repository.dart';
import '../../blocs/ai_assistant/ai_assistant_bloc.dart';
import '../../blocs/ai_assistant/ai_assistant_event.dart';
import '../../blocs/ai_assistant/ai_assistant_state.dart';
import '../../widgets/common/common_widgets.dart';
import 'ai_assistant_settings_page.dart';

/// AI 助手聊天页面
class AiAssistantPage extends StatelessWidget {
  final String? assistantId;

  const AiAssistantPage({super.key, this.assistantId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AiAssistantBloc(aiRepository: getIt<IAiRepository>())
            ..add(InitializeAiAssistant(assistantId: assistantId)),
      child: const _AiAssistantView(),
    );
  }
}

class _AiAssistantView extends StatefulWidget {
  const _AiAssistantView();

  @override
  State<_AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<_AiAssistantView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleDraftChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_handleDraftChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDraftChanged() {
    if (mounted) {
      setState(() {});
    }
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
    final blocState = context.read<AiAssistantBloc>().state;
    if (!_canSend(blocState)) return;

    final text = _textController.text.trim();

    context.read<AiAssistantBloc>().add(SendAiMessage(text));
    _textController.clear();
    _scrollToBottom();
  }

  bool _canSend(AiAssistantState state) {
    return state.isAvailable &&
        !state.isGenerating &&
        _textController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = S.of(context);

    return BlocConsumer<AiAssistantBloc, AiAssistantState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.isGenerating != current.isGenerating ||
          previous.messages != current.messages,
      listener: (context, state) {
        if (state.error == null) {
          _lastShownError = null;
        } else if (state.error != _lastShownError) {
          _lastShownError = state.error;
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.isGenerating || state.messages.isNotEmpty) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        final assistantName = state.assistant?.name ?? 'N42 AI';

        return Scaffold(
          backgroundColor: context.pageBackground,
          appBar: N42AppBar(
            title: assistantName,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: () => _openSettings(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 22),
                onPressed: () => _confirmClearHistory(context, l10n),
              ),
            ],
          ),
          body: Column(
            children: [
              // 消息列表
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessageList(context, state, isDark),
              ),
              // 输入栏
              _buildInputBar(context, state, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    AiAssistantState state,
    bool isDark,
  ) {
    final allMessages = [...state.messages];

    if (allMessages.isEmpty && !state.isGenerating) {
      return _buildWelcome(context, state, isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: allMessages.length + (state.isGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < allMessages.length) {
          return _buildMessageBubble(allMessages[index], isDark);
        }
        // 流式响应中的消息
        return _buildStreamingBubble(state.streamingText, isDark);
      },
    );
  }

  Widget _buildWelcome(
    BuildContext context,
    AiAssistantState state,
    bool isDark,
  ) {
    final l10n = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.assistant?.avatar ?? '🤖',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              state.assistant?.name ?? 'N42 AI',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.aiAssistantWelcome ??
                  'Ask me anything! I can help with questions, writing, analysis, and more.',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: context.textSecondary,
              ),
            ),
            if (!state.isAvailable) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n?.aiAssistantNotConfigured ??
                      'AI service not configured. Please set API key in settings.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.warning),
                ),
              ),
            ],
            // Web3 快捷建议 chips
            if (state.isAvailable) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildSuggestionChip(
                    context,
                    l10n?.aiSuggestionGasFee ?? 'What is Gas fee?',
                    Icons.local_gas_station_outlined,
                  ),
                  _buildSuggestionChip(
                    context,
                    l10n?.aiSuggestionDefi ?? 'DeFi Beginner Guide',
                    Icons.account_balance_outlined,
                  ),
                  _buildSuggestionChip(
                    context,
                    l10n?.aiSuggestionSecurity ??
                        'How to check contract security',
                    Icons.security_outlined,
                  ),
                  _buildSuggestionChip(
                    context,
                    l10n?.aiSuggestionBridge ?? 'Cross-chain bridging',
                    Icons.swap_horiz_outlined,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final isDark = context.isDarkMode;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 1.3,
          color: context.textPrimary,
        ),
      ),
      backgroundColor: isDark
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        context.read<AiAssistantBloc>().add(SendAiMessage(label));
      },
    );
  }

  Widget _buildMessageBubble(AiChatMessage message, bool isDark) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Text('🤖', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: isUser ? null : const Radius.circular(4),
                  topRight: isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: GestureDetector(
                onLongPress: () => _copyMessage(message.content),
                child: isUser
                    ? SelectableText(
                        message.content,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      )
                    : MarkdownBody(
                        data: message.content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 15,
                            color: context.textPrimary,
                            height: 1.4,
                          ),
                          code: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.greenAccent.shade200
                                : Colors.green.shade800,
                            backgroundColor: isDark
                                ? Colors.black26
                                : Colors.grey.shade100,
                            fontFamily: 'monospace',
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: isDark
                                ? Colors.black26
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          listBullet: TextStyle(
                            fontSize: 15,
                            color: context.textPrimary,
                          ),
                          strong: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreamingBubble(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Text('🤖', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(
                  16,
                ).copyWith(topLeft: const Radius.circular(4)),
              ),
              child: text.isEmpty
                  ? _buildTypingIndicator()
                  : SelectableText(
                      text,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.textPrimary,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _TypingDot(delay: i * 200),
        );
      }),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    AiAssistantState state,
    bool isDark,
  ) {
    final l10n = S.of(context);
    final canSend = _canSend(state);

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: AppColors.dividerOf(isDark)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.inputBgOf(isDark),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                enabled: state.isAvailable && !state.isGenerating,
                decoration: InputDecoration(
                  hintText: l10n?.aiAssistantWelcome ?? 'Ask anything...',
                  hintStyle: TextStyle(
                    color: context.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: context.textPrimary,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (state.isGenerating)
            IconButton(
              onPressed: () =>
                  context.read<AiAssistantBloc>().add(const StopAiGeneration()),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.stop, color: Colors.white, size: 18),
              ),
            )
          else
            IconButton(
              onPressed: canSend ? _sendMessage : null,
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: canSend ? AppColors.primary : Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context)?.chatCopied ?? 'Copied'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<AiAssistantBloc>(),
          child: const AiAssistantSettingsPage(),
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, S? l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.aiAssistantClearHistory ?? 'Clear History'),
        content: Text(
          l10n?.aiAssistantClearHistoryConfirm ??
              'Are you sure you want to clear all chat history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AiAssistantBloc>().add(const ClearAiChatHistory());
            },
            child: Text(
              l10n?.commonDelete ?? 'Delete',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 打字动画圆点
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_animation.value * 0.7),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
