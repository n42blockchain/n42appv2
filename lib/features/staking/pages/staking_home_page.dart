// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/staking/api/atom_staking_api.dart';
import 'package:n42_wallet/features/staking/api/eth_staking_api.dart';
import 'package:n42_wallet/features/staking/api/sol_staking_api.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/stake_page.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// Staking 首页
///
/// 显示支持的质押协议列表和用户的质押仓位
class StakingHomePage extends StatefulWidget {
  final Map<StakingChainType, String>? userAddresses;

  const StakingHomePage({
    super.key,
    this.userAddresses,
  });

  @override
  State<StakingHomePage> createState() => _StakingHomePageState();
}

class _StakingHomePageState extends State<StakingHomePage>
    with SingleTickerProviderStateMixin {
  // Evaluated once at compile time; avoids repeated bool.fromEnvironment calls on every build.
  static const bool _dotStakingEnabled =
      bool.fromEnvironment('FEATURE_DOT_STAKING', defaultValue: false);

  late TabController _tabController;
  late StakingProvider _provider;
  // 实时 APY 缓存：key = protocol.id
  final Map<String, double> _liveApys = {};
  bool _loadingApys = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = StakingProvider();

    // 加载用户仓位
    if (widget.userAddresses != null && widget.userAddresses!.isNotEmpty) {
      _provider.loadAllUserPositions(widget.userAddresses!);
    }

    // 并行拉取各协议实时 APY
    _loadLiveApys();
  }

  /// 并行拉取三条链的实时 APY，全部完成后刷新 UI
  Future<void> _loadLiveApys() async {
    if (_loadingApys) return;
    if (!mounted) return;
    setState(() => _loadingApys = true);

    try {
      final results = await Future.wait([
        EthStakingApi().getLidoApy(),
        SolStakingApi().getEstimatedApy(),
        AtomStakingApi().getInflationAndApy(),
      ]);

      if (!mounted) return;

      final newApys = <String, double>{};

      final ethResult = results[0];
      if (!ethResult.error && ethResult.data is double) {
        newApys[StakingProtocols.ethLido.id] = ethResult.data as double;
      }

      final solResult = results[1];
      if (!solResult.error && solResult.data is double) {
        newApys[StakingProtocols.solNative.id] = solResult.data as double;
      }

      final atomResult = results[2];
      if (!atomResult.error && atomResult.data is Map) {
        final atomData = atomResult.data as Map;
        final apy = (atomData['apy'] as num?)?.toDouble();
        if (apy != null && apy > 0) {
          newApys[StakingProtocols.atomNative.id] = apy;
        }
      }

      setState(() {
        _liveApys.addAll(newApys);
        _loadingApys = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingApys = false);
    }
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
        text: S.of(context).g_key_stake_title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab 栏
            _buildTabBar(context),

            // Tab 内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProtocolsTab(context),
                  _buildPositionsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(30),
        vertical: ScreenUtil().setWidth(16),
      ),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppThemeUtils.getColorByKey(
          context,
          AppThemeKeys.itemSubtitleTextColor.name,
        ),
        labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(26),
          fontWeight: FontWeight.normal,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(8)),
        tabs: [
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                child: Text(S.of(context).g_key_stake_protocols),
              ),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(24)),
                child: Text(S.of(context).g_key_stake_positions),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 协议列表 Tab
  Widget _buildProtocolsTab(BuildContext context) {
    // DOT staking is not yet implemented; hide until backend support is ready
    final protocols = _dotStakingEnabled
        ? StakingProtocols.all
        : StakingProtocols.all
            .where((p) => p.chainType != StakingChainType.polkadot)
            .toList();

    return ListView.builder(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      itemCount: protocols.length,
      itemBuilder: (context, index) {
        final protocol = protocols[index];
        return _buildProtocolCard(context, protocol);
      },
    );
  }

  Widget _buildProtocolCard(BuildContext context, StakingProtocol protocol) {
    return GestureDetector(
      onTap: () => _navigateToStakePage(context, protocol),
      child: Container(
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(16)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Row(
          children: [
            // 协议 Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(24)),
              child: protocol.logoUri.isNotEmpty
                  ? Image.network(
                      protocol.logoUri,
                      width: ScreenUtil().setWidth(56),
                      height: ScreenUtil().setWidth(56),
                      errorBuilder: (ctx, error, stackTrace) => _buildDefaultLogo(context, protocol),
                    )
                  : _buildDefaultLogo(context, protocol),
            ),

            SizedBox(width: ScreenUtil().setWidth(20)),

            // 协议信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: ScreenUtil().setWidth(8),
                    runSpacing: ScreenUtil().setWidth(4),
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        protocol.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainTextColor.name,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(8),
                          vertical: ScreenUtil().setWidth(4),
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeUtils.getColorByKey(
                            context,
                            AppThemeKeys.mainBlueColor.name,
                          ).withAlpha(30),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                        ),
                        child: Text(
                          protocol.chainSymbol,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(22),
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainBlueColor.name,
                            ),
                          ),
                        ),
                      ),
                      if (protocol.isLiquid)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(8),
                            vertical: ScreenUtil().setWidth(4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(30),
                            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                          ),
                          child: Text(
                            S.of(context).g_key_stake_liquid_tag,
                            style: TextStyle(
                              fontSize: ScreenUtil().setSp(22),
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(8)),
                  Text(
                    protocol.description,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: ScreenUtil().setWidth(16)),

            // APY 和解绑期
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _loadingApys && !_liveApys.containsKey(protocol.id)
                    ? SizedBox(
                        width: ScreenUtil().setWidth(20),
                        height: ScreenUtil().setWidth(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                    : Text(
                        '${(_liveApys[protocol.id] ?? protocol.apy).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(32),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                Text(
                  _liveApys.containsKey(protocol.id)
                      ? S.of(context).g_key_stake_apy
                      : (_loadingApys ? S.of(context).g_key_stake_updating : S.of(context).g_key_stake_apy),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(8)),
                Text(
                  protocol.unbondingPeriodDays > 0
                      ? S.of(context).g_key_stake_d_unbond(protocol.unbondingPeriodDays.toString())
                      : S.of(context).g_key_stake_no_lock,
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

            SizedBox(width: ScreenUtil().setWidth(8)),

            Icon(
              Icons.chevron_right,
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLogo(BuildContext context, StakingProtocol protocol) {
    return Container(
      width: ScreenUtil().setWidth(56),
      height: ScreenUtil().setWidth(56),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          protocol.chainSymbol.substring(0, 1),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    );
  }

  /// 用户仓位 Tab
  Widget _buildPositionsTab(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;
        if (provider.state == StakingState.loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.positions.isEmpty) {
          return _buildEmptyPositions(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.userAddresses != null) {
              await provider.loadAllUserPositions(widget.userAddresses!);
            }
          },
          child: ListView(
            padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
            children: [
              // 统计卡片
              _buildStatsCard(context, provider),

              SizedBox(height: ScreenUtil().setWidth(24)),

              // 活跃仓位
              if (provider.activePositions.isNotEmpty) ...[
                _buildSectionHeader(context, S.of(context).g_key_stake_active_positions),
                ...provider.activePositions.map(
                  (p) => _buildPositionCard(context, p),
                ),
              ],

              // 解绑中仓位
              if (provider.unbondingPositions.isNotEmpty) ...[
                SizedBox(height: ScreenUtil().setWidth(16)),
                _buildSectionHeader(context, S.of(context).g_key_stake_unbonding),
                ...provider.unbondingPositions.map(
                  (p) => _buildPositionCard(context, p),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyPositions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: ScreenUtil().setWidth(80),
            color: AppThemeUtils.getColorByKey(
              context,
              AppThemeKeys.itemSubtitleTextColor.name,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(20)),
          Text(
            S.of(context).g_key_stake_no_positions_yet,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.itemSubtitleTextColor.name,
              ),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(0),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeUtils.getColorByKey(
                context,
                AppThemeKeys.mainBlueColor.name,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(40),
                vertical: ScreenUtil().setWidth(16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              ),
            ),
            child: Text(
              S.of(context).g_key_stake_start_staking,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, StakingProvider provider) {
    final stats = provider.getStats();

    return Container(
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
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_stake_overview,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: Colors.white70,
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                S.of(context).g_key_stake_active_positions,
                stats.activePositions.toString(),
              ),
              _buildStatItem(
                S.of(context).g_key_stake_avg_apy,
                '${stats.averageApy.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(36),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.bold,
          color: AppThemeUtils.getColorByKey(
            context,
            AppThemeKeys.mainTextColor.name,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionCard(BuildContext context, StakingPosition position) {
    final isUnbonding = position.status == StakingPositionStatus.unbonding;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        border: isUnbonding
            ? Border.all(color: Colors.orange.withAlpha(100), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 协议名称
              Text(
                position.protocol.name,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(30),
                  fontWeight: FontWeight.bold,
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.mainTextColor.name,
                  ),
                ),
              ),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenUtil().setWidth(8),
                  vertical: ScreenUtil().setWidth(4),
                ),
                decoration: BoxDecoration(
                  color: isUnbonding
                      ? Colors.orange.withAlpha(30)
                      : Colors.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                ),
                child: Text(
                  isUnbonding ? S.of(context).g_key_stake_unbonding : S.of(context).g_key_stake_active,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(22),
                    color: isUnbonding ? Colors.orange : Colors.green,
                  ),
                ),
              ),
              Spacer(),
              Text(
                '${(_liveApys[position.protocol.id] ?? position.protocol.apy).toStringAsFixed(1)}% ${S.of(context).g_key_stake_apy}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: Colors.green,
                ),
              ),
            ],
          ),

          if (position.validator != null) ...[
            SizedBox(height: ScreenUtil().setWidth(8)),
            Text(
              '${S.of(context).g_key_stake_validator}: ${position.validator!.name}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
              ),
            ),
          ],

          SizedBox(height: ScreenUtil().setWidth(12)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).g_key_stake_staked,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                  Text(
                    _formatAmount(position.stakedAmount, position.protocol.chainSymbol),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                ],
              ),
              if (position.pendingRewards > BigInt.zero)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      S.of(context).g_key_stake_rewards,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                    ),
                    Text(
                      _formatAmount(position.pendingRewards, position.protocol.chainSymbol),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 解绑剩余时间
          if (isUnbonding && position.unbondingDaysLeft != null) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(12),
                vertical: ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_bottom,
                    size: ScreenUtil().setWidth(28),
                    color: Colors.orange,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(8)),
                  Text(
                    S.of(context).g_key_stake_days_remaining(position.unbondingDaysLeft.toString()),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(BigInt amount, String symbol) {
    // 根据不同链使用不同的精度
    int decimals;
    switch (symbol) {
      case 'ETH':
        decimals = 18;
        break;
      case 'SOL':
        decimals = 9;
        break;
      case 'ATOM':
        decimals = 6;
        break;
      case 'DOT':
        decimals = 10;
        break;
      default:
        decimals = 18;
    }

    final value = amount.toDouble() / BigInt.from(10).pow(decimals).toDouble();
    return '${value.toStringAsFixed(4)} $symbol';
  }

  void _navigateToStakePage(BuildContext context, StakingProtocol protocol) {
    // 获取对应链的用户地址
    String? userAddress;
    if (widget.userAddresses != null) {
      userAddress = widget.userAddresses![protocol.chainType];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StakePage(
          protocol: protocol,
          userAddress: userAddress,
        ),
      ),
    );
  }
}
