// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';
import 'package:n42_wallet/features/loyalty/provider/loyalty_provider.dart';

/// 奖励兑换页面
class RewardsPage extends StatelessWidget {
  final List<Reward> rewards;
  final int availablePoints;
  final LoyaltyProvider provider;

  const RewardsPage({
    super.key,
    required this.rewards,
    required this.availablePoints,
    required this.provider,
  });

  /// 主题色辅助方法
  Color _themeColor(BuildContext context, AppThemeKeys key) =>
      AppThemeUtils.getColorByKey(context, key.name);

  @override
  Widget build(BuildContext context) {
    if (rewards.isEmpty) {
      final subtitleColor = _themeColor(context, AppThemeKeys.itemSubtitleTextColor);
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard,
              size: ScreenUtil().setWidth(80),
              color: subtitleColor,
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              'No rewards available',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    // 分组奖励
    bool isAffordable(Reward r) => r.canRedeem && r.pointsCost <= availablePoints;
    final affordableRewards = rewards.where(isAffordable).toList();
    final otherRewards = rewards.where((r) => !isAffordable(r)).toList();

    return ListView(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      children: [
        // 可用积分提示
        Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
          margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: ScreenUtil().setWidth(32),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Points',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '$availablePoints',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(36),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if (affordableRewards.isNotEmpty) ...[
          _buildSectionHeader(context, 'Available to Redeem'),
          ...affordableRewards.map((reward) => _buildRewardCard(context, reward, true)),
          SizedBox(height: ScreenUtil().setWidth(16)),
        ],

        if (otherRewards.isNotEmpty) ...[
          _buildSectionHeader(context, 'More Rewards'),
          ...otherRewards.map((reward) => _buildRewardCard(context, reward, false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(4),
        bottom: ScreenUtil().setWidth(12),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.bold,
          color: _themeColor(context, AppThemeKeys.mainTextColor),
        ),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, Reward reward, bool canAfford) {
    final canRedeem = reward.canRedeem && canAfford;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      decoration: BoxDecoration(
        color: _themeColor(context, AppThemeKeys.itemBgColor),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: canRedeem
            ? Border.all(color: Colors.green.withValues(alpha: 100 / 255), width: 1)
            : null,
      ),
      child: Column(
        children: [
          // 奖励图片/图标区域
          Container(
            height: ScreenUtil().setWidth(120),
            decoration: BoxDecoration(
              color: _getRewardColor(reward.type).withValues(alpha: 30 / 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ScreenUtil().setWidth(12)),
                topRight: Radius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
            child: Center(
              child: Text(
                _getRewardEmoji(reward.type),
                style: TextStyle(fontSize: ScreenUtil().setSp(56)),
              ),
            ),
          ),

          // 奖励信息
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reward.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: _themeColor(context, AppThemeKeys.mainTextColor),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(12),
                        vertical: ScreenUtil().setWidth(6),
                      ),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? Colors.green.withValues(alpha: 30 / 255)
                            : Colors.grey.withValues(alpha: 30 / 255),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                      child: Text(
                        '${reward.pointsCost} pts',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: _themeColor(context, AppThemeKeys.itemSubtitleTextColor),
                  ),
                ),

                // 库存和限制信息
                if (reward.stock != null || reward.userLimit != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Row(
                    children: [
                      if (reward.stock != null)
                        _buildInfoChip(
                          context,
                          Icons.inventory_2_outlined,
                          '${reward.stock} left',
                          reward.stock! < 50 ? Colors.orange : Colors.grey,
                        ),
                      if (reward.stock != null && reward.userLimit != null)
                        SizedBox(width: ScreenUtil().setWidth(8)),
                      if (reward.userLimit != null)
                        _buildInfoChip(
                          context,
                          Icons.person_outline,
                          '${reward.userRedeemed}/${reward.userLimit}',
                          reward.userRedeemed >= reward.userLimit!
                              ? Colors.red
                              : Colors.grey,
                        ),
                    ],
                  ),
                ],

                // 过期时间
                if (reward.expiresAt != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  _buildExpiryRow(context, reward.expiresAt!),
                ],

                // 兑换按钮
                SizedBox(height: ScreenUtil().setWidth(12)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canRedeem
                        ? () => _handleRedeem(context, reward)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getRewardColor(reward.type),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                      ),
                    ),
                    child: Text(
                      _getButtonText(reward, canAfford),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 20 / 255),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(18), color: color),
          SizedBox(width: ScreenUtil().setWidth(4)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRewardColor(RewardType type) => switch (type) {
        RewardType.gasDiscount => Colors.blue,
        RewardType.feeDiscount => Colors.green,
        RewardType.nft => Colors.purple,
        RewardType.token => Colors.orange,
        RewardType.membership => Colors.indigo,
        RewardType.raffle => Colors.pink,
        RewardType.other => Colors.teal,
      };

  String _getRewardEmoji(RewardType type) => switch (type) {
        RewardType.gasDiscount => '⛽',
        RewardType.feeDiscount => '💰',
        RewardType.nft => '🖼️',
        RewardType.token => '🪙',
        RewardType.membership => '👑',
        RewardType.raffle => '🎟️',
        RewardType.other => '🎁',
      };

  String _getButtonText(Reward reward, bool canAfford) {
    if (!reward.canRedeem) {
      if (reward.userLimit != null && reward.userRedeemed >= reward.userLimit!) {
        return 'Limit Reached';
      }
      if (reward.stock != null && reward.stock! <= 0) {
        return 'Out of Stock';
      }
      return 'Unavailable';
    }
    if (!canAfford) {
      return 'Need ${reward.pointsCost - availablePoints} more pts';
    }
    return 'Redeem';
  }

  Widget _buildExpiryRow(BuildContext context, DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    final expiringSoon = diff.inDays <= 3;
    final expiryColor = expiringSoon
        ? Colors.orange
        : _themeColor(context, AppThemeKeys.itemSubtitleTextColor);
    final String expiryText;
    if (diff.isNegative) {
      expiryText = 'Expired';
    } else if (diff.inHours < 24) {
      expiryText = 'in ${diff.inHours}h';
    } else {
      expiryText = 'in ${diff.inDays}d';
    }
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: ScreenUtil().setWidth(20),
          color: expiryColor,
        ),
        SizedBox(width: ScreenUtil().setWidth(4)),
        Text(
          'Expires $expiryText',
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: expiryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _handleRedeem(BuildContext context, Reward reward) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to redeem:'),
            SizedBox(height: 8),
            Text(
              reward.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This will cost ${reward.pointsCost} points.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // 执行兑换
    final success = await provider.redeemReward(reward.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Successfully redeemed ${reward.name}!'
              : 'Failed to redeem reward',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
