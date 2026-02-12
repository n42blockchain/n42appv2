// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/airdrop/pages/airdrop_home_page.dart';
import 'package:n42appv2/src/airdrop/provider/airdrop_provider.dart';
import 'package:n42appv2/src/bridge/pages/bridge_home_page.dart';
import 'package:n42appv2/src/home/widgets/feature_entry_card.dart';
import 'package:n42appv2/src/loyalty/pages/loyalty_home_page.dart';
import 'package:n42appv2/src/loyalty/provider/loyalty_provider.dart';
import 'package:n42appv2/src/staking/pages/staking_home_page.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:provider/provider.dart';

/// 赚取首页
///
/// 聚合所有收益相关功能：Staking、挖矿、跨链桥等
class EarnHomePage extends StatefulWidget {
  const EarnHomePage({super.key});

  @override
  State<EarnHomePage> createState() => _EarnHomePageState();
}

class _EarnHomePageState extends State<EarnHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部标题
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),

            // 收益概览卡片
            SliverToBoxAdapter(
              child: _buildEarningsOverview(context),
            ),

            // 主要功能入口
            SliverToBoxAdapter(
              child: _buildMainFeatures(context),
            ),

            // 快捷功能
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),

            // 热门机会
            SliverToBoxAdapter(
              child: _buildHotOpportunities(context),
            ),

            // 底部间距
            SliverToBoxAdapter(
              child: SizedBox(height: ScreenUtil().setWidth(30)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earn',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(48),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              SizedBox(height: ScreenUtil().setWidth(4)),
              Text(
                'Grow your crypto assets',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
            ],
          ),
          // 历史记录按钮
          IconButton(
            onPressed: () {
              // TODO: 导航到收益历史
            },
            icon: Icon(
              Icons.history,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              size: ScreenUtil().setWidth(40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsOverview(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
            AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(180),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earnings',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(12),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.greenAccent,
                      size: ScreenUtil().setWidth(20),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(4)),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            '\$0.00',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(48),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Row(
            children: [
              Expanded(child: _buildOverviewItem(context, 'Staking', '\$0.00', Icons.savings)),
              SizedBox(width: ScreenUtil().setWidth(16)),
              Expanded(child: _buildOverviewItem(context, 'Mining', '\$0.00', Icons.memory)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: ScreenUtil().setWidth(28)),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeatures(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            children: [
              Expanded(
                child: FeatureEntryCard(
                  title: 'Staking',
                  subtitle: 'Earn up to 15% APY',
                  icon: Icons.savings,
                  iconColor: Colors.purple,
                  tag: '15% APY',
                  tagColor: Colors.purple,
                  style: FeatureCardStyle.medium,
                  onTap: () => _navigateToStaking(context),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: FeatureEntryCard(
                  title: 'Mining',
                  subtitle: 'N42 Node Mining',
                  icon: Icons.memory,
                  iconColor: Colors.orange,
                  style: FeatureCardStyle.medium,
                  onTap: () => _navigateToMining(context),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              Expanded(
                child: FeatureEntryCard(
                  title: 'Bridge',
                  subtitle: 'Cross-chain transfer',
                  icon: Icons.swap_horiz,
                  iconColor: Colors.blue,
                  isNew: true,
                  style: FeatureCardStyle.medium,
                  onTap: () => _navigateToBridge(context),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: FeatureEntryCard(
                  title: 'Swap',
                  subtitle: 'Exchange tokens',
                  icon: Icons.currency_exchange,
                  iconColor: Colors.green,
                  style: FeatureCardStyle.medium,
                  onTap: () => _navigateToSwap(context),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            children: [
              Expanded(
                child: FeatureEntryCard(
                  title: 'Airdrop',
                  subtitle: 'Free tokens',
                  icon: Icons.card_giftcard,
                  iconColor: Colors.amber,
                  tag: 'HOT',
                  tagColor: Colors.red,
                  style: FeatureCardStyle.medium,
                  onTap: () => _navigateToAirdrop(context),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: FeatureEntryCard(
                  title: 'Points',
                  subtitle: 'Earn rewards',
                  icon: Icons.stars,
                  iconColor: Colors.deepPurple,
                  isNew: true,
                  style: FeatureCardStyle.medium,
                  onTap: () => _navigateToLoyalty(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionItem(
                  context,
                  'Claim',
                  Icons.redeem,
                  Colors.green,
                  () {},
                ),
                _buildQuickActionItem(
                  context,
                  'Compound',
                  Icons.autorenew,
                  Colors.blue,
                  () {},
                ),
                _buildQuickActionItem(
                  context,
                  'Unstake',
                  Icons.remove_circle_outline,
                  Colors.orange,
                  () {},
                ),
                _buildQuickActionItem(
                  context,
                  'History',
                  Icons.history,
                  Colors.purple,
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: ScreenUtil().setWidth(56),
            height: ScreenUtil().setWidth(56),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
            ),
            child: Icon(icon, color: color, size: ScreenUtil().setWidth(28)),
          ),
          SizedBox(height: ScreenUtil().setWidth(8)),
          Text(
            label,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(22),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotOpportunities(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hot Opportunities',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildOpportunityCard(
            context,
            'ETH Staking',
            'Lido Protocol',
            '4.0%',
            'https://tokens.1inch.io/0xae7ab96520de3a18e5e111b5eaab095312d7fe84.png',
            Colors.blue,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildOpportunityCard(
            context,
            'ATOM Staking',
            'Cosmos Hub',
            '15.0%',
            'https://raw.githubusercontent.com/cosmos/chain-registry/master/cosmoshub/images/atom.png',
            Colors.purple,
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildOpportunityCard(
            context,
            'SOL Staking',
            'Native Staking',
            '7.0%',
            'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png',
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(
    BuildContext context,
    String title,
    String protocol,
    String apy,
    String imageUrl,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => _navigateToStaking(context),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              child: Image.network(
                imageUrl,
                width: ScreenUtil().setWidth(48),
                height: ScreenUtil().setWidth(48),
                errorBuilder: (ctx, err, stack) => Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(48),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Icon(Icons.savings, color: color),
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(16)),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                  Text(
                    protocol,
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

            // APY
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(14),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                '$apy APY',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStaking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StakingHomePage()),
    );
  }

  void _navigateToMining(BuildContext context) {
    // 切换到挖矿标签页
    // TODO: 实现导航到挖矿页面
  }

  void _navigateToBridge(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BridgeHomePage()),
    );
  }

  void _navigateToSwap(BuildContext context) {
    // TODO: 导航到 Swap 页面
  }

  /// 获取第一个 EVM 钱包地址
  String _getEvmWalletAddress(BuildContext context) {
    final coinModels = context.read<WalletActionProvider>().coinModels;
    for (final cm in coinModels) {
      if (cm.address != null && cm.address!.startsWith('0x')) {
        return cm.address!;
      }
    }
    return '';
  }

  void _navigateToAirdrop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ChangeNotifierProvider(
          create: (_) => AirdropProvider(),
          child: AirdropHomePage(walletAddress: _getEvmWalletAddress(context)),
        ),
      ),
    );
  }

  void _navigateToLoyalty(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ChangeNotifierProvider(
          create: (_) => LoyaltyProvider(),
          child: LoyaltyHomePage(walletAddress: _getEvmWalletAddress(context)),
        ),
      ),
    );
  }
}
