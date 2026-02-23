// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/validator_list_page.dart';
import 'package:n42_wallet/features/staking/provider/staking_provider.dart';
import 'package:n42_wallet/features/wallet/pages/dex_swap/dex_swap_home.dart';
import 'package:n42_wallet/features/widgets/app_bar_widget.dart';

/// Stake 页面
///
/// 用于质押/解除质押操作
class StakePage extends StatefulWidget {
  final StakingProtocol protocol;
  final String? userAddress;

  const StakePage({
    super.key,
    required this.protocol,
    this.userAddress,
  });

  @override
  State<StakePage> createState() => _StakePageState();
}

class _StakePageState extends State<StakePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StakingProvider _provider;
  final TextEditingController _amountController = TextEditingController();

  // 解质押专用控制器（与 stake 用的 _amountController 分开）
  final TextEditingController _unstakeAmountController = TextEditingController();

  bool _isLoading = false;
  BigInt _balance = BigInt.zero;
  String _errorMessage = '';

  // 解质押相关状态
  List<StakingPosition> _activePositions = [];
  StakingPosition? _selectedPosition;
  bool _loadingPositions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = StakingProvider();
    _provider.selectProtocol(widget.protocol);

    // 加载验证者列表并同步更新实时 APY（所有链都执行）
    _provider.loadValidators();

    _loadBalance();

    // 非流动性质押：加载用户仓位，以便解质押选择
    if (!widget.protocol.isLiquid && widget.userAddress != null) {
      _loadActivePositions();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _unstakeAmountController.dispose();
    _provider.dispose();
    super.dispose();
  }

  bool _needsValidator() {
    return widget.protocol.chainType != StakingChainType.ethereum;
  }

  /// 加载用户当前活跃质押仓位（用于解质押页面显示）
  Future<void> _loadActivePositions() async {
    if (widget.userAddress == null || widget.userAddress!.isEmpty) return;
    if (!mounted) return;
    setState(() => _loadingPositions = true);

    await _provider.loadUserPositions(widget.userAddress!, widget.protocol.chainType);

    if (!mounted) return;
    setState(() {
      _activePositions = _provider.positions
          .where((p) => p.status == StakingPositionStatus.active)
          .toList();
      _loadingPositions = false;
    });
  }

  Future<void> _loadBalance() async {
    final symbol = widget.protocol.chainSymbol;
    try {
      final coinModels = globalWapAdapter.coinModels;
      final cm = coinModels.where((c) => c.coin['coinType'] == symbol).firstOrNull;
      if (cm != null) {
        final rawBalance = cm.isTest
            ? (cm.coin['balance_test'] ?? '0')
            : (cm.coin['balance'] ?? '0');
        setState(() {
          _balance = BigInt.tryParse(rawBalance) ?? BigInt.zero;
        });
        return;
      }
    } catch (_) {}
    // Fallback: zero balance if wallet data unavailable
    setState(() {
      _balance = BigInt.zero;
    });
  }

  int _getDecimals() {
    switch (widget.protocol.chainType) {
      case StakingChainType.ethereum:
        return 18;
      case StakingChainType.solana:
        return 9;
      case StakingChainType.cosmos:
        return 6;
      case StakingChainType.polkadot:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: widget.protocol.name,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 协议信息卡片
            _buildProtocolInfoCard(context),

            // Tab 栏
            _buildTabBar(context),

            // Tab 内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStakeTab(context),
                  _buildUnstakeTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolInfoCard(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;
        return Container(
          margin: EdgeInsets.all(ScreenUtil().setWidth(30)),
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
          child: Row(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(28)),
                child: widget.protocol.logoUri.isNotEmpty
                    ? Image.network(
                        widget.protocol.logoUri,
                        width: ScreenUtil().setWidth(56),
                        height: ScreenUtil().setWidth(56),
                        errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
                      )
                    : _buildDefaultLogo(),
              ),
              SizedBox(width: ScreenUtil().setWidth(20)),

              // 协议信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.protocol.name,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.protocol.isLiquid) ...[
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(8),
                              vertical: ScreenUtil().setWidth(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(6)),
                            ),
                            child: Text(
                              S.of(context).g_key_stake_liquid_tag,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(20),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    Text(
                      widget.protocol.isLiquid
                          ? S.of(context).g_key_stake_liquid_staking_label
                          : S.of(context).g_key_stake_d_unbond(widget.protocol.unbondingPeriodDays.toString()),
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(24),
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // APY
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${provider.currentApy.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(36),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'APY',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: ScreenUtil().setWidth(56),
      height: ScreenUtil().setWidth(56),
      decoration: BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.protocol.chainSymbol.substring(0, 1),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(30)),
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
          fontSize: ScreenUtil().setSp(28),
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: S.of(context).g_key_stake_stake),
          Tab(text: S.of(context).g_key_stake_unstake),
        ],
      ),
    );
  }

  Widget _buildStakeTab(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;
        return SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 验证者选择（如果需要）
              if (_needsValidator()) ...[
                _buildSectionTitle(context, S.of(context).g_key_stake_select_validator),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildValidatorSelector(context, provider),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // 金额输入
              _buildSectionTitle(context, S.of(context).g_key_stake_amount),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildAmountInput(context),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildQuickAmountButtons(context),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // 质押预估
              _buildStakeEstimate(context, provider),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // 错误提示
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: ScreenUtil().setWidth(32)),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: ScreenUtil().setSp(24)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // Stake 按钮
              _buildStakeButton(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnstakeTab(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        final provider = _provider;

        // 流动性质押（ETH Lido）：引导用户去 DEX Swap
        if (widget.protocol.isLiquid) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: ScreenUtil().setWidth(80),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainBlueColor.name,
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(20)),
                  Text(
                    S.of(context).g_key_stake_liquid_staking_label,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.mainTextColor.name,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(12)),
                  // 液态代币符号 + 说明
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                      ),
                      children: [
                        TextSpan(
                          text: widget.protocol.liquidTokenSymbol,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppThemeUtils.getColorByKey(
                              context,
                              AppThemeKeys.mainBlueColor.name,
                            ),
                          ),
                        ),
                        TextSpan(text: ' — '),
                        TextSpan(text: S.of(context).g_key_stake_liquid_unstake_desc),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(30)),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DexSwapHome()),
                      );
                    },
                    icon: Icon(Icons.swap_horizontal_circle_outlined, color: Colors.white),
                    label: Text(
                      S.of(context).g_key_stake_go_to_swap,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: Colors.white,
                      ),
                    ),
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
                  ),
                ],
              ),
            ),
          );
        }

        // 非流动性质押（SOL / ATOM）：显示用户仓位列表 + 解质押操作
        return SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 解绑警告
              Container(
                padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: ScreenUtil().setWidth(36),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(12)),
                    Expanded(
                      child: Text(
                        S.of(context).g_key_stake_unbonding_warning(
                          widget.protocol.unbondingPeriodDays.toString(),
                        ),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ScreenUtil().setWidth(24)),

              // 用户活跃质押仓位列表
              _buildSectionTitle(context, S.of(context).g_key_stake_select_position),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildPositionSelector(context),

              // 只有选中仓位后才显示金额输入（对于支持部分解绑的协议）
              if (_selectedPosition != null && widget.protocol.chainType == StakingChainType.cosmos) ...[
                SizedBox(height: ScreenUtil().setWidth(24)),
                _buildSectionTitle(context, S.of(context).g_key_stake_amount_unstake),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildUnstakeAmountInput(context),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildQuickUnstakeButtons(context),
              ],

              SizedBox(height: ScreenUtil().setWidth(24)),

              // 错误提示
              if (_errorMessage.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(12)),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: ScreenUtil().setWidth(32)),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: ScreenUtil().setSp(24)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // Unstake 按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isLoading || _selectedPosition == null)
                      ? null
                      : () => _performUnstake(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPosition != null ? Colors.orange : null,
                    padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: ScreenUtil().setWidth(32),
                          height: ScreenUtil().setWidth(32),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _selectedPosition == null
                              ? S.of(context).g_key_stake_select_position
                              : S.of(context).g_key_stake_unstake,
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.bold,
                            color: _selectedPosition != null
                                ? Colors.white
                                : AppThemeUtils.getColorByKey(
                                    context,
                                    AppThemeKeys.itemSubtitleTextColor.name,
                                  ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 用户活跃仓位选择器（解质押用）
  Widget _buildPositionSelector(BuildContext context) {
    if (_loadingPositions) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.userAddress == null || widget.userAddress!.isEmpty) {
      return _buildNoWalletHint(context);
    }

    if (_activePositions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Center(
          child: Text(
            S.of(context).g_key_stake_no_active_positions,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
      );
    }

    return Column(
      children: _activePositions.map((pos) {
        final isSelected = _selectedPosition?.id == pos.id;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPosition = isSelected ? null : pos;
              // SOL 解质押是全额解绑；ATOM 可部分解绑，预填最大值
              if (!isSelected) {
                if (widget.protocol.chainType == StakingChainType.cosmos) {
                  _unstakeAmountController.text = _formatBigInt(pos.stakedAmount);
                }
                // 更新 provider 中的 selectedValidator（ATOM 需要）
                if (pos.validator != null) {
                  _provider.selectValidator(pos.validator!);
                }
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              border: isSelected
                  ? Border.all(
                      color: Colors.orange,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos.validator != null
                            ? pos.validator!.name
                            : widget.protocol.name,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.w600,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        '${S.of(context).g_key_stake_staked}: ${_formatBigInt(pos.stakedAmount)} ${widget.protocol.chainSymbol}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(24),
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.orange, size: ScreenUtil().setWidth(36)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 解质押金额输入框（ATOM 专用，支持部分解绑）
  Widget _buildUnstakeAmountInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _unstakeAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() => _errorMessage = ''),
            ),
          ),
          Text(
            widget.protocol.chainSymbol,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  /// 解质押快捷百分比按钮（ATOM 专用）
  Widget _buildQuickUnstakeButtons(BuildContext context) {
    if (_selectedPosition == null) return const SizedBox.shrink();
    final stakedAmount = _selectedPosition!.stakedAmount;

    return Row(
      children: [
        for (final pct in [
          ('25%', 0.25),
          ('50%', 0.5),
          ('75%', 0.75),
          ('MAX', 1.0),
        ]) ...[
          Expanded(
            child: GestureDetector(
              onTap: () {
                final decimals = _getDecimals();
                final scaled = stakedAmount *
                    BigInt.from((pct.$2 * 1000).round()) ~/
                    BigInt.from(1000);
                final divisor = BigInt.from(10).pow(decimals);
                final intPart = scaled ~/ divisor;
                final fracStr =
                    scaled.remainder(divisor).abs().toString().padLeft(decimals, '0');
                final dispFrac =
                    fracStr.length > 6 ? fracStr.substring(0, 6) : fracStr;
                _unstakeAmountController.text = '$intPart.$dispFrac';
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                decoration: BoxDecoration(
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
                  borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                ),
                child: Center(
                  child: Text(
                    pct.$1,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(24),
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoWalletHint(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Center(
        child: Text(
          S.of(context).g_key_stake_no_wallet,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
      ),
    );
  }

  /// BigInt 转人类可读字符串（最多 6 位小数）
  String _formatBigInt(BigInt amount) {
    final decimals = _getDecimals();
    final divisor = BigInt.from(10).pow(decimals);
    final intPart = amount ~/ divisor;
    final fracStr = amount.remainder(divisor).abs().toString().padLeft(decimals, '0');
    final dispFrac = fracStr.length > 6 ? fracStr.substring(0, 6) : fracStr;
    // 去掉尾部多余 0
    final trimmed = dispFrac.replaceAll(RegExp(r'0+$'), '');
    return trimmed.isEmpty ? '$intPart' : '$intPart.$trimmed';
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(28),
        fontWeight: FontWeight.w600,
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
      ),
    );
  }

  Widget _buildValidatorSelector(BuildContext context, StakingProvider provider) {
    return GestureDetector(
      onTap: () => _navigateToValidatorList(context, provider),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          border: Border.all(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          ),
        ),
        child: Row(
          children: [
            if (provider.selectedValidator != null) ...[
              // 选中的验证者
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.selectedValidator!.name,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        fontWeight: FontWeight.w600,
                        color: AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.mainTextColor.name,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(4)),
                    Text(
                      '${S.of(context).g_key_stake_commission}: ${provider.selectedValidator!.commission.toStringAsFixed(1)}% | ${S.of(context).g_key_stake_apy}: ${provider.selectedValidator!.apy.toStringAsFixed(1)}%',
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
            ] else ...[
              // 未选择验证者
              Icon(
                Icons.account_balance,
                color: AppThemeUtils.getColorByKey(
                  context,
                  AppThemeKeys.itemSubtitleTextColor.name,
                ),
                size: ScreenUtil().setWidth(36),
              ),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Expanded(
                child: Text(
                  S.of(context).g_key_stake_select_a_validator,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(28),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildAmountInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(
                fontSize: ScreenUtil().setSp(32),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
              ),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: TextStyle(
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _errorMessage = '';
                });
              },
            ),
          ),
          Text(
            widget.protocol.chainSymbol,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
              fontWeight: FontWeight.w600,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons(BuildContext context) {
    return Row(
      children: [
        _buildQuickAmountButton(context, '25%', 0.25),
        SizedBox(width: ScreenUtil().setWidth(12)),
        _buildQuickAmountButton(context, '50%', 0.5),
        SizedBox(width: ScreenUtil().setWidth(12)),
        _buildQuickAmountButton(context, '75%', 0.75),
        SizedBox(width: ScreenUtil().setWidth(12)),
        _buildQuickAmountButton(context, 'MAX', 1.0),
      ],
    );
  }

  Widget _buildQuickAmountButton(BuildContext context, String label, double percentage) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 使用整数运算避免浮点精度丢失
          final decimals = _getDecimals();
          final scaledAmount = _balance * BigInt.from((percentage * 1000).round()) ~/ BigInt.from(1000);
          final divisor = BigInt.from(10).pow(decimals);
          final intPart = scaledAmount ~/ divisor;
          final fracPart = scaledAmount.remainder(divisor).abs();
          final fracStr = fracPart.toString().padLeft(decimals, '0');
          // 显示最多 6 位小数
          final displayFrac = fracStr.length > 6 ? fracStr.substring(0, 6) : fracStr;
          _amountController.text = '$intPart.$displayFrac';
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(12)),
          decoration: BoxDecoration(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(24),
                fontWeight: FontWeight.w600,
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStakeEstimate(BuildContext context, StakingProvider provider) {
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;

    // 计算年收益
    final yearlyReward = amount * provider.currentApy / 100;
    final dailyReward = yearlyReward / 365;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_stake_estimated_daily,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Text(
                '${dailyReward.toStringAsFixed(6)} ${widget.protocol.chainSymbol}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenUtil().setWidth(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_stake_estimated_yearly,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                    context,
                    AppThemeKeys.itemSubtitleTextColor.name,
                  ),
                ),
              ),
              Text(
                '${yearlyReward.toStringAsFixed(4)} ${widget.protocol.chainSymbol}',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (widget.protocol.isLiquid) ...[
            SizedBox(height: ScreenUtil().setWidth(12)),
            Divider(),
            SizedBox(height: ScreenUtil().setWidth(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).g_key_stake_you_receive,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.itemSubtitleTextColor.name,
                    ),
                  ),
                ),
                Text(
                  '~$amountText ${widget.protocol.liquidTokenSymbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w600,
                    color: AppThemeUtils.getColorByKey(
                      context,
                      AppThemeKeys.mainTextColor.name,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStakeButton(BuildContext context, StakingProvider provider) {
    final isValidatorRequired = _needsValidator() && provider.selectedValidator == null;
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;
    final isAmountValid = amount >= widget.protocol.minStakeAmount;
    final isEnabled = !isValidatorRequired && isAmountValid && !_isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _performStake(context, provider) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
              : AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: ScreenUtil().setWidth(32),
                height: ScreenUtil().setWidth(32),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isValidatorRequired
                    ? S.of(context).g_key_stake_select_a_validator
                    : !isAmountValid
                        ? '${S.of(context).g_key_stake_min_stake}: ${widget.protocol.minStakeAmount} ${widget.protocol.chainSymbol}'
                        : S.of(context).g_key_stake_stake,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(32),
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? Colors.white
                      : AppThemeUtils.getColorByKey(
                          context,
                          AppThemeKeys.itemSubtitleTextColor.name,
                        ),
                ),
              ),
      ),
    );
  }

  Future<void> _navigateToValidatorList(BuildContext context, StakingProvider provider) async {
    final selectedValidator = await Navigator.push<Validator>(
      context,
      MaterialPageRoute(
        builder: (context) => ValidatorListPage(
          protocol: widget.protocol,
          validators: provider.validators,
          selectedValidator: provider.selectedValidator,
        ),
      ),
    );

    if (selectedValidator != null) {
      provider.selectValidator(selectedValidator);
    }
  }

  Future<void> _performStake(BuildContext context, StakingProvider provider) async {
    if (widget.userAddress == null || widget.userAddress!.isEmpty) {
      setState(() {
        _errorMessage = S.of(context).g_key_stake_no_wallet;
      });
      return;
    }

    final amountText = _amountController.text;
    final amountBigInt = _parseAmountToBigInt(amountText, _getDecimals());
    // 提前捕获跨异步使用的对象
    final messenger = ScaffoldMessenger.of(context);
    final txPreparedMsg = S.of(context).g_key_stake_tx_prepared;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await provider.buildStakeTransaction(
        fromAddress: widget.userAddress!,
        amount: amountBigInt,
      );

      if (result != null && result.success) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text(txPreparedMsg), backgroundColor: Colors.green),
        );
      } else {
        setState(() {
          _errorMessage = result?.error ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 将用户输入的金额字符串精确转换为 BigInt（最小单位）
  ///
  /// 避免使用 double 中间转换导致的精度丢失。
  /// 例如：输入 "1.5"，decimals=18 -> 1500000000000000000
  BigInt _parseAmountToBigInt(String amountText, int decimals) {
    if (amountText.isEmpty) return BigInt.zero;

    final parts = amountText.split('.');
    final integerPart = parts[0].isEmpty ? '0' : parts[0];
    String fractionalPart = parts.length > 1 ? parts[1] : '';

    // 截断超出精度的小数位
    if (fractionalPart.length > decimals) {
      fractionalPart = fractionalPart.substring(0, decimals);
    }

    // 右侧补零到 decimals 位
    fractionalPart = fractionalPart.padRight(decimals, '0');

    final combined = '$integerPart$fractionalPart';
    return BigInt.tryParse(combined) ?? BigInt.zero;
  }

  Future<void> _performUnstake(BuildContext context, StakingProvider provider) async {
    if (widget.userAddress == null || widget.userAddress!.isEmpty) {
      setState(() => _errorMessage = S.of(context).g_key_stake_no_wallet);
      return;
    }

    if (_selectedPosition == null) {
      setState(() => _errorMessage = S.of(context).g_key_stake_select_position);
      return;
    }

    // 解质押金额：SOL 全量，ATOM 可自定义
    BigInt unstakeAmount;
    if (widget.protocol.chainType == StakingChainType.cosmos) {
      final amtText = _unstakeAmountController.text;
      unstakeAmount = _parseAmountToBigInt(amtText, _getDecimals());
      if (unstakeAmount == BigInt.zero) {
        setState(() => _errorMessage = S.of(context).g_key_stake_amount_unstake);
        return;
      }
    } else {
      // SOL：全量解绑整个 stake account
      unstakeAmount = _selectedPosition!.stakedAmount;
    }

    // 提前捕获跨异步使用的对象
    final messenger = ScaffoldMessenger.of(context);
    final txPreparedMsg = S.of(context).g_key_stake_tx_prepared;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final positionToUnstake = _selectedPosition!;
    try {
      final result = await provider.buildUnstakeTransaction(
        position: positionToUnstake,
        fromAddress: widget.userAddress!,
        amount: unstakeAmount,
      );

      if (!mounted) return;

      if (result != null && result.success) {
        messenger.showSnackBar(
          SnackBar(content: Text(txPreparedMsg), backgroundColor: Colors.green),
        );
        // 解质押成功后刷新仓位列表
        setState(() => _selectedPosition = null);
        await _loadActivePositions();
      } else {
        setState(() {
          _errorMessage = result?.error ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
