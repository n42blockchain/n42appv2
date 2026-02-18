// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/core/providers/legacy_wallet_adapter.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/staking/models/staking_models.dart';
import 'package:n42appv2/src/staking/pages/validator_list_page.dart';
import 'package:n42appv2/src/staking/provider/staking_provider.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';

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

  bool _isLoading = false;
  BigInt _balance = BigInt.zero;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _provider = StakingProvider();
    _provider.selectProtocol(widget.protocol);

    // 加载验证者列表（如果需要）
    if (_needsValidator()) {
      _provider.loadValidators();
    }

    // TODO: 加载用户余额
    _loadBalance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _provider.dispose();
    super.dispose();
  }

  bool _needsValidator() {
    return widget.protocol.chainType != StakingChainType.ethereum;
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
                              'Liquid',
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
                          ? 'Receive ${widget.protocol.liquidTokenSymbol} after staking'
                          : 'Unbonding period: ${widget.protocol.unbondingPeriodDays} days',
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
          Tab(text: 'Stake'),
          Tab(text: 'Unstake'),
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
                _buildSectionTitle(context, 'Select Validator'),
                SizedBox(height: ScreenUtil().setWidth(12)),
                _buildValidatorSelector(context, provider),
                SizedBox(height: ScreenUtil().setWidth(24)),
              ],

              // 金额输入
              _buildSectionTitle(context, 'Amount'),
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
        // 如果是流动性质押，显示不同的提示
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
                    'Liquid Staking',
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
                  Text(
                    'Your ${widget.protocol.liquidTokenSymbol} can be traded directly on DEX without unstaking. Go to Swap to exchange it back to ${widget.protocol.chainSymbol}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(26),
                      color: AppThemeUtils.getColorByKey(
                        context,
                        AppThemeKeys.itemSubtitleTextColor.name,
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setWidth(30)),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: 导航到 Swap 页面
                      Navigator.pop(context);
                    },
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
                      'Go to Swap',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(28),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 非流动性质押的解除质押页面
        return SingleChildScrollView(
          padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 解绑说明
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
                        'Unstaking takes ${widget.protocol.unbondingPeriodDays} days. Your tokens will be locked during this period.',
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

              // 金额输入
              _buildSectionTitle(context, 'Amount to Unstake'),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildAmountInput(context),
              SizedBox(height: ScreenUtil().setWidth(12)),
              _buildQuickAmountButtons(context),
              SizedBox(height: ScreenUtil().setWidth(24)),

              // Unstake 按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _performUnstake(context, provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
                          'Unstake',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                      'Commission: ${provider.selectedValidator!.commission.toStringAsFixed(1)}% | APY: ${provider.selectedValidator!.apy.toStringAsFixed(1)}%',
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
                  'Select a validator',
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
                'Estimated Daily Reward',
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
                'Estimated Yearly Reward',
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
                  'You will receive',
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
                    ? 'Select a Validator'
                    : !isAmountValid
                        ? 'Min: ${widget.protocol.minStakeAmount} ${widget.protocol.chainSymbol}'
                        : 'Stake',
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
        _errorMessage = 'No wallet address available';
      });
      return;
    }

    final amountText = _amountController.text;
    final amountBigInt = _parseAmountToBigInt(amountText, _getDecimals());

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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction prepared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = result?.error ?? 'Failed to build transaction';
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
    // TODO: 实现解除质押
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unstake functionality coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
