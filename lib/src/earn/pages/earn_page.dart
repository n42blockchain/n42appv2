// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/bridge/pages/bridge_home_page.dart';
import 'package:n42appv2/src/earn/provider/earn_provider.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';
import 'package:n42appv2/src/staking/pages/staking_home_page.dart';
import 'package:n42appv2/src/airdrop/pages/airdrop_home_page.dart';
import 'package:n42appv2/src/loyalty/pages/loyalty_home_page.dart';
import 'package:n42appv2/src/hardware_wallet/pages/hardware_wallet_page.dart';
import 'package:n42appv2/src/miningV2/pages/mining_today_v2.dart';
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42appv2/src/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42appv2/src/wallet/pages/batch_transfer/batch_transfer_select_page.dart';
import 'package:n42appv2/src/widgets/app_home_top_bar.dart';
import 'package:n42appv2/src/widgets/sheet_bottom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, Consumer;
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

/// Earn 页面
///
/// 展示所有收益相关功能：Stake, Bridge, Mining, Swap, Airdrop, Rewards 等。
/// 通过 [earnProvider] 获取三链实时 APY 和用户活跃质押仓位。
class EarnPage extends ConsumerStatefulWidget {
  const EarnPage({super.key});

  @override
  ConsumerState<EarnPage> createState() => _EarnPageState();
}

