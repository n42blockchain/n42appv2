import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/utils/a11y_l10n.dart';

/// 转账消息组件（仿微信）
class TransferMessageWidget extends StatelessWidget {
  /// 转账金额
  final String amount;

  /// 货币符号
  final String currency;

  /// 转账状态
  final TransferMessageStatus status;

  /// 转账备注
  final String? note;

  /// 是否是自己发送的
  final bool isSelf;

  /// 点击回调
  final VoidCallback? onTap;

  const TransferMessageWidget({
    super.key,
    required this.amount,
    required this.currency,
    required this.status,
    this.note,
    required this.isSelf,
    this.onTap,
  });

  String get _currencySymbol {
    switch (currency.toUpperCase()) {
      case 'CNY':
        return '¥';
      case 'ETH':
        return 'Ξ';
      case 'BTC':
        return '₿';
      case 'USDT':
        return '\$';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PaymentCardFrame(
      onTap: onTap,
      backgroundColor: _getBackgroundColor(),
      iconBackgroundColor: _getIconBackgroundColor(),
      icon: _getIcon(),
      textColor: _getTextColor(),
      title: '$_currencySymbol$amount',
      subtitle: _getStatusText(context),
      note: note,
      footerLabel: S.of(context)?.commonTransfer ?? 'Transfer',
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case TransferMessageStatus.pending:
        return const Color(0xFFF9A825);
      case TransferMessageStatus.completed:
        return const Color(0xFFF9A825);
      case TransferMessageStatus.failed:
      case TransferMessageStatus.cancelled:
      case TransferMessageStatus.expired:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _getIconBackgroundColor() {
    switch (status) {
      case TransferMessageStatus.pending:
      case TransferMessageStatus.completed:
        return Colors.white.withValues(alpha: 0.25);
      case TransferMessageStatus.failed:
      case TransferMessageStatus.cancelled:
      case TransferMessageStatus.expired:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case TransferMessageStatus.pending:
        return Icons.access_time;
      case TransferMessageStatus.completed:
        return Icons.check;
      case TransferMessageStatus.failed:
        return Icons.error_outline;
      case TransferMessageStatus.cancelled:
        return Icons.close;
      case TransferMessageStatus.expired:
        return Icons.schedule;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case TransferMessageStatus.pending:
      case TransferMessageStatus.completed:
        return Colors.white;
      case TransferMessageStatus.failed:
      case TransferMessageStatus.cancelled:
      case TransferMessageStatus.expired:
        return const Color(0xFF666666);
    }
  }

  String _getStatusText(BuildContext context) {
    switch (status) {
      case TransferMessageStatus.pending:
        return isSelf
            ? (S.of(context)?.commonWaitingToReceive ?? 'Waiting to receive')
            : (S.of(context)?.commonTapToClaim ?? 'Tap to claim');
      case TransferMessageStatus.completed:
        return isSelf
            ? (S.of(context)?.commonHasBeenReceived ?? 'Has been received')
            : (S.of(context)?.commonReceivedTransfer ?? 'Received Transfer');
      case TransferMessageStatus.failed:
        return 'Transfer failed';
      case TransferMessageStatus.cancelled:
        return 'Transfer cancelled';
      case TransferMessageStatus.expired:
        return S.of(context)?.commonExpired ?? 'Expired';
    }
  }
}

/// 转账状态
enum TransferMessageStatus { pending, completed, failed, cancelled, expired }

/// 收款请求消息组件
class PaymentRequestMessageWidget extends StatelessWidget {
  final String amount;
  final String currency;
  final PaymentRequestMessageStatus status;
  final String? note;
  final bool isSelf;
  final VoidCallback? onTap;

  const PaymentRequestMessageWidget({
    super.key,
    required this.amount,
    required this.currency,
    required this.status,
    this.note,
    required this.isSelf,
    this.onTap,
  });

  String get _currencySymbol {
    switch (currency.toUpperCase()) {
      case 'CNY':
        return '¥';
      case 'ETH':
        return 'Ξ';
      case 'BTC':
        return '₿';
      case 'USDT':
        return '\$';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PaymentCardFrame(
      onTap: onTap,
      backgroundColor: _getBackgroundColor(),
      iconBackgroundColor: _getIconBackgroundColor(),
      icon: _getIcon(),
      textColor: _getTextColor(),
      title: '$_currencySymbol$amount',
      subtitle: _getStatusText(context),
      note: note,
      footerLabel:
          S.of(context)?.transferSendPaymentRequest ?? 'Payment Request',
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case PaymentRequestMessageStatus.pending:
        return const Color(0xFF2D9CDB);
      case PaymentRequestMessageStatus.paid:
        return const Color(0xFFF9A825);
      case PaymentRequestMessageStatus.expired:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _getIconBackgroundColor() {
    switch (status) {
      case PaymentRequestMessageStatus.pending:
      case PaymentRequestMessageStatus.paid:
        return Colors.white.withValues(alpha: 0.25);
      case PaymentRequestMessageStatus.expired:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  IconData _getIcon() {
    switch (status) {
      case PaymentRequestMessageStatus.pending:
        return Icons.payments_outlined;
      case PaymentRequestMessageStatus.paid:
        return Icons.check;
      case PaymentRequestMessageStatus.expired:
        return Icons.schedule;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case PaymentRequestMessageStatus.pending:
      case PaymentRequestMessageStatus.paid:
        return Colors.white;
      case PaymentRequestMessageStatus.expired:
        return const Color(0xFF666666);
    }
  }

  String _getStatusText(BuildContext context) {
    switch (status) {
      case PaymentRequestMessageStatus.pending:
        return isSelf
            ? (S.of(context)?.commonWaitingToReceive ?? 'Waiting to receive')
            : (S.of(context)?.commonPayment ?? 'Payment');
      case PaymentRequestMessageStatus.paid:
        return isSelf
            ? (S.of(context)?.commonReceivedTransfer ?? 'Received Transfer')
            : (S.of(context)?.commonReceived ?? 'Received');
      case PaymentRequestMessageStatus.expired:
        return S.of(context)?.commonExpired ?? 'Expired';
    }
  }
}

enum PaymentRequestMessageStatus { pending, paid, expired }

class _PaymentCardFrame extends StatelessWidget {
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final Color textColor;
  final String title;
  final String subtitle;
  final String? note;
  final String footerLabel;
  final VoidCallback? onTap;

  const _PaymentCardFrame({
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.icon,
    required this.textColor,
    required this.title,
    required this.subtitle,
    required this.note,
    required this.footerLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: [
        footerLabel,
        title,
        subtitle,
        if (note?.isNotEmpty == true) note,
      ].where((e) => e != null && e.isNotEmpty).join(', '),
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: textColor.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.75),
                          ),
                        ),
                        if (note?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                footerLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// 红包消息组件（仿微信）
class RedPacketMessageWidget extends StatelessWidget {
  /// 红包备注/祝福语
  final String? note;

  /// 红包状态
  final RedPacketStatus status;

  /// 是否是自己发送的
  final bool isSelf;

  /// 点击回调
  final VoidCallback? onTap;

  /// 红包封面背景图URL
  final String? coverImageUrl;

  const RedPacketMessageWidget({
    super.key,
    this.note,
    required this.status,
    required this.isSelf,
    this.onTap,
    this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isOpened = status != RedPacketStatus.pending;

    // 已领取的红包使用浅棕色背景（类似微信）
    final bgColor = isOpened
        ? const Color(0xFFD4B896) // 已领取：浅棕色/米色
        : const Color(0xFFE64340); // 未领取：红色

    final textColor = isOpened
        ? const Color(0xFF8B7355) // 已领取：深棕色文字
        : Colors.white; // 未领取：白色文字

    return Semantics(
      button: onTap != null,
      label: [
        S.of(context)?.profileRedPacket ?? 'Red Packet',
        if (note?.isNotEmpty == true) note,
        isOpened
            ? A11yL10n.of(context).redPacketOpened
            : A11yL10n.of(context).redPacketUnopened,
      ].where((e) => e != null && e.isNotEmpty).join(', '),
      excludeSemantics: true,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 主体内容
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 红包图标
                      _buildRedPacketIcon(isOpened),
                      const SizedBox(width: 12),

                      // 祝福语和状态
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              note ??
                                  (S.of(context)?.chatRedPacketGreeting ??
                                      'Best wishes'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            if (isOpened) ...[
                              const SizedBox(height: 2),
                              Text(
                                _getStatusText(context),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 底部标签区域
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                  child: Text(
                    S.of(context)?.commonN42RedPacket ?? 'N42 Red Packet',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),

            // 封面图片覆盖层（仅未领取时显示）
            if (coverImageUrl != null && !isOpened)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: Image.network(
                    coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  /// 红包图标（圆形勾选或红包图标）
  Widget _buildRedPacketIcon(bool isOpened) {
    // 已领取：显示勾选图标（类似转账消息）
    if (isOpened) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 22, color: Color(0xFF8B7355)),
      );
    }

    // 未领取：显示红包图标
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFD4380D),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFFFD700),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '¥',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4380D),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(BuildContext context) {
    switch (status) {
      case RedPacketStatus.pending:
        return S.of(context)?.commonGetLucky ?? 'Get lucky';
      case RedPacketStatus.opened:
        return S.of(context)?.commonClaimed ?? 'Claimed';
      case RedPacketStatus.expired:
        return S.of(context)?.commonExpired ?? 'Expired';
      case RedPacketStatus.empty:
        return S.of(context)?.commonAllClaimed ?? 'All claimed';
    }
  }
}

/// 红包状态
enum RedPacketStatus { pending, opened, expired, empty }
