// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/src/bridge/models/bridge_models.dart';
import 'package:n42_wallet/src/bridge/pages/bridge_select_chain_page.dart';
import 'package:n42_wallet/src/bridge/pages/bridge_history_page.dart';
import 'package:n42_wallet/src/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/src/wallet/provider/trustdart.dart';
import 'package:n42_wallet/src/wallet/utils/chain_util.dart';
import 'package:n42_wallet/src/widgets/app_bar_widget.dart';
import 'package:n42_wallet/src/widgets/button_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

/// 跨链桥主页面
class BridgeHomePage extends ConsumerStatefulWidget {
  const BridgeHomePage({super.key});

  @override
  ConsumerState<BridgeHomePage> createState() => _BridgeHomePageState();
}

class _BridgeHomePageState extends ConsumerState<BridgeHomePage> {
  late BridgeProvider _bridgeProvider;
  final TextEditingController _amountController = TextEditingController();

  // 缓存 RegExp，避免每次 _formatAmount 时重新编译
  static final _trailingZeroRegex = RegExp(r'0+$');

  // 可选滑点列表（百分比）
  static const _slippageOptions = [0.1, 0.5, 1.0, 2.0];

  @override
  void initState() {
    super.initState();
    _bridgeProvider = BridgeProvider();
    // 注册状态变化回调（在终态时弹出通知）
    _bridgeProvider.onStatusChanged = _handleStatusChange;
    _bridgeProvider.initialize();
  }

  @override
  void dispose() {
    // 清除回调，防止 provider 在 widget 销毁后触发野回调
    _bridgeProvider.onStatusChanged = null;
    _amountController.dispose();
    _bridgeProvider.dispose();
    super.dispose();
  }

