// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/loyalty/models/loyalty_model.dart';
import 'package:n42_wallet/features/loyalty/pages/history_page.dart';
import 'package:n42_wallet/features/loyalty/pages/rewards_page.dart';
import 'package:n42_wallet/features/loyalty/pages/tasks_page.dart';
import 'package:n42_wallet/features/loyalty/provider/loyalty_provider.dart';
import 'package:n42_wallet/features/utils/toast_utils.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// 积分系统首页
class LoyaltyHomePage extends StatefulWidget {
  final String walletAddress;

  const LoyaltyHomePage({
    super.key,
    required this.walletAddress,
  });

  @override
  State<LoyaltyHomePage> createState() => _LoyaltyHomePageState();
}

class _LoyaltyHomePageState extends State<LoyaltyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LoyaltyProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _provider = LoyaltyProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.initialize(widget.walletAddress);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_loyalty_title,
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          final provider = _provider;
          if (provider.loadState == LoyaltyLoadState.loading &&
              provider.account.totalPoints == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _buildPointsCard(context, provider),
                ),
                SliverToBoxAdapter(
                  child: _buildCheckInCard(context, provider),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickActions(context, provider),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      unselectedLabelColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                      indicatorColor: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainBlueColor.name,
                      ),
                      tabs: [
                        Tab(text: S.of(context).g_key_loyalty_tasks),
                        Tab(text: S.of(context).g_key_loyalty_rewards),
                        Tab(text: S.of(context).g_key_loyalty_history),
                      ],
                    ),
                    AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.backGroundColor.name,
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                TasksPage(tasks: provider.tasks, provider: _provider),
                RewardsPage(
                  rewards: provider.rewards,
                  availablePoints: provider.account.availablePoints,
                  provider: _provider,
                ),
                HistoryPage(history: provider.history),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 积分卡片 ──────────────────────────────────────────────────────────────

  Widget _buildPointsCard(BuildContext context, LoyaltyProvider provider) {
    final tierColor = Color(provider.getTierColorValue());

    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withValues(alpha: 180 / 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: [
          BoxShadow(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withValues(alpha: 50 / 255),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部：等级 badge + 帮助按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(12),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 50 / 255),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                  border: Border.all(color: tierColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.account.tierEmoji,
                      style: TextStyle(fontSize: ScreenUtil().setSp(24)),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(6)),
                    Text(
                      provider.account.tierName,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 积分规则按钮
              GestureDetector(
                onTap: _showRulesBottomSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(6),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: ScreenUtil().setWidth(18),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(4)),
                      Text(
                        'Rules',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 积分数
          Text(
            '${provider.account.availablePoints}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(64),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Available Points',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: Colors.white70,
            ),
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 等级进度条
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next: ${_getNextTierName(provider.account.tier)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white70,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${provider.account.tierProgress}%',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: Colors.white70,
                        ),
                      ),
                      if (provider.account.nextTierPoints > 0 &&
                          provider.account.tier != LoyaltyTier.diamond) ...[
                        Text(
                          ' · ${provider.account.nextTierPoints} pts to go',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(20),
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setWidth(8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                child: LinearProgressIndicator(
                  value: provider.account.tierProgress / 100,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(tierColor),
                  minHeight: ScreenUtil().setWidth(8),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Earned', '${provider.account.totalPoints}'),
              Container(
                width: 1,
                height: ScreenUtil().setWidth(40),
                color: Colors.white24,
              ),
              _buildStatItem('Used', '${provider.account.usedPoints}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(32),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(22),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // ── 签到卡片 ──────────────────────────────────────────────────────────────

  Widget _buildCheckInCard(BuildContext context, LoyaltyProvider provider) {
    final hasCheckedIn = provider.hasCheckedInToday;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: (hasCheckedIn ? Colors.green : Colors.amber)
                  .withValues(alpha: 30 / 255),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
            ),
            child: Icon(
              hasCheckedIn ? Icons.check_circle : Icons.calendar_today,
              color: hasCheckedIn ? Colors.green : Colors.amber,
              size: ScreenUtil().setWidth(32),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).g_key_loyalty_daily_checkin,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                Text(
                  hasCheckedIn
                      ? S.of(context).g_key_loyalty_checked_today
                      : S.of(context).g_key_loyalty_earn_points(10),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: hasCheckedIn ? null : () => _handleCheckIn(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasCheckedIn ? Colors.grey : Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
              ),
            ),
            child: Text(
              hasCheckedIn
                  ? S.of(context).g_key_loyalty_checkin_done
                  : S.of(context).g_key_loyalty_checkin_btn,
            ),
          ),
        ],
      ),
    );
  }

  // ── 快捷入口 ──────────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, LoyaltyProvider provider) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              context,
              S.of(context).g_key_loyalty_tasks,
              '${provider.availableTasks.length}',
              Icons.assignment,
              Colors.blue,
              () => _tabController.animateTo(0),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: _buildQuickAction(
              context,
              S.of(context).g_key_loyalty_rewards,
              '${provider.rewards.length}',
              Icons.card_giftcard,
              Colors.purple,
              () => _tabController.animateTo(1),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: _buildQuickAction(
              context,
              S.of(context).g_key_loyalty_invite,
              '+100',
              Icons.person_add,
              Colors.green,
              () => _showReferralSheet(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    String badge,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(48),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 30 / 255),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Icon(icon, color: color, size: ScreenUtil().setWidth(28)),
                ),
                Positioned(
                  top: -4,
                  right: -8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(6),
                      vertical: ScreenUtil().setWidth(2),
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(18),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 事件处理 ──────────────────────────────────────────────────────────────

  Future<void> _handleCheckIn(LoyaltyProvider provider) async {
    try {
      final result = await provider.checkIn();
      if (!mounted) return;

      if (result != null) {
        final pointsEarned = result['points_earned'] as int? ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).g_key_loyalty_checkin_success} +$pointsEarned ${S.of(context).g_key_loyalty_points}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ToastUtils.show(S.of(context).g_key_loyalty_checkin_failed);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.show(S.of(context).g_key_loyalty_checkin_failed);
      }
    }
  }

  // ── 邀请底部弹窗 ──────────────────────────────────────────────────────────

  void _showReferralSheet(LoyaltyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ScreenUtil().setWidth(20)),
            ),
          ),
          child: Column(
            children: [
              // 拖拽把手
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
                child: Container(
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setWidth(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
                  children: [
                    // 图标 + 标题
                    Center(
                      child: Icon(
                        Icons.person_add,
                        size: ScreenUtil().setWidth(56),
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(12)),
                    Center(
                      child: Text(
                        S.of(context).g_key_loyalty_invite_friends,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(6)),
                    Center(
                      child: Text(
                        S.of(context).g_key_loyalty_invite_bonus(100),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(26),
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.itemSubtitleTextColor.name,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // 邀请码
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                      decoration: BoxDecoration(
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.backGroundColor.name,
                        ),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.referralCode ?? S.of(context).g_key_106,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(32),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainTextColor.name,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: S.of(context).g_key_loyalty_copy,
                            onPressed: () {
                              if (provider.referralCode != null) {
                                Clipboard.setData(
                                  ClipboardData(text: provider.referralCode!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(context).g_key_119),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(12)),

                    // 分享链接按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final link = provider.referralLink;
                          if (link != null) {
                            Clipboard.setData(ClipboardData(text: link));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Link copied: $link'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: Text(S.of(context).g_key_loyalty_share),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ScreenUtil().setWidth(14),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ScreenUtil().setWidth(24)),

                    // 邀请记录列表
                    Row(
                      children: [
                        Text(
                          S.of(context).g_key_loyalty_invited_friends,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(28),
                            fontWeight: FontWeight.bold,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainTextColor.name,
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Text(
                          '(${provider.referrals.length})',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(24),
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.itemSubtitleTextColor.name,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ScreenUtil().setWidth(12)),

                    if (provider.referrals.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setWidth(24),
                        ),
                        child: Center(
                          child: Text(
                            'No referrals yet — share your code!',
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(24),
                              color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.itemSubtitleTextColor.name,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ...provider.referrals.map(
                        (r) => _buildReferralItem(context, r),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferralItem(BuildContext context, ReferralRecord r) {
    Color statusColor;
    String statusText;
    switch (r.status) {
      case ReferralStatus.confirmed:
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case ReferralStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case ReferralStatus.invalid:
        statusColor = Colors.red;
        statusText = 'Invalid';
        break;
    }

    final addr = r.referredAddress;
    final shortAddr = addr.length > 10
        ? '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}'
        : addr;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(16),
        vertical: ScreenUtil().setWidth(12),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(40),
            height: ScreenUtil().setWidth(40),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: statusColor,
              size: ScreenUtil().setWidth(22),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.referredName ?? shortAddr,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                if (r.referredName != null)
                  Text(
                    shortAddr,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(20),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(8),
                  vertical: ScreenUtil().setWidth(3),
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (r.pointsEarned > 0) ...[
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  '+${r.pointsEarned} pts',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── 积分规则底部弹窗 ──────────────────────────────────────────────────────

  void _showRulesBottomSheet() async {
    await _provider.loadRules();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final provider = _provider;
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ScreenUtil().setWidth(20)),
              ),
            ),
            child: Column(
              children: [
                // 拖拽把手
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setWidth(12)),
                  child: Container(
                    width: ScreenUtil().setWidth(40),
                    height: ScreenUtil().setWidth(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 标题
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                    vertical: ScreenUtil().setWidth(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainBlueColor.name,
                        ),
                        size: ScreenUtil().setWidth(28),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Text(
                        'Points & Tier Rules',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(24),
                    ),
                    children: [
                      // ── 等级阶梯 ─────────────────────────────────────────
                      _buildRuleSection(context, Icons.trending_up, 'Tier System'),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _buildTierTable(context),

                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // ── 获取积分方式 ──────────────────────────────────────
                      _buildRuleSection(context, Icons.star, 'How to Earn Points'),
                      SizedBox(height: ScreenUtil().setWidth(12)),

                      if (provider.rules.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else
                        ...provider.rules.map(
                          (rule) => _buildRuleCard(context, rule, provider),
                        ),

                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // ── 注意事项 ──────────────────────────────────────────
                      _buildRuleSection(context, Icons.info_outline, 'Notes'),
                      SizedBox(height: ScreenUtil().setWidth(12)),
                      _buildNoteItem(context, '• Points expire after 12 months of inactivity.'),
                      _buildNoteItem(context, '• Tier upgrades are calculated weekly.'),
                      _buildNoteItem(context, '• Fraudulent activity may result in point forfeiture.'),

                      SizedBox(height: ScreenUtil().setWidth(24)),

                      // 关闭按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(14),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(ScreenUtil().setWidth(12)),
                            ),
                          ),
                          child: const Text('Got it'),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleSection(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: ScreenUtil().setWidth(22),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        ),
        SizedBox(width: ScreenUtil().setWidth(8)),
        Text(
          title,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
          ),
        ),
      ],
    );
  }

  Widget _buildTierTable(BuildContext context) {
    const tiers = [
      (LoyaltyTier.bronze, '🥉', 'Bronze', 0, 999),
      (LoyaltyTier.silver, '🥈', 'Silver', 1000, 2499),
      (LoyaltyTier.gold, '🥇', 'Gold', 2500, 4999),
      (LoyaltyTier.platinum, '💎', 'Platinum', 5000, 9999),
      (LoyaltyTier.diamond, '👑', 'Diamond', 10000, -1),
    ];

    final currentTier = _provider.account.tier;

    return Container(
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: tiers.asMap().entries.map((entry) {
          final i = entry.key;
          final (tier, emoji, name, minPts, maxPts) = entry.value;
          final isCurrent = tier == currentTier;
          final tierColor = _tierColor(tier);

          return Container(
            decoration: BoxDecoration(
              color: isCurrent
                  ? tierColor.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: i == 0
                  ? BorderRadius.vertical(
                      top: Radius.circular(ScreenUtil().setWidth(12)),
                    )
                  : i == tiers.length - 1
                      ? BorderRadius.vertical(
                          bottom: Radius.circular(ScreenUtil().setWidth(12)),
                        )
                      : BorderRadius.zero,
              border: isCurrent
                  ? Border.all(color: tierColor.withValues(alpha: 0.4), width: 1)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(16),
                vertical: ScreenUtil().setWidth(12),
              ),
              child: Row(
                children: [
                  Text(emoji, style: TextStyle(fontSize: ScreenUtil().setSp(28))),
                  SizedBox(width: ScreenUtil().setWidth(10)),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? tierColor
                            : AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainTextColor.name,
                              ),
                      ),
                    ),
                  ),
                  Text(
                    maxPts < 0
                        ? '≥ ${_formatPts(minPts)} pts'
                        : '${_formatPts(minPts)} – ${_formatPts(maxPts)} pts',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                  if (isCurrent) ...[
                    SizedBox(width: ScreenUtil().setWidth(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil().setWidth(6),
                        vertical: ScreenUtil().setWidth(2),
                      ),
                      decoration: BoxDecoration(
                        color: tierColor,
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(6)),
                      ),
                      child: Text(
                        'You',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(18),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRuleCard(BuildContext context, PointsRule rule, LoyaltyProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(10)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.getTaskTypeIcon(rule.taskType),
            style: TextStyle(fontSize: ScreenUtil().setSp(28)),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(2)),
                Text(
                  rule.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                // 限制信息
                if (rule.dailyLimit != null || rule.totalLimit != null) ...[
                  SizedBox(height: ScreenUtil().setWidth(6)),
                  Wrap(
                    spacing: ScreenUtil().setWidth(8),
                    children: [
                      if (rule.dailyLimit != null)
                        _buildLimitChip(
                          context,
                          Icons.today,
                          'Daily limit: ${rule.dailyLimit}x',
                        ),
                      if (rule.totalLimit != null)
                        _buildLimitChip(
                          context,
                          Icons.all_inclusive,
                          'Total limit: ${rule.totalLimit}x',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(10),
              vertical: ScreenUtil().setWidth(6),
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
            ),
            child: Text(
              '+${rule.points}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenUtil().setWidth(14), color: Colors.orange),
          SizedBox(width: ScreenUtil().setWidth(4)),
          Text(
            text,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(6)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(24),
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.itemSubtitleTextColor.name,
          ),
          height: 1.5,
        ),
      ),
    );
  }

  // ── 工具方法 ──────────────────────────────────────────────────────────────

  String _getNextTierName(LoyaltyTier currentTier) {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return 'Silver';
      case LoyaltyTier.silver:
        return 'Gold';
      case LoyaltyTier.gold:
        return 'Platinum';
      case LoyaltyTier.platinum:
        return 'Diamond';
      case LoyaltyTier.diamond:
        return 'Max Level';
    }
  }

  Color _tierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:
        return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold:
        return const Color(0xFFFFD700);
      case LoyaltyTier.platinum:
        return const Color(0xFF8B8FA8);
      case LoyaltyTier.diamond:
        return const Color(0xFF6DD5FA);
    }
  }

  String _formatPts(int pts) {
    if (pts >= 1000) return '${pts ~/ 1000}K';
    return '$pts';
  }
}

/// Tab Bar 吸顶代理
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
