import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';

/// 时间分隔器（微信风格：无背景，纯灰色文字居中）
class TimeSeparator extends StatelessWidget {
  /// 时间
  final DateTime dateTime;

  /// 自定义格式化
  final String? customText;

  const TimeSeparator({
    super.key,
    required this.dateTime,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          customText ?? N42DateUtils.formatMessageTime(dateTime),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF808080) : const Color(0xFF999999),
          ),
        ),
      ),
    );
  }
}

/// 系统消息组件
///
/// 用于显示系统通知、群聊事件等
class SystemMessageWidget extends StatelessWidget {
  /// 消息内容
  final String message;

  /// 可点击部分
  final List<ClickableText>? clickableTexts;

  const SystemMessageWidget({
    super.key,
    required this.message,
    this.clickableTexts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
      child: Center(
        child: _buildText(),
      ),
    );
  }

  Widget _buildText() {
    if (clickableTexts == null || clickableTexts!.isEmpty) {
      return Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
        textAlign: TextAlign.center,
      );
    }

    // 构建富文本，支持可点击部分
    final spans = <InlineSpan>[];
    var currentIndex = 0;

    for (final clickable in clickableTexts!) {
      final startIndex = message.indexOf(clickable.text, currentIndex);
      if (startIndex == -1) continue;

      // 添加前面的普通文本
      if (startIndex > currentIndex) {
        spans.add(TextSpan(
          text: message.substring(currentIndex, startIndex),
        ));
      }

      // 添加可点击文本
      spans.add(TextSpan(
        text: clickable.text,
        style: const TextStyle(
          color: AppColors.link,
        ),
        recognizer: null, // 需要使用 GestureRecognizer
      ));

      currentIndex = startIndex + clickable.text.length;
    }

    // 添加剩余的普通文本
    if (currentIndex < message.length) {
      spans.add(TextSpan(
        text: message.substring(currentIndex),
      ));
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
        children: spans,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// 可点击文本
class ClickableText {
  final String text;
  final VoidCallback? onTap;

  const ClickableText({
    required this.text,
    this.onTap,
  });
}

/// 红包领取系统消息组件
/// 
/// 用于显示 "XXX领取了你的红包" 这类消息
class RedPacketClaimMessageWidget extends StatelessWidget {
  /// 领取者名称
  final String claimerName;
  
  /// 是否是自己发的红包被领取
  final bool isOwnRedPacket;
  
  /// 点击回调
  final VoidCallback? onTap;

  const RedPacketClaimMessageWidget({
    super.key,
    required this.claimerName,
    this.isOwnRedPacket = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE64340).withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 红包小图标
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE64340),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 消息文本
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(text: claimerName),
                      TextSpan(text: isOwnRedPacket ? (S.of(context)?.commonClaimedYour ?? ' claimed your ') : (S.of(context)?.commonClaimedText ?? ' claimed ')),
                      TextSpan(
                        text: S.of(context)?.profileRedPacket ?? 'Red Packet',
                        style: const TextStyle(
                          color: Color(0xFFE64340),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 正在输入指示器
class TypingIndicator extends StatefulWidget {
  /// 用户名
  final String? userName;

  /// 是否显示
  final bool isVisible;

  const TypingIndicator({
    super.key,
    this.userName,
    this.isVisible = true,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final value = (_controller.value + delay) % 1.0;
                  final opacity = (value < 0.5)
                      ? value * 2
                      : (1 - value) * 2;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withValues(alpha: opacity.clamp(0.3, 1.0)),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            widget.userName != null
                ? (S.of(context)?.commonUserTyping(widget.userName!) ?? '${widget.userName} is typing...')
                : (S.of(context)?.commonTyping ?? 'Typing...'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

