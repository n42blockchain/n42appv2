// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42appv2/generated/l10n.dart';
import 'package:n42appv2/presentation/themes/theme_adapter.dart';
import 'package:n42appv2/src/bridge/api/lifi_api.dart';
import 'package:n42appv2/src/bridge/models/bridge_models.dart';
import 'package:n42appv2/src/bridge/pages/bridge_select_chain_page.dart';
import 'package:n42appv2/src/bridge/pages/bridge_history_page.dart';
import 'package:n42appv2/src/bridge/provider/bridge_provider.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:n42appv2/src/widgets/app_bar_widget.dart';
import 'package:n42appv2/src/widgets/button_widget.dart';
import 'package:provider/provider.dart';

/// 跨链桥主页面
class BridgeHomePage extends StatefulWidget {
  const BridgeHomePage({super.key});

  @override
  State<BridgeHomePage> createState() => _BridgeHomePageState();
}

class _BridgeHomePageState extends State<BridgeHomePage> {
  late BridgeProvider _bridgeProvider;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bridgeProvider = BridgeProvider();
    _bridgeProvider.initialize();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bridgeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _bridgeProvider,
      child: Scaffold(
        appBar: AppBarWidget(
          text: S.of(context).g_key_bridge_title,
          actions: [
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: _bridgeProvider,
                      child: const BridgeHistoryPage(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<BridgeProvider>(
          builder: (context, provider, _) {
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 源链选择
                          _buildChainCard(
                            context,
                            provider,
                            isFrom: true,
                          ),

                          // 交换按钮
                          Center(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(20)),
                              child: IconButton(
                                onPressed: provider.state == BridgeState.idle
                                    ? () => provider.swapChains()
                                    : null,
                                icon: Container(
                                  padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
                                  decoration: BoxDecoration(
                                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name),
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
                          ),

                          // 目标链选择
                          _buildChainCard(
                            context,
                            provider,
                            isFrom: false,
                          ),

                          SizedBox(height: ScreenUtil().setWidth(30)),

                          // 路由信息
                          if (provider.selectedRoute != null) _buildRouteInfo(context, provider),

                          // 错误信息
                          if (provider.errorMessage != null) _buildErrorMessage(context, provider),
                        ],
                      ),
                    ),
                  ),

                  // 底部按钮
                  _buildBottomButton(context, provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChainCard(BuildContext context, BridgeProvider provider, {required bool isFrom}) {
    final chain = isFrom ? provider.fromChain : provider.toChain;
    final token = isFrom ? provider.fromToken : provider.toToken;

    return Container(
      padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和链选择
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFrom ? S.of(context).g_key_75 : S.of(context).g_key_38, // From / To
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              InkWell(
                onTap: () async {
                  final selectedChain = await Navigator.push<BridgeChain>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BridgeSelectChainPage(
                        chains: provider.chains,
                        selectedChain: chain,
                        excludeChain: isFrom ? provider.toChain : provider.fromChain,
                      ),
                    ),
                  );
                  if (selectedChain != null) {
                    if (isFrom) {
                      provider.setFromChain(selectedChain);
                    } else {
                      provider.setToChain(selectedChain);
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20),
                    vertical: ScreenUtil().setWidth(10),
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chain?.logoUri.isNotEmpty == true)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                          child: Image.network(
                            chain!.logoUri,
                            width: ScreenUtil().setWidth(32),
                            height: ScreenUtil().setWidth(32),
                            errorBuilder: (ctx, err, stack) => Icon(Icons.circle, size: ScreenUtil().setWidth(32)),
                          ),
                        ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Text(
                        chain?.name ?? S.of(context).g_key_17, // Select Chain
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(28),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(8)),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: ScreenUtil().setWidth(32),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtil().setWidth(20)),

          // 代币选择和金额输入
          Row(
            children: [
              // 代币选择
              InkWell(
                onTap: () async {
                  if (chain == null) return;
                  final tokens = provider.getTokensForChain(chain.chainId);
                  if (tokens.isEmpty) return;

                  final selectedToken = await _showTokenSelector(context, tokens, token);
                  if (selectedToken != null) {
                    if (isFrom) {
                      provider.setFromToken(selectedToken);
                    } else {
                      provider.setToToken(selectedToken);
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(16),
                    vertical: ScreenUtil().setWidth(12),
                  ),
                  decoration: BoxDecoration(
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (token?.logoUri.isNotEmpty == true)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
                          child: Image.network(
                            token!.logoUri,
                            width: ScreenUtil().setWidth(40),
                            height: ScreenUtil().setWidth(40),
                            errorBuilder: (ctx, err, stack) => Icon(Icons.token, size: ScreenUtil().setWidth(40)),
                          ),
                        ),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Text(
                        token?.symbol ?? 'Select',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: ScreenUtil().setWidth(28),
                        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: ScreenUtil().setWidth(20)),

              // 金额输入
              Expanded(
                child: isFrom
                    ? TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(40),
                          fontWeight: FontWeight.bold,
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(40),
                            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.textFieldHintColor.name),
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          provider.setFromAmount(value);
                        },
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
                          color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context, BridgeProvider provider) {
    final route = provider.selectedRoute!;

    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemBgColor.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).g_key_bridge_route,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(26),
              fontWeight: FontWeight.bold,
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
            ),
          ),
          SizedBox(height: ScreenUtil().setWidth(16)),

          // 路由步骤
          ...route.steps.map((step) => _buildRouteStep(context, step)),

          Divider(height: ScreenUtil().setWidth(30)),

          // 费用和时间
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).g_key_gas_estimated_time,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                ),
              ),
              Text(
                '~${(route.estimatedSeconds / 60).ceil()} min',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(26),
                  color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                ),
              ),
            ],
          ),