class _EarnPageState extends ConsumerState<EarnPage> {
  @override
  void initState() {
    super.initState();
    // 初始化时加载多链质押仓位
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStakedData());
  }

  void _loadStakedData() {
    final wap = ref.read(wapBridgeProvider);
    // 从 coinList 中找各链地址
    String? ethAddr;
    String? solAddr;
    String? atomAddr;
    for (final cm in wap.coinList) {
      final coinType = cm.coin['coinType'] as String? ?? '';
      final addr = cm.address?.toString() ?? '';
      if (addr.isEmpty) continue;
      if (coinType == 'ETH' && ethAddr == null) ethAddr = addr;
      if (coinType == 'SOL' && solAddr == null) solAddr = addr;
      if (coinType == 'ATOM' && atomAddr == null) atomAddr = addr;
    }
    ref.read(earnProvider.notifier).loadPositions(
          ethAddress: ethAddr,
          solAddress: solAddr,
          atomAddress: atomAddr,
        );
  }

  String get _walletAddress {
    final wap = ref.read(wapBridgeProvider);
    return wap.coinList.isNotEmpty
        ? wap.coinList.first.address?.toString() ?? ''
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final earnState = ref.watch(earnProvider);
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
              child: _buildEarningsCard(context, earnState),
            ),

            // 主要功能区
            SliverToBoxAdapter(
              child: _buildMainFeatures(context, earnState),
            ),

            // 快捷工具区
            SliverToBoxAdapter(
              child: _buildQuickTools(context),
            ),

            // 已质押/活跃产品（始终显示，空时展示引导入口）
            SliverToBoxAdapter(
              child: _buildActiveProducts(context, earnState),
            ),

            // 推荐产品（实时 APY）
            SliverToBoxAdapter(
              child: _buildRecommendedProducts(context, earnState),
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

  // ──────────────────────────────────────────────────────────────────────────
  //  总收益卡片
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildEarningsCard(BuildContext context, EarnState earnState) {
    final maxApy = earnState.maxApy;
    final apyLabel = earnState.apyLoading
        ? S.of(context).g_key_earn_loading_apy
        : 'up to ${maxApy.toStringAsFixed(1)}% APY';

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
                child: earnState.apyLoading
                    ? SizedBox(
                        width: ScreenUtil().setWidth(60),
                        height: ScreenUtil().setWidth(22),
                        child: const LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: Colors.white54,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up,
                              color: Colors.greenAccent,
                              size: ScreenUtil().setWidth(20)),
                          SizedBox(width: ScreenUtil().setWidth(4)),
                          Text(
                            apyLabel,
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
              _buildEarningsStat(
                  S.of(context).g_key_stake_title, '\$0.00', Icons.account_balance),
              SizedBox(width: ScreenUtil().setWidth(32)),
              _buildEarningsStat(
                  S.of(context).g_key_stake_rewards, '0 pts', Icons.stars),
              SizedBox(width: ScreenUtil().setWidth(32)),
              _buildEarningsStat(
                  S.of(context).g_key_airdrop_title, '0', Icons.card_giftcard),
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

  // ──────────────────────────────────────────────────────────────────────────
  //  主要功能区（含 Mining + Swap）
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildMainFeatures(BuildContext context, EarnState earnState) {
    final address = _walletAddress;
    final maxApyStr = earnState.apyLoading
        ? '...'
        : earnState.maxApy.toStringAsFixed(1);

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
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          // 大功能卡片 — 横向滚动
          SizedBox(
            height: ScreenUtil().setWidth(230),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFeatureCard(
                  context,
                  title: S.of(context).g_key_stake_stake,
                  subtitle: S.of(context).g_key_earn_up_to_apy(maxApyStr),
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
                  title: S.of(context).g_key_earn_mining,
                  subtitle: S.of(context).g_key_earn_node_mining_desc,
                  icon: Icons.developer_board_rounded,
                  gradientColors: const [Color(0xFFf7971e), Color(0xFFffd200)],
                  badge: 'N42',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MiningTodayV2()),
                  ),
                ),
                SizedBox(width: ScreenUtil().setWidth(16)),
                _buildFeatureCard(
                  context,
                  title: S.of(context).g_key_earn_swap,
                  subtitle: S.of(context).g_key_earn_buy_n_desc,
                  icon: Icons.currency_exchange_rounded,
                  gradientColors: const [Color(0xFF4776E6), Color(0xFF8E54E9)],
                  onTap: () => _navigateToSwap(context),
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
                    MaterialPageRoute(
                        builder: (_) => AirdropHomePage(walletAddress: address)),
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
                    MaterialPageRoute(
                        builder: (_) => LoyaltyHomePage(walletAddress: address)),
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

  /// Swap 导航：底部弹出选择"买 N"
  void _navigateToSwap(BuildContext context) {
    final s = S.of(context);
    sheetBottom(
      context,
      s.g_key_earn_select_swap,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _swapOptionTile(
            context,
            icon: Icons.currency_exchange,
            title: s.g_key_earn_buy_n,
            subtitle: s.g_key_earn_buy_n_desc,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SwapAstHome()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _swapOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: ScreenUtil().setWidth(48),
        height: ScreenUtil().setWidth(48),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              .withAlpha(25),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Icon(
          icon,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainBlueColor.name),
          size: ScreenUtil().setWidth(26),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainTextColor.name),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(22),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemSubtitleTextColor.name),
      ),
      onTap: onTap,
    );
  }

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
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Icon(icon,
                      color: Colors.white, size: ScreenUtil().setWidth(28)),
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(10),
                      vertical: ScreenUtil().setWidth(4),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(10)),
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

  // ──────────────────────────────────────────────────────────────────────────
  //  快捷工具区（4 个工具：Ledger / Gas / Batch / Burn）
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildQuickTools(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_earn_quick_tools,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
            ),
            child: Row(
              children: [
                _buildToolItem(
                  context,
                  icon: Icons.security_rounded,
                  label: s.g_key_earn_ledger,
                  color: const Color(0xFF607D8B),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HardwareWalletPage()),
                  ),
                ),
                _buildToolItem(
                  context,
                  icon: Icons.local_gas_station_rounded,
                  label: s.g_key_earn_gas,
                  color: const Color(0xFFE91E63),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GasTrackerPage()),
                  ),
                ),
                _buildToolItem(
                  context,
                  icon: Icons.send_rounded,
                  label: s.g_key_earn_batch,
                  color: const Color(0xFF00BCD4),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BatchTransferSelectPage()),
                  ),
                ),
                _buildToolItem(
                  context,
                  icon: Icons.local_fire_department_rounded,
                  label: s.g_key_earn_burn,
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
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
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

  // ──────────────────────────────────────────────────────────────────────────
  //  已质押/活跃产品（始终展示，空时显示引导）
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildActiveProducts(BuildContext context, EarnState earnState) {
    final positions = earnState.activePositions;
    final loading = earnState.positionsLoading;

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
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StakingHomePage()),
                ),
                child: Text(
                  S.of(context).g_key_earn_view_all,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainBlueColor.name),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          if (loading)
            _buildPositionsLoading()
          else if (positions.isEmpty)
            _buildNoPositions(context)
          else
            ...positions.map((p) => _buildActivePositionItem(context, p)),
        ],
      ),
    );
  }

  Widget _buildPositionsLoading() {
    return Container(
      height: ScreenUtil().setWidth(80),
      alignment: Alignment.center,
      child: SizedBox(
        width: ScreenUtil().setWidth(24),
        height: ScreenUtil().setWidth(24),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildNoPositions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: ScreenUtil().setWidth(48),
            color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.itemSubtitleTextColor.name)
                .withAlpha(100),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Text(
            S.of(context).g_key_earn_no_positions,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StakingHomePage()),
            ),
            child: Text(
              S.of(context).g_key_earn_go_staking,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePositionItem(
      BuildContext context, StakingPosition position) {
    final protocol = position.protocol;
    final apyStr = '${protocol.apy.toStringAsFixed(1)}% APY';

    // 链对应颜色
    final color = _chainColor(protocol.chainType);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        border: Border.all(
          color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name)
              .withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(48),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
            ),
            child: Center(
              child: Text(
                protocol.chainSymbol,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(20),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  protocol.name,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.mainTextColor.name),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  protocol.chainSymbol,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                        context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatBigInt(position.stakedAmount, protocol.chainSymbol),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(28),
                  fontWeight: FontWeight.w600,
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.mainTextColor.name),
                ),
              ),
              Text(
                apyStr,
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

  Color _chainColor(StakingChainType chainType) {
    switch (chainType) {
      case StakingChainType.ethereum:
        return const Color(0xFF627EEA);
      case StakingChainType.solana:
        return const Color(0xFF9945FF);
      case StakingChainType.cosmos:
        return const Color(0xFF2E3148);
      case StakingChainType.polkadot:
        return const Color(0xFFE6007A);
    }
  }

  /// 将最小单位 BigInt 格式化为可读字符串（精度 6 位）
  String _formatBigInt(BigInt raw, String symbol) {
    if (raw == BigInt.zero) return '0 $symbol';
    // 以 1e18 精度（ETH / SOL / ATOM 的标准）
    final whole = raw ~/ BigInt.from(10).pow(18);
    final frac = (raw % BigInt.from(10).pow(18)) ~/
        BigInt.from(10).pow(12); // 6 位小数
    final fracStr = frac.toString().padLeft(6, '0').replaceAll(RegExp(r'0+$'), '');
    final display = fracStr.isEmpty ? whole.toString() : '$whole.$fracStr';
    return '$display $symbol';
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  推荐产品（使用实时 APY）
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildRecommendedProducts(BuildContext context, EarnState earnState) {
    final s = S.of(context);
    final ethApyStr = earnState.apyLoading
        ? '...'
        : '~${earnState.ethApy.toStringAsFixed(1)}% ${s.g_key_stake_apy}';
    final solApyStr = earnState.apyLoading
        ? '...'
        : '~${earnState.solApy.toStringAsFixed(1)}% ${s.g_key_stake_apy}';

    return Padding(
      padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.g_key_earn_recommended,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(32),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          _buildRecommendedItem(
            context,
            name: 'ETH ${s.g_key_stake_title}',
            description: s.g_key_earn_stake_eth_lido,
            apy: ethApyStr,
            color: const Color(0xFF627EEA),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StakingHomePage()),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildRecommendedItem(
            context,
            name: 'SOL ${s.g_key_stake_title}',
            description: s.g_key_earn_native_sol,
            apy: solApyStr,
            color: const Color(0xFF9945FF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StakingHomePage()),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          _buildRecommendedItem(
            context,
            name: s.g_key_loyalty_daily_checkin,
            description: s.g_key_earn_points_daily,
            apy: s.g_key_earn_pts_day('10'),
            color: const Color(0xFFFFC107),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      LoyaltyHomePage(walletAddress: _walletAddress)),
            ),
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
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            Container(
              width: ScreenUtil().setWidth(52),
              height: ScreenUtil().setWidth(52),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(14)),
              ),
              child: Icon(Icons.account_balance,
                  color: color, size: ScreenUtil().setWidth(28)),
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
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(context,
                          AppThemeKeys.itemSubtitleTextColor.name),
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
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(8)),
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
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  Burn NFT 提示对话框
  // ──────────────────────────────────────────────────────────────────────────

  void _showBurnNftTip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.of(context).g_key_burn_nft_title,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87),
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
              color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).g_key_burn_got_it,
              style: TextStyle(
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
