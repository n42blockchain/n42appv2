// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/ai_assistant/data/chat_ai_channel.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_assistant_engine.dart';
import 'package:n42_wallet/features/ai_assistant/domain/wallet_snapshot.dart';

class WalletAssistantPage extends StatefulWidget {
  const WalletAssistantPage({super.key, required this.snapshot});

  final WalletSnapshot snapshot;

  @override
  State<WalletAssistantPage> createState() => _WalletAssistantPageState();
}

class _WalletAssistantPageState extends State<WalletAssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _engine = const WalletAssistantEngine(channel: ChatAiChannel());
  final _messages = <_WalletAssistantMessage>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _WalletAssistantMessage.assistant(_snapshotIntro(widget.snapshot)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _controller.clear();
      _messages.add(_WalletAssistantMessage.user(text));
      _loading = true;
    });
    _scrollToEnd();

    String reply;
    try {
      reply = await _engine.answer(text, widget.snapshot);
    } catch (_) {
      reply = const WalletAssistantEngine().fallbackAnswer();
    }
    if (!mounted) return;

    setState(() {
      _messages.add(_WalletAssistantMessage.assistant(reply));
      _loading = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return Scaffold(
      key: const ValueKey<String>('wallet_assistant_page'),
      backgroundColor: c.bgBase,
      appBar: AppBar(
        backgroundColor: c.bgBase,
        elevation: 0,
        foregroundColor: c.textPrimary,
        title: Text(
          'Wallet AI',
          style: AppTypography.headline.copyWith(
            color: c.textPrimary,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SnapshotHeader(snapshot: widget.snapshot),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.space8,
                  AppSpacing.space4,
                  AppSpacing.space8,
                  AppSpacing.space6,
                ),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_loading && index == _messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            _PromptRow(onPromptTap: _send),
            _Composer(
              controller: _controller,
              loading: _loading,
              onSubmitted: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotHeader extends StatelessWidget {
  const _SnapshotHeader({required this.snapshot});

  final WalletSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    final topSymbols = snapshot.assets.take(3).map((a) => a.symbol).join(' / ');
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space4,
        AppSpacing.space8,
        AppSpacing.space6,
      ),
      padding: AppSpacing.cardInset,
      decoration: BoxDecoration(
        color: c.bgSurface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: c.brand, size: 22),
          ),
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${snapshot.totalUsd.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: c.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  [
                    snapshot.chainName,
                    if (topSymbols.isNotEmpty) topSymbols,
                  ].whereType<String>().where((v) => v.isNotEmpty).join(' / '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Text(
            'Read-only',
            style: AppTypography.captionSm.copyWith(
              color: c.textTertiary,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _WalletAssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    final isUser = message.fromUser;
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = math.min(width * 0.82, 560.0);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: EdgeInsets.only(bottom: AppSpacing.space4),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space4,
          ),
          decoration: BoxDecoration(
            color: isUser ? c.brand : c.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: isUser ? null : Border.all(color: c.border),
          ),
          child: Text(
            message.text,
            style: AppTypography.body.copyWith(
              color: isUser ? Colors.white : c.textPrimary,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.space4),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space6,
          vertical: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: c.brand),
        ),
      ),
    );
  }
}

class _PromptRow extends StatelessWidget {
  const _PromptRow({required this.onPromptTap});

  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    // 'Gas' 暂不列入:快照未注入 gasGwei(打开面板未查 gas),引擎 gasAnswer
    // 恒返回"unavailable"——不展示恒不可用的入口(接线复审第二轮 P1)。
    // gas 数据源接通后可复原。
    const prompts = ['Balance', 'Portfolio', 'Help'];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: AppSpacing.space2),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: AppTypography.caption.copyWith(
                color: c.textPrimary,
                letterSpacing: 0,
              ),
            ),
            side: BorderSide(color: c.border),
            backgroundColor: c.bgSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () => onPromptTap(prompt),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.loading,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool loading;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = AppColorTokens.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space8,
        AppSpacing.space4,
        AppSpacing.space8,
        AppSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: c.bgBase,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !loading,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmitted,
              style: AppTypography.body.copyWith(
                color: c.textPrimary,
                letterSpacing: 0,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about balance, portfolio, gas',
                hintStyle: AppTypography.body.copyWith(
                  color: c.textTertiary,
                  letterSpacing: 0,
                ),
                filled: true,
                fillColor: c.bgSurface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space6,
                  vertical: AppSpacing.space4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.brand),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          IconButton.filled(
            onPressed: loading ? null : () => onSubmitted(controller.text),
            icon: const Icon(Icons.arrow_upward_rounded),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

class _WalletAssistantMessage {
  const _WalletAssistantMessage({required this.text, required this.fromUser});

  factory _WalletAssistantMessage.user(String text) =>
      _WalletAssistantMessage(text: text, fromUser: true);

  factory _WalletAssistantMessage.assistant(String text) =>
      _WalletAssistantMessage(text: text, fromUser: false);

  final String text;
  final bool fromUser;
}

String _snapshotIntro(WalletSnapshot snapshot) {
  final assetCount = snapshot.assets.length;
  final total = '\$${snapshot.totalUsd.toStringAsFixed(2)}';
  if (assetCount == 0) {
    return 'Wallet snapshot loaded. Total value: $total. No visible assets found.';
  }
  final top = snapshot.assets.take(3).map((a) => a.symbol).join(', ');
  return 'Wallet snapshot loaded. Total value: $total. Top assets: $top.';
}
