import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

/// 消息发送状态 (用于UI显示)
enum MessageStatus {
  /// 发送中
  sending,

  /// 已发送
  sent,

  /// 已送达
  delivered,

  /// 已读
  read,

  /// 发送失败
  failed,
}

/// DeliveryStatus 是 MessageStatus 的别名，用于避免命名冲突
typedef DeliveryStatus = MessageStatus;

/// 消息状态指示器
class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final double size;
  final Color? color;

  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.size = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return _buildSending();
      case MessageStatus.sent:
        return _buildSent();
      case MessageStatus.delivered:
        return _buildDelivered();
      case MessageStatus.read:
        return _buildRead();
      case MessageStatus.failed:
        return _buildFailed();
    }
  }

  Widget _buildSending() {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSent() {
    return Icon(
      Icons.check,
      size: size,
      color: color ?? AppColors.textTertiary,
    );
  }

  Widget _buildDelivered() {
    return Icon(
      Icons.done_all,
      size: size,
      color: color ?? AppColors.textTertiary,
    );
  }

  Widget _buildRead() {
    return Icon(
      Icons.done_all,
      size: size,
      color: color ?? AppColors.primary,
    );
  }

  Widget _buildFailed() {
    return Icon(
      Icons.error_outline,
      size: size,
      color: color ?? AppColors.error,
    );
  }
}

/// 消息已读未读状态（群聊使用）
class MessageReadReceipt extends StatelessWidget {
  /// 已读人数
  final int readCount;

  /// 总人数
  final int totalCount;

  /// 是否只显示数字
  final bool compact;

  const MessageReadReceipt({
    super.key,
    required this.readCount,
    required this.totalCount,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Text(
        '$readCount/$totalCount',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textTertiary,
        ),
      );
    }

    final allRead = readCount >= totalCount;
    final l10n = S.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          allRead ? Icons.done_all : Icons.done,
          size: 14,
          color: allRead ? AppColors.primary : AppColors.textTertiary,
        ),
        const SizedBox(width: 2),
        Text(
          allRead
              ? (l10n?.commonAllRead ?? 'All read')
              : (l10n?.commonReadCount(readCount) ?? '$readCount read'),
          style: TextStyle(
            fontSize: 11,
            color: allRead ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

