import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';

class RedPacketDetailPage extends StatelessWidget {
  /// 发送者名称
  final String senderName;

  /// 发送者头像
  final String? senderAvatar;

  /// 红包祝福语
  final String? greeting;

  /// 当前用户领取的金额（null 表示未领取）
  final String? claimedAmount;

  /// 代币类型
  final String token;

  /// 是否已领取
  final bool isClaimed;

  /// 领取者列表
  final List<RedPacketClaimer>? claimers;

  // ── Stats (optional — shown as summary bar above claim list)
  final int? totalCount;
  final int? claimedCount;
  final String? totalAmount;

  const RedPacketDetailPage({
    super.key,
    required this.senderName,
    this.senderAvatar,
    this.greeting,
    this.claimedAmount,
    this.token = 'CNY',
    this.isClaimed = false,
    this.claimers,
    this.totalCount,
    this.claimedCount,
    this.totalAmount,
  });

  String _currencyUnit(BuildContext context) {
    switch (token) {
      case 'CNY':
        return S.of(context)?.commonYuan ?? 'CNY';
      case 'ETH':
        return 'ETH';
      case 'BTC':
        return 'BTC';
      default:
        return token;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // ── Red gradient header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE64340), Color(0xFFD63030), Colors.black],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // AppBar row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(AppIcons.back,
                                color: Colors.white, size: 20),
                            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sender info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          backgroundImage: senderAvatar != null
                              ? NetworkImage(senderAvatar!)
                              : null,
                          child: senderAvatar == null
                              ? Text(
                                  senderName.isNotEmpty ? senderName[0] : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            S.of(context)?.commonSenderSentRedPacket(senderName) ??
                                '$senderName sent a red packet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Greeting
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        greeting ??
                            S.of(context)?.commonRedPacketDefaultGreeting ??
                            'Best wishes',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Claimed amount for current user
                    if (isClaimed && claimedAmount != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                claimedAmount!,
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 56,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  _currencyUnit(context),
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                S.of(context)?.commonSavedToBalance ??
                                    'Saved to balance, can transfer directly',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            Icon(
                              AppIcons.chevron,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Emoji reply button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                  child: Text('🐕',
                                      style: TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              S.of(context)?.commonReplyWithEmoji ??
                                  'Reply with this emoji',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          S.of(context)?.commonRedPacketExpiredOrEmpty ??
                              'Red packet expired/all claimed',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats bar ────────────────────────────────────────────────────
          if (totalCount != null)
            SliverToBoxAdapter(
              child: _StatsBar(
                claimedCount: claimedCount ?? 0,
                totalCount: totalCount!,
                totalAmount: totalAmount,
                token: token,
                currencyUnit: _currencyUnit(context),
              ),
            ),

          // ── Claim list ───────────────────────────────────────────────────
          if (claimers != null && claimers!.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ClaimerRow(
                  claimer: claimers![index],
                  currencyUnit: _currencyUnit(context),
                ),
                childCount: claimers!.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ─── Stats bar ───────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final int claimedCount;
  final int totalCount;
  final String? totalAmount;
  final String token;
  final String currencyUnit;

  const _StatsBar({
    required this.claimedCount,
    required this.totalCount,
    required this.totalAmount,
    required this.token,
    required this.currencyUnit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final statsText = l10n?.redPacketStats(claimedCount, totalCount) ??
        '$claimedCount / $totalCount claimed';
    final amountText = totalAmount != null
        ? '  •  $totalAmount $currencyUnit ${l10n?.redPacketStatsTotal ?? 'total'}'
        : '';

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$statsText$amountText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
        ],
      ),
    );
  }
}

// ─── Claim row ────────────────────────────────────────────────────────────────

class _ClaimerRow extends StatelessWidget {
  final RedPacketClaimer claimer;
  final String currencyUnit;

  const _ClaimerRow({required this.claimer, required this.currencyUnit});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              backgroundImage: claimer.avatarUrl != null
                  ? NetworkImage(claimer.avatarUrl!)
                  : null,
              child: claimer.avatarUrl == null
                  ? Text(
                      claimer.name.isNotEmpty ? claimer.name[0] : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Name + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          claimer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16, height: 1.3),
                        ),
                      ),
                      if (claimer.isBestLuck) ...[
                        const SizedBox(width: 6),
                        _BestLuckBadge(
                            label: l10n?.redPacketBestLuck ?? 'Best Luck'),
                      ],
                    ],
                  ),
                  if (claimer.claimTime != null)
                    Text(
                      claimer.claimTime!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),

            // Amount — gold if best luck
            Text(
              '${claimer.amount}$currencyUnit',
              style: TextStyle(
                color: claimer.isBestLuck
                    ? const Color(0xFFFFD700)
                    : Colors.white70,
                fontSize: 16,
                fontWeight: claimer.isBestLuck
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Best luck badge ─────────────────────────────────────────────────────────

class _BestLuckBadge extends StatelessWidget {
  final String label;

  const _BestLuckBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data models ─────────────────────────────────────────────────────────────

/// Display model for a single claim row in the detail page.
class RedPacketClaimer {
  final String name;
  final String? avatarUrl;
  final String amount;
  final String? claimTime;

  /// Whether this claimer holds the "best luck" position (highest amount).
  final bool isBestLuck;

  const RedPacketClaimer({
    required this.name,
    this.avatarUrl,
    required this.amount,
    this.claimTime,
    this.isBestLuck = false,
  });
}

/// 确认收款弹窗
class ConfirmReceiveDialog extends StatelessWidget {
  final String senderName;
  final String amount;
  final String token;
  final String? memo;
  final VoidCallback onConfirm;

  const ConfirmReceiveDialog({
    super.key,
    required this.senderName,
    required this.amount,
    required this.token,
    this.memo,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF9A825).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet,
                  size: 32, color: Color(0xFFF9A825)),
            ),
            const SizedBox(height: 16),

            Text(
              S.of(context)?.commonReceivedTransfer ?? 'Received Transfer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              S.of(context)?.commonFromSender(senderName, senderName) ??
                  'From $senderName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, height: 1.3, color: context.textTertiary),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9A825)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(' $token',
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFFF9A825))),
                ),
              ],
            ),

            if (memo != null && memo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(memo!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 14, height: 1.4, color: context.textTertiary)),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  S.of(context)?.commonConfirmReceive ?? 'Confirm Receipt',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
