// ignore_for_file: invalid_use_of_protected_member
part of 'chat_page.dart';

/// AI 功能相关方法（改写、翻译、摘要、助手）
extension _ChatPageAiFeaturesMethods on _ChatPageState {
  String _smartReplyLanguageTag() =>
      Localizations.localeOf(context).toLanguageTag();

  void _resetAiSmartReplyState({bool clearAnchor = false}) {
    _smartReplySuggestions = const [];
    _isLoadingSmartReplySuggestions = false;
    if (clearAnchor) {
      _smartReplyAnchorMessageId = null;
    }
  }

  Widget _buildAiRewriteBar() {
    return AiRewriteBar(
      originalText: _rewriteOriginalText,
      rewrittenText: _rewriteResult,
      isRewriting: _isRewriting,
      selectedTone: _selectedTone,
      onToneSelected: _onRewriteTone,
      onAccept: (text) {
        _inputController.text = text;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
        setState(() {
          _showRewriteBar = false;
          _rewriteResult = null;
          _selectedTone = null;
        });
      },
      onDismiss: () {
        setState(() {
          _showRewriteBar = false;
          _rewriteResult = null;
          _selectedTone = null;
        });
      },
    );
  }

  void _onRewriteTone(AiTone tone) {
    if (!getIt.isRegistered<AiService>()) return;
    setState(() {
      _selectedTone = tone;
      _isRewriting = true;
      _rewriteResult = null;
    });
    getIt<AiService>()
        .rewriteMessage(_rewriteOriginalText, tone)
        .then((result) {
          if (mounted) {
            setState(() {
              _rewriteResult = result;
              _isRewriting = false;
            });
          }
        })
        .catchError((Object e) {
          if (mounted) {
            setState(() => _isRewriting = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('AI rewrite failed: $e')));
          }
        });
  }

  void _showAiRewriteBar() {
    final text = _inputController.text.trim();
    if (text.isEmpty || !getIt.isRegistered<AiService>()) return;
    setState(() {
      _resetAiSmartReplyState();
      _rewriteOriginalText = text;
      _showRewriteBar = true;
      _rewriteResult = null;
      _selectedTone = null;
    });
  }

  void _openAiAssistant() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AiAssistantPage()));
  }

  /// 群聊消息摘要
  void _summarizeRecentMessages() {
    if (!getIt.isRegistered<AiService>() || _isAiSummarizing) return;
    final messages = context.read<ChatBloc>().state.messages;
    final textMessages = messages
        .where((m) => m.type == MessageType.text && m.content.trim().isNotEmpty)
        .take(50)
        .toList()
        .reversed;
    if (textMessages.isEmpty) return;
    final texts = textMessages
        .map((m) => '${m.senderName}: ${m.content}')
        .join('\n');
    setState(() {
      _isAiSummarizing = true;
      _aiSummaryResult = null;
    });
    getIt<AiService>()
        .summarize(texts)
        .then((result) {
          if (mounted) {
            setState(() {
              _aiSummaryResult = result;
              _isAiSummarizing = false;
            });
          }
        })
        .catchError((Object e) {
          if (mounted) {
            setState(() => _isAiSummarizing = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Summarize failed: $e')));
          }
        });
  }

  Widget _buildAiSmartReplyBar() {
    return AiSmartReplyBar(
      suggestions: _smartReplySuggestions,
      isLoading: _isLoadingSmartReplySuggestions,
      onSelect: (reply) {
        _dismissAiSmartReplyBar();
        _sendMessage(reply);
      },
      onRefresh: _isLoadingSmartReplySuggestions
          ? null
          : () => unawaited(_refreshAiSmartReplies(force: true)),
      onDismiss: _dismissAiSmartReplyBar,
    );
  }

  void _handleSmartReplyStateChanged(ChatState state) {
    if (!mounted || !getIt.isRegistered<AiService>()) {
      return;
    }

    if (_inputController.text.trim().isNotEmpty ||
        _showSearchBar ||
        _showRewriteBar ||
        _isMultiSelectMode) {
      return;
    }

    final suggestionContext = AiReplySuggestionHelper.buildContext(
      state.messages,
    );
    if (suggestionContext == null) {
      if (_smartReplySuggestions.isNotEmpty ||
          _isLoadingSmartReplySuggestions ||
          _smartReplyAnchorMessageId != null) {
        setState(() {
          _resetAiSmartReplyState(clearAnchor: true);
        });
      }
      return;
    }

    if (_dismissedSmartReplyAnchorMessageId ==
        suggestionContext.anchorMessageId) {
      return;
    }

    if (_smartReplyAnchorMessageId == suggestionContext.anchorMessageId &&
        (_smartReplySuggestions.isNotEmpty ||
            _isLoadingSmartReplySuggestions)) {
      return;
    }

    unawaited(_refreshAiSmartReplies(state: state));
  }

  Future<void> _refreshAiSmartReplies({
    ChatState? state,
    bool force = false,
  }) async {
    if (!mounted || !getIt.isRegistered<AiService>()) {
      return;
    }

    final currentState = state ?? context.read<ChatBloc>().state;
    final suggestionContext = AiReplySuggestionHelper.buildContext(
      currentState.messages,
    );
    if (suggestionContext == null) {
      if (mounted) {
        setState(() {
          _resetAiSmartReplyState(clearAnchor: true);
        });
      }
      return;
    }

    if (!force &&
        _dismissedSmartReplyAnchorMessageId ==
            suggestionContext.anchorMessageId) {
      return;
    }

    setState(() {
      _isLoadingSmartReplySuggestions = true;
      _smartReplyAnchorMessageId = suggestionContext.anchorMessageId;
      if (force) {
        _dismissedSmartReplyAnchorMessageId = null;
        _smartReplySuggestions = const [];
      }
    });

    try {
      final replies = await AiReplySuggestionHelper.loadSuggestions(
        aiService: getIt<AiService>(),
        context: suggestionContext,
        language: _smartReplyLanguageTag(),
      );
      if (!mounted) return;

      final latestState = context.read<ChatBloc>().state;
      final latestContext = AiReplySuggestionHelper.buildContext(
        latestState.messages,
      );
      if (latestContext?.anchorMessageId != suggestionContext.anchorMessageId) {
        return;
      }
      if (_dismissedSmartReplyAnchorMessageId ==
          suggestionContext.anchorMessageId) {
        return;
      }
      if (_inputController.text.trim().isNotEmpty ||
          _showSearchBar ||
          _showRewriteBar ||
          _isMultiSelectMode) {
        setState(() {
          _resetAiSmartReplyState();
        });
        return;
      }

      setState(() {
        _smartReplySuggestions = replies;
        _isLoadingSmartReplySuggestions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resetAiSmartReplyState();
      });
    }
  }

  Future<List<String>> _loadAiSmartReplies() async {
    if (!getIt.isRegistered<AiService>()) {
      return const [];
    }

    final suggestionContext = AiReplySuggestionHelper.buildContext(
      context.read<ChatBloc>().state.messages,
    );
    if (suggestionContext == null) {
      return const [];
    }

    return AiReplySuggestionHelper.loadSuggestions(
      aiService: getIt<AiService>(),
      context: suggestionContext,
      language: _smartReplyLanguageTag(),
    );
  }

  void _dismissAiSmartReplyBar() {
    setState(() {
      _dismissedSmartReplyAnchorMessageId = _smartReplyAnchorMessageId;
      _resetAiSmartReplyState();
    });
  }
}