          if (route.tags.isNotEmpty) ...[
            SizedBox(height: ScreenUtil().setWidth(16)),
            Wrap(
              spacing: ScreenUtil().setWidth(10),
              children: route.tags.map((tag) {
                Color tagColor;
                switch (tag) {
                  case 'RECOMMENDED':
                    tagColor = Colors.green;
                    break;
                  case 'FASTEST':
                    tagColor = Colors.orange;
                    break;
                  case 'CHEAPEST':
                    tagColor = Colors.blue;
                    break;
                  default:
                    tagColor = Colors.grey;
                }
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(12),
                    vertical: ScreenUtil().setWidth(6),
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(ScreenUtil().setWidth(8)),
                    border: Border.all(color: tagColor),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(22),
                      color: tagColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteStep(BuildContext context, BridgeRouteStep step) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setWidth(12)),
      child: Row(
        children: [
          if (step.toolLogoUri.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
              child: Image.network(
                step.toolLogoUri,
                width: ScreenUtil().setWidth(32),
                height: ScreenUtil().setWidth(32),
                errorBuilder: (ctx, err, stack) => Icon(Icons.link, size: ScreenUtil().setWidth(32)),
              ),
            )
          else
            Icon(Icons.link, size: ScreenUtil().setWidth(32)),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.toolName,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(26),
                    fontWeight: FontWeight.w500,
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                  ),
                ),
                Text(
                  '${step.fromToken.symbol} → ${step.toToken.symbol}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '~${step.estimatedSeconds}s',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(24),
              color: AppThemeUtils.getColorByKey(context, AppThemeKeys.itemSubtitleTextColor.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, BridgeProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setWidth(20)),
      padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
      decoration: BoxDecoration(
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorBgColor2.name),
        borderRadius: BorderRadius.circular(ScreenUtil().setWidth(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
            size: ScreenUtil().setWidth(40),
          ),
          SizedBox(width: ScreenUtil().setWidth(12)),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(26),
                color: AppThemeUtils.getColorByKey(context, AppThemeKeys.errorTextColor.name),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        color: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
        border: Border(
          top: BorderSide(
            color: AppThemeUtils.getColorByKey(context, AppThemeKeys.dividerColor.name),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: ScreenUtil().setWidth(88),
        child: buttonStyle6(
          context,
          isLoading
              ? () {}
              : () {
                  _onBridgeButtonPressed(context, provider, canGetQuote, canExecute);
                },
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
          AppThemeUtils.getColorByKey(context, AppThemeKeys.mainButtonTextColor.name),
          isLoading,
        ),
      ),
    );
  }

  Future<void> _onBridgeButtonPressed(
    BuildContext context,
    BridgeProvider provider,
    bool canGetQuote,
    bool canExecute,
  ) async {
    if (!canGetQuote) return;

    final walletProvider = Provider.of<WalletActionProvider>(context, listen: false);
    final address = walletProvider.getAddress('ETH') ?? '';

    if (canExecute) {
      // 执行跨链
      final result = await provider.executeBridge(
        fromAddress: address,
        toAddress: address,
        signAndSend: (txData) async {
          return await _signAndBroadcast(context, txData, provider);
        },
      );

      if (!result.error && mounted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_140),
            backgroundColor: Colors.green,
          ),
        );
        provider.reset();
        _amountController.clear();
      }
    } else {
      // 获取报价
      await provider.getQuote(
        fromAddress: address,
        toAddress: address,
      );
    }
  }

  Future<BridgeToken?> _showTokenSelector(
    BuildContext context,
    List<BridgeToken> tokens,
    BridgeToken? selected,
  ) async {
    return showModalBottomSheet<BridgeToken>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeUtils.getColorByKey(context, AppThemeKeys.backGroundColor.name),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenUtil().setWidth(20))),
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
                Container(
                  padding: EdgeInsets.all(ScreenUtil().setWidth(30)),
                  child: Text(
                    S.of(context).g_key_bridge_select_token,
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(32),
                      fontWeight: FontWeight.bold,
                      color: AppThemeUtils.getColorByKey(context, AppThemeKeys.mainTextColor.name),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: tokens.length,
                    itemBuilder: (context, index) {
                      final token = tokens[index];
                      final isSelected = selected?.address == token.address;

                      return ListTile(
                        leading: token.logoUri.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(20)),
                                child: Image.network(
                                  token.logoUri,
                                  width: ScreenUtil().setWidth(48),
                                  height: ScreenUtil().setWidth(48),
                                  errorBuilder: (ctx, err, stack) => Icon(Icons.token),
                                ),
                              )
                            : Icon(Icons.token),
                        title: Text(token.symbol),
                        subtitle: Text(token.name),
                        trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
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

  /// 签名并广播交易
  Future<String?> _signAndBroadcast(
    BuildContext context,
    Map<String, dynamic> txData,
    BridgeProvider provider,
  ) async {
    try {
      final walletProvider = Provider.of<WalletActionProvider>(context, listen: false);
      final walletInfo = walletProvider.walletInfo;
      final mnemonic = walletInfo.mnemonic ?? '';
      final privateKey = walletInfo.privateKey ?? '';

      if (mnemonic.isEmpty && privateKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).g_key_210)),
        );
        return null;
      }

