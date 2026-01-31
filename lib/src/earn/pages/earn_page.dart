// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/bridge/pages/bridge_home_page.dart';
import 'package:n42appv2/src/staking/pages/staking_home_page.dart';
import 'package:n42appv2/src/airdrop/pages/airdrop_home_page.dart';
import 'package:n42appv2/src/loyalty/pages/loyalty_home_page.dart';
import 'package:n42appv2/src/hardware_wallet/pages/hardware_wallet_page.dart';
import 'package:n42appv2/src/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42appv2/src/wallet/pages/batch_transfer/batch_transfer_select_page.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:provider/provider.dart';

/// Earn 页面
///
/// 展示所有收益相关功能：Stake, Bridge, Airdrop, Rewards 等
class EarnPage extends StatefulWidget {
  const EarnPage({super.key});

  @override
  State<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends State<EarnPage> {
  // 模拟已质押数据
  final List<StakedItem> _stakedItems = [];

  @override
  void initState() {
    super.initState();
    _loadStakedData();
  }

  void _loadStakedData() {
    // TODO: 从 API 或本地存储加载已质押数据
    // 这里用模拟数据展示 UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部栏
            SliverToBoxAdapter(
              child: AppHomeTopBar(
                title: S.of(context).g_key_earn_title,
                onLeftImageClick: () {
                  Scaffold.of(context).openDrawer();
                },
                onLeftImageUri: "assets/img/menu.png",
              ),
            ),

            // 总收益卡片
            SliverToBoxAdapter(
              child: _buildEarningsCard(context),
            ),

            // 主要功能区
            SliverToBoxAdapter(
              child: _buildMainFeatures(context),
            ),

            // 快捷工具区
            SliverToBoxAdapter(
              child: _buildQuickTools(context),
            ),

            // 已质押/活跃产品
            if (_stakedItems.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildActiveProducts(context),
              ),

            // 推荐产品
            SliverToBoxAdapter(
              child: _buildRecommendedProducts(context),
            ),

            // 底部间距
            SliverToBoxAdapter(
              child: SizedBox(height: ScreenUtil().setWidth(120)),
            ),
          ],
        ),
      ),
    );
  }

  /// 总收益卡片
  Widget _buildEarningsCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ScreenUtil().setWidth(24)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                S.of(context).g_key_earn_total_earnings,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: Colors.white.withAlpha(200),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(12),
                  vertical: ScreenUtil().setWidth(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.greenAccent, size: ScreenUtil().setWidth(20)),
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
              fontSize: ScreenUtil().setSp(56),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Row(
            children: [
              _buildEarningsStat(S.of(context).g_key_stake_title, '\$0.00', Icons.account_balance),
              SizedBox(width: ScreenUtil().setWidth(32)),
              _buildEarningsStat(S.of(context).g_key_stake_rewards, '0 pts', Icons.stars),
              SizedBox(width: ScreenUtil().setWidth(32)),
              _buildEarningsStat(S.of(context).g_key_airdrop_title, '0', Icons.card_giftcard),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withAlpha(180), size: ScreenUtil().setWidth(28)),
          SizedBox(width: ScreenUtil().setWidth(8)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(20),
                    color: Colors.white.withAlpha(150),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 主要功能区
  Widget _buildMainFeatures(BuildContext context) {
    final waProvider = Provider.of<WalletActionProvider>(context, listen: false);
    final address = waProvider.coinList.isNotEmpty
        ? waProvider.coinList.first.address?.toString() ?? ''
        : '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_earn_more,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // 大功能卡片 - 横向滚动
          SizedBox(
            height: ScreenUtil().setWidth(200),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFeatureCard(
                  context,
                  title: S.of(context).g_key_stake_stake,
                  subtitle: S.of(context).g_key_earn_up_to_apy('15'),
                  icon: Icons.account_balance_rounded,
                  gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                  badge: 'HOT',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StakingHomePage()),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                _buildFeatureCard(
                  context,
                  title: S.of(context).g_key_bridge_title,
                  subtitle: S.of(context).g_key_earn_cross_chain,
                  icon: Icons.swap_horiz_rounded,
                  gradientColors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BridgeHomePage()),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                _buildFeatureCard(
                  context,
                  title: S.of(context).g_key_airdrop_claim,
                  subtitle: S.of(context).g_key_earn_claim_free,
                  icon: Icons.card_giftcard_rounded,
                  gradientColors: const [Color(0xFFf093fb), Color(0xFFf5576c)],
                  badge: 'NEW',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AirdropHomePage(walletAddress: address)),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                _buildFeatureCard(
                  context,
                  title: S.of(context).g_key_loyalty_rewards,
                  subtitle: S.of(context).g_key_earn_daily_bonus,
                  icon: Icons.stars_rounded,
                  gradientColors: const [Color(0xFFf7971e), Color(0xFFffd200)],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoyaltyHomePage(walletAddress: address)),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 大功能卡片
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    String? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ScreenUtil().setWidth(220),
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(48),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Icon(icon, color: Colors.white, size: ScreenUtil().setWidth(28)),
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(10),
                      vertical: ScreenUtil().setWidth(4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(32),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScreenUtil().setWidth(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: Colors.white.withAlpha(200),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 快捷工具区
  Widget _buildQuickTools(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_earn_quick_tools,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Row(
              children: [
                _buildToolItem(
                  context,
                  icon: Icons.security_rounded,
                  label: 'Ledger',
                  color: const Color(0xFF607D8B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HardwareWalletPage()),
                  ),
                ),
                _buildToolItem(
                  context,
                  icon: Icons.local_gas_station_rounded,
                  label: 'Gas',
                  color: const Color(0xFFE91E63),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GasTrackerPage()),
                  ),
                ),
                _buildToolItem(
                  context,
                  icon: Icons.send_rounded,
                  label: 'Batch',
                  color: const Color(0xFF00BCD4),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BatchTransferSelectPage()),
                  ),
                ),
                _buildToolItem(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: 'Burn',
                  color: const Color(0xFFFF5722),
                  onTap: () => _showBurnNftTip(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenUtil().setWidth(56),
              height: ScreenUtil().setWidth(56),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
              ),
              child: Icon(icon, color: color, size: ScreenUtil().setWidth(28)),
            ),
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 已质押/活跃产品
  Widget _buildActiveProducts(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_earn_active_products,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  S.of(context).g_key_earn_view_all,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          ..._stakedItems.map((item) => _buildActiveProductItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildActiveProductItem(BuildContext context, StakedItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name).withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: item.color.withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Icon(item.icon, color: item.color, size: ScreenUtil().setWidth(28)),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              Text(
                item.apy,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(22),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 推荐产品
  Widget _buildRecommendedProducts(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_earn_recommended,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildRecommendedItem(
            context,
            name: 'ETH ${S.of(context).g_key_stake_title}',
            description: S.of(context).g_key_earn_stake_eth_lido,
            apy: '~4% ${S.of(context).g_key_stake_apy}',
            icon: Icons.account_balance,
            color: const Color(0xFF627EEA),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StakingHomePage()),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildRecommendedItem(
            context,
            name: 'SOL ${S.of(context).g_key_stake_title}',
            description: S.of(context).g_key_earn_native_sol,
            apy: '~7% ${S.of(context).g_key_stake_apy}',
            icon: Icons.account_balance,
            color: const Color(0xFF9945FF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StakingHomePage()),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildRecommendedItem(
            context,
            name: S.of(context).g_key_loyalty_daily_checkin,
            description: S.of(context).g_key_earn_points_daily,
            apy: S.of(context).g_key_earn_pts_day('10'),
            icon: Icons.stars,
            color: const Color(0xFFFFC107),
            onTap: () {
              final waProvider = Provider.of<WalletActionProvider>(context, listen: false);
              final address = waProvider.coinList.isNotEmpty
                  ? waProvider.coinList.first.address?.toString() ?? ''
                  : '';
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoyaltyHomePage(walletAddress: address)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedItem(
    BuildContext context, {
    required String name,
    required String description,
    required String apy,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(52),
              height: ScreenUtil().setWidth(52),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Icon(icon, color: color, size: ScreenUtil().setWidth(28)),
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(6),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Text(
                apy,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(8)),
            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  void _showBurnNftTip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.of(context).g_key_burn_nft_title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          '${S.of(context).g_key_burn_nft_tip}\n\n'
          '${S.of(context).g_key_burn_nft_steps}\n'
          '${S.of(context).g_key_burn_nft_step1}\n'
          '${S.of(context).g_key_burn_nft_step2}\n'
          '${S.of(context).g_key_burn_nft_step3}\n'
          '${S.of(context).g_key_burn_nft_step4}',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).g_key_burn_got_it,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 已质押项目数据模型
class StakedItem {
  final String name;
  final String description;
  final String amount;
  final String apy;
  final IconData icon;
  final Color color;

  StakedItem({
    required this.name,
    required this.description,
    required this.amount,
    required this.apy,
    required this.icon,
    required this.color,
  });
}