  /// 当 BridgeProvider 检测到交易到达终态时调用
  void _handleStatusChange(
    BridgeTransaction tx,
    BridgeTransactionStatus newStatus,
  ) {
    if (!mounted) return;
    final isSuccess = newStatus == BridgeTransactionStatus.completed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            SizedBox(width: ScreenUtil().setWidth(12)),
            Expanded(
              child: Text(
                isSuccess
                    ? S.of(context).g_key_bridge_tx_success
                    : S.of(context).g_key_bridge_tx_failed,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: S.of(context).g_key_bridge_history,
          textColor: Colors.white,
          onPressed: () => _openHistory(),
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BridgeHistoryPage(provider: _bridgeProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        text: S.of(context).g_key_bridge_title,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _bridgeProvider,
        builder: (context, _) {
          final provider = _bridgeProvider;
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 源链选择卡
                        _buildChainCard(context, provider, isFrom: true),

                        // 交换方向按钮
                        _buildSwapButton(context, provider),

                        // 目标链选择卡
                        _buildChainCard(context, provider, isFrom: false),

                        SizedBox(height: ScreenUtil().setWidth(24)),

                        // 滑点选择器（有报价后显示）
                        if (provider.quoteResponse?.hasRoutes == true) ...[
                          _buildSlippageSelector(context, provider),
                          SizedBox(height: ScreenUtil().setWidth(24)),
                        ],

                        // 全部路由对比卡（有报价时显示）
                        if (provider.quoteResponse != null)
                          _buildAllRoutesSection(context, provider),

                        // 错误提示
                        if (provider.errorMessage != null)
                          _buildErrorMessage(context, provider),
                      ],
                    ),
                  ),
                ),

                // 底部操作按钮
                _buildBottomButton(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── 源/目标链卡片 ──────────────────────────────────────────────────────────

  Widget _buildChainCard(
    BuildContext context,
    BridgeProvider provider, {
    required bool isFrom,
  }) {
    final chain = isFrom ? provider.fromChain : provider.toChain;
    final token = isFrom ? provider.fromToken : provider.toToken;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签 + 链选择器
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFrom ? S.of(context).g_key_75 : S.of(context).g_key_38,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(
                      context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              _buildChainPicker(context, provider, chain, isFrom),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 代币选择 + 金额
          Row(
            children: [
              _buildTokenPicker(context, provider, chain, token, isFrom),
              SizedBox(width: ScreenUtil().setWidth(20)),
              Expanded(
                child: isFrom
                    ? TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                            color: AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.textFieldHintColor.name),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: provider.setFromAmount,
                      )
                    : Text(
                        provider.selectedRoute != null
                            ? _formatAmount(
                                provider.selectedRoute!.toAmount,
                                provider.toToken?.decimals ?? 18,
                              )
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChainPicker(
    BuildContext context,
    BridgeProvider provider,
    BridgeChain? chain,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      onTap: () async {
        final selected = await Navigator.push<BridgeChain>(
          context,
          MaterialPageRoute(
            builder: (_) => BridgeSelectChainPage(
              chains: provider.chains,
              selectedChain: chain,
              excludeChain: isFrom ? provider.toChain : provider.fromChain,
            ),
          ),
        );
        if (selected != null) {
          if (isFrom) {
            provider.setFromChain(selected);
          } else {
            provider.setToChain(selected);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(20),
          vertical: ScreenUtil().setWidth(10),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chain?.logoUri.isNotEmpty == true)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(16)),
                child: Image.network(
                  chain!.logoUri,
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                  errorBuilder: (ctx, err, stack) =>
                      Icon(Icons.circle, size: ScreenUtil().setWidth(32)),
                ),
              ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Text(
              chain?.name ?? S.of(context).g_key_17,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(4)),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenUtil().setWidth(32),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenPicker(
    BuildContext context,
    BridgeProvider provider,
    BridgeChain? chain,
    BridgeToken? token,
    bool isFrom,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      onTap: () async {
        if (chain == null) return;
        final tokens = provider.getTokensForChain(chain.chainId);
        if (tokens.isEmpty) return;
        final selected =
            await _showTokenSelector(context, tokens, token);
        if (selected != null) {
          if (isFrom) {
            provider.setFromToken(selected);
          } else {
            provider.setToToken(selected);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenUtil().setWidth(16),
          vertical: ScreenUtil().setWidth(12),
        ),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.backGroundColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (token?.logoUri.isNotEmpty == true)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(16)),
                child: Image.network(
                  token!.logoUri,
                  width: ScreenUtil().setWidth(40),
                  height: ScreenUtil().setWidth(40),
                  errorBuilder: (ctx, err, stack) =>
                      Icon(Icons.token, size: ScreenUtil().setWidth(40)),
                ),
              ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            Text(
              token?.symbol ?? S.of(context).g_key_bridge_select,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(30),
                fontWeight: FontWeight.bold,
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.mainTextColor.name),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenUtil().setWidth(28),
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainTextColor.name),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 交换方向按钮 ────────────────────────────────────────────────────────────

  Widget _buildSwapButton(BuildContext context, BridgeProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(16)),
        child: IconButton(
          onPressed: provider.state == BridgeState.idle
              ? () {
                  provider.swapChains();
                  _amountController.clear();
                }
              : null,
          icon: Container(
            padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
            decoration: BoxDecoration(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.mainBlueColor.name),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_vert,
              color: Colors.white,
              size: ScreenUtil().setWidth(40),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 滑点选择器 ──────────────────────────────────────────────────────────────

  Widget _buildSlippageSelector(
      BuildContext context, BridgeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_bridge_slippage,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(26),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        Row(
          children: _slippageOptions.map((pct) {
            final selected = (provider.slippage - pct).abs() < 0.001;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                child: GestureDetector(
                  onTap: () => provider.setSlippage(pct),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(14)),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainButtonBgColor.name)
                          : AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.itemBgColor.name),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(8)),
                      border: Border.all(
                        color: selected
                            ? AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainButtonBgColor.name)
                            : AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.dividerColor.name),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(26),
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? AppThemeUtils.getColorByKey(
                                context,
                                AppThemeKeys.mainButtonTextColor.name)
                            : AppThemeUtils.getColorByKey(
                                context, AppThemeKeys.mainTextColor.name),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── 路由对比区（全部路由）──────────────────────────────────────────────────

  Widget _buildAllRoutesSection(
      BuildContext context, BridgeProvider provider) {
    final response = provider.quoteResponse!;

    if (!response.hasRoutes) {
      return Container(
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
        ),
        child: Center(
          child: Text(
            S.of(context).g_key_bridge_no_routes,
            style: TextStyle(
              color: AppThemeUtils.getColorByKey(
                  context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).g_key_bridge_route,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.mainTextColor.name),
          ),
        ),
        SizedBox(height: ScreenUtil().setWidth(12)),
        ...response.routes
            .map((r) => _buildRouteCard(context, provider, r)),
      ],
    );
  }

  /// 单个路由卡片（支持选中高亮）
  Widget _buildRouteCard(
    BuildContext context,
    BridgeProvider provider,
    BridgeRoute route,
  ) {
    final isSelected = provider.selectedRoute?.id == route.id;
    final selectedColor = AppThemeUtils.getColorByKey(
        context, AppThemeKeys.mainBlueColor.name);

    // 标签优先级：RECOMMENDED > FASTEST > CHEAPEST
    String? tagLabel;
    Color tagColor = Colors.grey;
    if (route.isRecommended) {
      tagLabel = S.of(context).g_key_bridge_recommended;
      tagColor = Colors.green;
    } else if (route.isFastest) {
      tagLabel = S.of(context).g_key_bridge_fastest;
      tagColor = Colors.orange;
    } else if (route.isCheapest) {
      tagLabel = S.of(context).g_key_bridge_cheapest;
      tagColor = Colors.blue;
    }

    // 路由使用的协议名称（step 聚合）
    final protocols = route.steps
        .map((s) => s.toolName)
        .toSet()
        .join(' + ');

    final toDecimals = provider.toToken?.decimals ?? 18;
    final receiveAmt = _formatAmount(route.toAmount, toDecimals);
    final minReceive = _formatAmount(route.toAmountMin, toDecimals);
    final gasCost = route.gasCostUSD > 0
        ? '\$${route.gasCostUSD.toStringAsFixed(2)}'
        : '—';
    final minutes = (route.estimatedSeconds / 60).ceil();

    return GestureDetector(
      onTap: () => provider.selectRoute(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
        padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
        decoration: BoxDecoration(
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemBgColor.name),
          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 协议 + 标签
            Row(
              children: [
                // 第一个 step logo
                if (route.steps.isNotEmpty &&
                    route.steps.first.toolLogoUri.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(10)),
                    child: Image.network(
                      route.steps.first.toolLogoUri,
                      width: ScreenUtil().setWidth(32),
                      height: ScreenUtil().setWidth(32),
                      errorBuilder: (ctx, err, stack) =>
                          Icon(Icons.link, size: ScreenUtil().setWidth(32)),
                    ),
                  )
                else
                  Icon(Icons.link, size: ScreenUtil().setWidth(32)),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Expanded(
                  child: Text(
                    protocols.isNotEmpty ? protocols : route.id,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(28),
                      fontWeight: FontWeight.w600,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (tagLabel != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(10),
                      vertical: ScreenUtil().setWidth(4),
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withAlpha(30),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(6)),
                      border: Border.all(color: tagColor),
                    ),
                    child: Text(
                      tagLabel,
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        color: tagColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
                    child: Icon(
                      Icons.check_circle,
                      color: selectedColor,
                      size: ScreenUtil().setWidth(32),
                    ),
                  ),
              ],
            ),

            SizedBox(height: ScreenUtil().setWidth(16)),

            // 接收量 + 最小接收量
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).g_key_bridge_estimated_receive,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                      SizedBox(height: ScreenUtil().setWidth(4)),
                      Text(
                        '$receiveAmt ${provider.toToken?.symbol ?? ''}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(
                              context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                      Text(
                        'Min: $minReceive ${provider.toToken?.symbol ?? ''}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(22),
                          color: AppThemeUtils.getColorByKey(context,
                              AppThemeKeys.itemSubtitleTextColor.name),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gas + 时间
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _infoChip(
                      context,
                      Icons.local_gas_station_outlined,
                      gasCost,
                    ),
                    SizedBox(height: ScreenUtil().setWidth(8)),
                    _infoChip(
                      context,
                      Icons.access_time,
                      '~$minutes min',
                    ),
                  ],
                ),
              ],
            ),

            // 步骤详情
            if (route.steps.length > 1) ...[
              SizedBox(height: ScreenUtil().setWidth(12)),
              Wrap(
                spacing: ScreenUtil().setWidth(8),
                runSpacing: ScreenUtil().setWidth(4),
                children: route.steps.map((step) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(10),
                      vertical: ScreenUtil().setWidth(4),
                    ),
                    decoration: BoxDecoration(
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.backGroundColor.name),
                      borderRadius:
                          BorderRadius.circular(ScreenUtil().setWidth(6)),
                    ),
                    child: Text(
                      '${step.fromToken.symbol} → ${step.toToken.symbol} via ${step.toolName}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(20),
                        color: AppThemeUtils.getColorByKey(context,
                            AppThemeKeys.itemSubtitleTextColor.name),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: ScreenUtil().setWidth(26),
          color: AppThemeUtils.getColorByKey(
              context, AppThemeKeys.itemSubtitleTextColor.name),
        ),
        SizedBox(width: ScreenUtil().setWidth(4)),
        Text(
          text,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(24),
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.itemSubtitleTextColor.name),
          ),
        ),
      ],
    );
  }

  // ─── 错误信息 ────────────────────────────────────────────────────────────────

  Widget _buildErrorMessage(BuildContext context, BridgeProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.errorBgColor2.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.errorTextColor.name),
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(
                    context, AppThemeKeys.errorTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 底部按钮 ────────────────────────────────────────────────────────────────

  Widget _buildBottomButton(BuildContext context, BridgeProvider provider) {
    final isLoading = provider.state == BridgeState.loadingQuotes ||
        provider.state == BridgeState.executing;

    final canGetQuote = provider.fromChain != null &&
        provider.toChain != null &&
        provider.fromToken != null &&
        provider.toToken != null &&
        provider.fromAmount.isNotEmpty;

    final canExecute = provider.selectedRoute != null;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(
            context, AppThemeKeys.backGroundColor.name),
        border: Border(
          top: BorderSide(
            color: AppThemeUtils.getColorByKey(
                context, AppThemeKeys.dividerColor.name),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtil().setWidth(88),
        child: buttonStyle6(
          context,
          isLoading ? () {} : () => _onButtonPressed(context, provider, canGetQuote, canExecute),
          isLoading
              ? '${S.of(context).g_key_106}...'
              : canExecute
                  ? S.of(context).g_key_bridge_swap
                  : S.of(context).g_key_bridge_get_quote,
          AppThemeUtils.getColorByKey(
            context,
            isLoading || !canGetQuote
                ? AppThemeKeys.mainButtonBgColor3.name
                : AppThemeKeys.mainButtonBgColor.name,
          ),
          AppThemeUtils.getColorByKey(
              context, AppThemeKeys.mainButtonTextColor.name),
          isLoading,
        ),
      ),
    );
  }

  Future<void> _onButtonPressed(
    BuildContext context,
    BridgeProvider provider,
    bool canGetQuote,
    bool canExecute,
  ) async {
    if (!canGetQuote) return;

    final walletProvider = ref.read(wapBridgeProvider);
    final address = walletProvider.getAddress('ETH') ?? '';

    if (canExecute) {
      final result = await provider.executeBridge(
        fromAddress: address,
        toAddress: address,
        signAndSend: (txData) => _signAndBroadcast(context, txData, provider),
      );

      if (!result.error && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_bridge_tx_pending),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        // 先导航到历史页再 reset，确保历史页第一帧能读取新记录
        _openHistory();
        provider.reset();
        _amountController.clear();
      }
    } else {
      await provider.getQuote(fromAddress: address, toAddress: address);
    }
  }

  // ─── 代币选择 Sheet ──────────────────────────────────────────────────────────

  Future<BridgeToken?> _showTokenSelector(
    BuildContext context,
    List<BridgeToken> tokens,
    BridgeToken? selected,
  ) {
    return showModalBottomSheet<BridgeToken>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeUtils.getColorByKey(
          context, AppThemeKeys.backGroundColor.name),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenUtil().setWidth(20))),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: Text(
                    S.of(context).g_key_bridge_select_token,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(
                          context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: tokens.length,
                    itemBuilder: (context, index) {
                      final token = tokens[index];
                      final isSelected =
                          selected?.address == token.address;
                      return ListTile(
                        leading: token.logoUri.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    ScreenUtil().setWidth(20)),
                                child: Image.network(
                                  token.logoUri,
                                  width: ScreenUtil().setWidth(48),
                                  height: ScreenUtil().setWidth(48),
                                  errorBuilder: (ctx, err, stack) =>
                                      const Icon(Icons.token),
                                ),
                              )
                            : const Icon(Icons.token),
                        title: Text(token.symbol),
                        subtitle: Text(token.name),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => Navigator.pop(context, token),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── 签名广播 ────────────────────────────────────────────────────────────────

  Future<String?> _signAndBroadcast(
    BuildContext context,
    Map<String, dynamic> txData,
    BridgeProvider provider,
  ) async {
    try {
      final walletProvider = ref.read(wapBridgeProvider);
      final walletInfo = walletProvider.walletInfo;
      final mnemonic = walletInfo.mnemonic ?? '';
      final privateKey = walletInfo.privateKey ?? '';

      if (mnemonic.isEmpty && privateKey.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).g_key_210)),
          );
        }
        return null;
      }

      final fromChainId =
          provider.fromChain?.chainId ?? BridgeChainIds.ethereum;
      final chainSymbol = _getChainSymbol(fromChainId);

      final coinInfo = walletProvider.walletMap[chainSymbol];
      if (coinInfo == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(S.of(context).g_key_bridge_chain_not_supported)),
          );
        }
        return null;
      }

      final pathMap =
          coinInfo['baseInfo']['path'] as Map<String, dynamic>;
      final pathIndex = coinInfo['pathIndex'] ?? 0;
      final path = getPathWithIndex(
          pathMap['legacy'] ?? "m/44'/60'/0'/0/0", pathIndex);

      final trustdart = Trustdart();
      final signedTx = await trustdart.signTransaction(
        chainSymbol,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
      );

      if (signedTx.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).g_key_175)),
          );
        }
        return null;
      }

      // signTransaction 返回已广播的 txHash 或原始 signedTx
      // 直接返回非空字符串作为 txHash 标识
      return _extractTxHash(signedTx);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return null;
    }
  }

  /// 从 signTransaction 结果中提取 txHash
  ///
  /// - 若结果已是 0x 开头 66 字符的哈希，直接返回
  /// - 否则仍返回原值（让调用方决定如何处理）
  String? _extractTxHash(String signedTx) {
    if (signedTx.isEmpty) return null;
    return signedTx;
  }

  String _getChainSymbol(int chainId) {
    switch (chainId) {
      case BridgeChainIds.ethereum:
        return 'ETH';
      case BridgeChainIds.bsc:
        return 'BNB';
      case BridgeChainIds.polygon:
        return 'MATIC';
      case BridgeChainIds.arbitrum:
        return 'ARB';
      case BridgeChainIds.optimism:
        return 'OP';
      case BridgeChainIds.avalanche:
        return 'AVAX';
      case BridgeChainIds.base:
        return 'BASE';
      case BridgeChainIds.fantom:
        return 'FTM';
      default:
        return 'ETH';
    }
  }

  // ─── 工具方法 ────────────────────────────────────────────────────────────────

  String _formatAmount(String amount, int decimals) {
    try {
      final value = BigInt.parse(amount);
      final divisor = BigInt.from(10).pow(decimals);
      final whole = value ~/ divisor;
      final fraction =
          (value % divisor).toString().padLeft(decimals, '0');

      if (decimals == 0) return whole.toString();

      String trimmedFraction =
          fraction.replaceAll(_trailingZeroRegex, '');
      if (trimmedFraction.isEmpty) return whole.toString();

      if (trimmedFraction.length > 6) {
        trimmedFraction = trimmedFraction.substring(0, 6);
      }

      return '$whole.$trimmedFraction';
    } catch (e) {
      return '0';
    }
  }
}