      // 获取源链符号
      final fromChainId = provider.fromChain?.chainId ?? BridgeChainIds.ethereum;
      final chainSymbol = _getChainSymbol(fromChainId);

      // 获取 derivation path
      final coinInfo = walletProvider.walletMap[chainSymbol];
      if (coinInfo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chain not supported')),
        );
        return null;
      }

      final pathMap = coinInfo['baseInfo']['path'] as Map<String, dynamic>;
      final pathIndex = coinInfo['pathIndex'] ?? 0;
      final path = getPathWithIndex(pathMap['legacy'] ?? "m/44'/60'/0'/0/0", pathIndex);

      // 调用 trustdart 签名
      final trustdart = Trustdart();
      final signedTx = await trustdart.signTransaction(
        chainSymbol,
        path,
        txData,
        mnemonic: mnemonic,
        pk: privateKey,
      );

      if (signedTx.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).g_key_175)), // Transaction failed
        );
        return null;
      }

      // 广播交易
      final rpc = chainUrlMap[chainSymbol]?['baseInfo']?['service'] as String? ?? '';
      if (rpc.isEmpty) {
        return null;
      }

      final broadcastResult = await _broadcastRawTx(rpc, signedTx);
      return broadcastResult;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return null;
    }
  }

  /// 根据 chainId 获取链符号
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

  /// 广播已签名交易
  ///
  /// 注意：实际的广播逻辑在 trustdart.signTransaction 中已处理
  /// 此方法作为备用广播入口，返回已签名交易
  Future<String?> _broadcastRawTx(String rpc, String signedTx) async {
    // signTransaction 返回的已经是广播后的 txHash
    // 如果需要额外的广播逻辑，可以在这里实现
    if (signedTx.isEmpty) return null;
    // 如果签名结果以 0x 开头且长度为66，认为是 txHash
    if (signedTx.startsWith('0x') && signedTx.length == 66) {
      return signedTx;
    }
    // 否则返回 null，表示需要额外广播
    return null;
  }

  String _formatAmount(String amount, int decimals) {
    try {
      final value = BigInt.parse(amount);
      final divisor = BigInt.from(10).pow(decimals);
      final whole = value ~/ divisor;
      final fraction = (value % divisor).toString().padLeft(decimals, '0');

      if (decimals == 0) {
        return whole.toString();
      }

      // 移除尾部的零
      String trimmedFraction = fraction.replaceAll(RegExp(r'0+$'), '');
      if (trimmedFraction.isEmpty) {
        return whole.toString();
      }

      // 最多显示 6 位小数
      if (trimmedFraction.length > 6) {
        trimmedFraction = trimmedFraction.substring(0, 6);
      }

      return '$whole.$trimmedFraction';
    } catch (e) {
      return '0';
    }
  }
}
