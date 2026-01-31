// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/loyalty/models/loyalty_model.dart';
import 'package:n42appv2/src/loyalty/pages/rewards_page.dart';
import 'package:n42appv2/src/loyalty/pages/tasks_page.dart';
import 'package:n42appv2/src/loyalty/provider/loyalty_provider.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyProvider>().initialize(widget.walletAddress);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoyaltyProvider>(
        builder: (context, provider, child) {
          if (provider.loadState == LoyaltyLoadState.loading &&
              provider.account.totalPoints == 0) {
            return Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 顶部积分卡片
                SliverToBoxAdapter(
                  child: _buildPointsCard(context, provider),
                ),

                // 每日签到
                SliverToBoxAdapter(
                  child: _buildCheckInCard(context, provider),
                ),

                // 快捷入口
                SliverToBoxAdapter(
                  child: _buildQuickActions(context, provider),
                ),

                // Tab Bar
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
                        Tab(text: 'Tasks'),
                        Tab(text: 'Rewards'),
                        Tab(text: 'History'),
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
                _buildTasksTab(provider),
                _buildRewardsTab(provider),
                _buildHistoryTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

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
                .withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
        boxShadow: [
          BoxShadow(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
                .withAlpha(50),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部行：等级和设置
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(12),
                      vertical: ScreenUtil().setWidth(6),
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withAlpha(50),
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
                ],
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.white70),
                onPressed: _showRulesDialog,
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 积分数量
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
                  Text(
                    '${provider.account.tierProgress}%',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white70,
                    ),
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
              color: (hasCheckedIn ? Colors.green : Colors.amber).withAlpha(30),
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
                  'Daily Check-in',
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
                  hasCheckedIn ? 'Checked in today!' : 'Earn 10 points',
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
            child: Text(hasCheckedIn ? 'Done' : 'Check In'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, LoyaltyProvider provider) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              context,
              'Tasks',
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
              'Rewards',
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
              'Invite',
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
                    color: color.withAlpha(30),
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

  Widget _buildTasksTab(LoyaltyProvider provider) {
    return TasksPage(tasks: provider.tasks);
  }

  Widget _buildRewardsTab(LoyaltyProvider provider) {
    return RewardsPage(
      rewards: provider.rewards,
      availablePoints: provider.account.availablePoints,
    );
  }

  Widget _buildHistoryTab(LoyaltyProvider provider) {
    if (provider.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history,
              size: ScreenUtil().setWidth(80),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              'No history yet',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      itemCount: provider.history.length,
      itemBuilder: (context, index) {
        final item = provider.history[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(PointsHistory item) {
    final isEarn = item.action == PointsAction.earn;
    final color = isEarn ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(44),
            height: ScreenUtil().setWidth(44),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarn ? Icons.add : Icons.remove,
              color: color,
              size: ScreenUtil().setWidth(24),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
                Text(
                  _formatDate(item.createdAt),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? '+' : ''}${item.points}',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckIn(LoyaltyProvider provider) async {
    final result = await provider.checkIn();
    if (!mounted) return;

    if (result != null) {
      final pointsEarned = result['points_earned'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check-in successful! +$pointsEarned points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showReferralSheet(LoyaltyProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(20)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(40),
              height: ScreenUtil().setWidth(4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
            Icon(
              Icons.person_add,
              size: ScreenUtil().setWidth(60),
              color: Colors.green,
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              'Invite Friends',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.mainTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              'Earn 100 points for each friend who joins!',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(24)),
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
                      provider.referralCode ?? 'Loading...',
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
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      if (provider.referralCode != null) {
                        Clipboard.setData(ClipboardData(text: provider.referralCode!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Code copied!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (provider.referralLink != null) {
                    Clipboard.setData(ClipboardData(text: provider.referralLink!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link copied!')),
                    );
                  }
                },
                icon: Icon(Icons.share),
                label: Text('Share Invite Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(16)),
            Text(
              '${provider.referrals.length} friends invited',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
            SizedBox(height: ScreenUtil().setWidth(20)),
          ],
        ),
      ),
    );
  }

  void _showRulesDialog() async {
    final provider = context.read<LoyaltyProvider>();
    await provider.loadRules();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Points Rules'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...provider.rules.map((rule) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.getTaskTypeIcon(rule.taskType),
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rule.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                rule.description,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${rule.points}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (provider.rules.isEmpty)
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Tab Bar 代理
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
