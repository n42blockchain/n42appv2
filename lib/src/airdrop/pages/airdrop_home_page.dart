// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/airdrop/models/airdrop_model.dart';
import 'package:n42appv2/src/airdrop/pages/airdrop_detail_page.dart';
import 'package:n42appv2/src/airdrop/provider/airdrop_provider.dart';
import 'package:provider/provider.dart';

/// 空投追踪首页
class AirdropHomePage extends StatefulWidget {
  final String walletAddress;

  const AirdropHomePage({
    super.key,
    required this.walletAddress,
  });

  @override
  State<AirdropHomePage> createState() => _AirdropHomePageState();
}

class _AirdropHomePageState extends State<AirdropHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AirdropProvider _provider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _provider = AirdropProvider();
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
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
      appBar: AppBar(
        title: Text('Airdrop Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: _showNotificationSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Claimable'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Claimed'),
          ],
        ),
      ),
      body: Consumer<AirdropProvider>(
        builder: (context, provider, child) {
          if (provider.loadState == AirdropLoadState.loading &&
              provider.airdrops.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.loadState == AirdropLoadState.error) {
            return _buildErrorView(provider);
          }

          return Column(
            children: [
              // 统计卡片
              _buildStatsCard(provider),

              // 标签页内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAirdropList(provider.airdrops, provider),
                    _buildAirdropList(provider.claimableAirdrops, provider),
                    _buildAirdropList(provider.upcomingAirdrops, provider),
                    _buildAirdropList(provider.claimedAirdrops, provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildStatsCard(AirdropProvider provider) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(16)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
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
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pending',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(4)),
                  Text(
                    '\$${provider.stats.pendingValueUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(40),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(16),
                  vertical: ScreenUtil().setWidth(8),
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                ),
                child: Text(
                  '${provider.stats.eligibleAirdrops} Eligible',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '${provider.stats.totalAirdrops}',
                  Icons.list_alt,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Claimed',
                  '${provider.stats.claimedAirdrops}',
                  Icons.check_circle_outline,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Value Claimed',
                  '\$${provider.stats.claimedValueUsd.toStringAsFixed(0)}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
      ),
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(4)),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: ScreenUtil().setWidth(24)),
          SizedBox(height: ScreenUtil().setWidth(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(20),
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirdropList(List<AirdropModel> airdrops, AirdropProvider provider) {
    if (airdrops.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(8),
        ),
        itemCount: airdrops.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == airdrops.length) {
            // 加载更多
            provider.loadMore();
            return Center(
              child: Padding(
                padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _buildAirdropCard(airdrops[index]);
        },
      ),
    );
  }

  Widget _buildAirdropCard(AirdropModel airdrop) {
    return GestureDetector(
      onTap: () => _navigateToDetail(airdrop),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: airdrop.isExpiringSoon
              ? Border.all(color: Colors.orange, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 项目 Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                  child: Image.network(
                    airdrop.projectLogo,
                    width: ScreenUtil().setWidth(48),
                    height: ScreenUtil().setWidth(48),
                    errorBuilder: (ctx, error, stack) => Container(
                      width: ScreenUtil().setWidth(48),
                      height: ScreenUtil().setWidth(48),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(30),
                        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                      ),
                      child: Icon(Icons.token, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(12)),

                // 项目信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              airdrop.name,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(28),
                                fontWeight: FontWeight.w600,
                                color: AppThemeUtils.getColorByKey(
                                  context,
                                  AppThemeKeys.mainTextColor.name,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(airdrop.status),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        airdrop.projectName,
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
              ],
            ),

            SizedBox(height: ScreenUtil().setWidth(12)),

            // 标签和信息
            Row(
              children: [
                // 链标签
                _buildChainTag(airdrop.chainSymbol),
                SizedBox(width: ScreenUtil().setWidth(8)),

                // 类型标签
                _buildTypeTag(airdrop.type),

                Spacer(),

                // 预估价值
                if (airdrop.estimatedValueUsd != null)
                  Text(
                    '~\$${airdrop.estimatedValueUsd!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),

            // 截止时间提示
            if (airdrop.isExpiringSoon && airdrop.daysLeft != null) ...[
              SizedBox(height: ScreenUtil().setWidth(12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(10),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: ScreenUtil().setWidth(20),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(4)),
                    Text(
                      '${airdrop.daysLeft} days left to claim',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 领取按钮
            if (airdrop.isClaimable) ...[
              SizedBox(height: ScreenUtil().setWidth(12)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _claimAirdrop(airdrop),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    ),
                  ),
                  child: Text(
                    'Claim ${airdrop.userClaimableAmount ?? ""} ${airdrop.tokenSymbol ?? ""}',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AirdropStatus status) {
    Color color;
    String text;

    switch (status) {
      case AirdropStatus.upcoming:
        color = Colors.blue;
        text = 'Upcoming';
        break;
      case AirdropStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case AirdropStatus.claimed:
        color = Colors.grey;
        text = 'Claimed';
        break;
      case AirdropStatus.expired:
        color = Colors.red;
        text = 'Expired';
        break;
      case AirdropStatus.ineligible:
        color = Colors.orange;
        text = 'Not Eligible';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChainTag(String chain) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
            .withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        chain,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeTag(AirdropType type) {
    String text;
    Color color;

    switch (type) {
      case AirdropType.token:
        text = 'Token';
        color = Colors.purple;
        break;
      case AirdropType.nft:
        text = 'NFT';
        color = Colors.pink;
        break;
      case AirdropType.points:
        text = 'Points';
        color = Colors.amber;
        break;
      case AirdropType.testnet:
        text = 'Testnet';
        color = Colors.teal;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(8),
        vertical: ScreenUtil().setWidth(3),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(20),
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.card_giftcard,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            'No airdrops found',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            'Check back later for new opportunities',
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
    );
  }

  Widget _buildErrorView(AirdropProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtil().setWidth(80),
            color: Colors.red,
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Text(
            'Failed to load airdrops',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ElevatedButton(
            onPressed: provider.refresh,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(AirdropModel airdrop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirdropDetailPage(airdrop: airdrop),
      ),
    );
  }

  void _claimAirdrop(AirdropModel airdrop) {
    if (airdrop.claimUrl != null) {
      // 打开领取链接
      _navigateToDetail(airdrop);
    }
  }

  void _showFilterSheet() {
    // TODO: 显示筛选底部表单
  }

  void _showNotificationSettings() {
    // TODO: 显示通知设置
  }
}
