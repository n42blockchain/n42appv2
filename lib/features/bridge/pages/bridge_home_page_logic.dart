// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_history_page.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/wallet/api/sender/sender_factory.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_home_page.dart';

/// 业务逻辑 mixin：状态字段、签名广播、导航、工具方法
mixin BridgeHomeLogicMixin on ConsumerState<BridgeHomePage> {
  late BridgeProvider bridgeProvider;
  final TextEditingController amountController = TextEditingController();

  // 缓存 RegExp，避免每次 formatAmount 时重新编译
  static final trailingZeroRegex = RegExp(r'0+$');

  // 可选滑点列表（百分比）
  static const slippageOptions = [0.1, 0.5, 1.0, 2.0];

  /// 当 BridgeProvider 检测到交易到达终态时调用
  void handleStatusChange(
    BridgeTransaction tx,
    BridgeTransactionStatus newStatus,
  ) {
    if (!mounted) return;
    final isSuccess = newStatus == BridgeTransactionStatus.completed;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        backgroundColor: isSuccess ? AppColorTokens.of(context).success : AppColorTokens.of(context).danger,
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            SizedBox(width: AppSpacing.space4),
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
          onPressed: () => openHistory(),
        ),
      ),
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BridgeHistoryPage(provider: bridgeProvider),
      ),
    );
  }

  Future<void> onButtonPressed(
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
        signAndSend: (txData) => signAndBroadcast(context, txData, provider),
      );

      if (!result.error && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).g_key_bridge_tx_pending),
            backgroundColor: AppColorTokens.of(context).warning,
            duration: const Duration(seconds: 3),
          ),
        );
        // 先导航到历史页再 reset，确保历史页第一帧能读取新记录
        openHistory();
        provider.reset();
        amountController.clear();
      }
    } else {
      await provider.getQuote(fromAddress: address, toAddress: address);
    }
  }

  // ─── 签名广播 ────────────────────────────────────────────────────────────────

  Future<String?> signAndBroadcast(
    BuildContext context,
    Map<String, dynamic> txData,
    BridgeProvider provider,
  ) async {
    try {
      final strings = S.of(context);
      final walletProvider = ref.read(wapBridgeProvider);
      final walletInfo = walletProvider.walletInfo;
      final mnemonic = walletInfo.mnemonic ?? '';
      final privateKey = walletInfo.privateKey ?? '';

      if (mnemonic.isEmpty && privateKey.isEmpty) {
        _showSnack(context, S.of(context).g_key_210);
        return null;
      }

      final fromChainId =
          provider.fromChain?.chainId ?? BridgeChainIds.ethereum;
      final chainSymbol = getChainSymbol(fromChainId);

      final coinInfo = walletProvider.walletMap[chainSymbol];
      if (coinInfo == null) {
        _showSnack(context, S.of(context).g_key_bridge_chain_not_supported);
        return null;
      }

      final pathMap = coinInfo['baseInfo']['path'] as Map<String, dynamic>;
      final pathIndex = coinInfo['pathIndex'] ?? 0;
      final path = getPathWithIndex(
        pathMap['legacy'] ?? "m/44'/60'/0'/0/0",
        pathIndex,
      );

      // 走钱包统一发送通道(EvmSender):构建 SendParams → 估算(含 calldata)
      // → 签名 → sendRawTransaction 广播,返回真实链上 txHash。
      // 此前仅 trustdart.signTransaction 拿到已签名 blob 直接 return,从不广播;
      // 且 LiFi 的 txData schema(to/value/data)与 trustdart signMap 键名不符——
      // 跨链交易在链上什么都不做(接线复审第二轮 P0)。approve 与 bridge 两笔
      // 都经本方法广播,统一修复。
      final cm = walletProvider.getCoinModelWithCoinType(chainSymbol);
      if (cm == null) {
        _showSnack(context, S.of(context).g_key_bridge_chain_not_supported);
        return null;
      }
      final toAddress = txData['to']?.toString() ?? '';
      final calldata = txData['data']?.toString() ?? '';
      final valueWei = _parseTxWei(txData['value']);
      if (toAddress.isEmpty) {
        _showSnack(context, strings.g_key_175);
        return null;
      }

      final result = await SenderFactory.instance
          .getSender(chainSymbol)
          .send(
            SendParams(
              coinType: chainSymbol,
              fromAddress: cm.address,
              toAddress: toAddress,
              // 名义金额供 gas 估算;精确 value 由 valueWeiOverride 透传给签名。
              amount: valueWei == BigInt.zero ? 0.0 : valueWei.toDouble() / 1e18,
              decimals: 18,
              path: path,
              isTest: cm.isTest,
              privateKey: cm.privateKey,
              chainConfig: cm.coin,
              // LiFi diamond 合约调用:calldata 带上,contractAddress 留空走
              // raw-data 分支(与加速/aave/staking 同款),value 经 override 精确保留。
              calldata: calldata.isEmpty || calldata == '0x' ? null : calldata,
              valueWeiOverride: valueWei,
            ),
          );
      if (!context.mounted) return null;
      if (!result.success) {
        _showSnack(context, result.error ?? strings.g_key_175);
        return null;
      }
      return result.txHash;
    } catch (e) {
      if (!context.mounted) return null;
      _showSnack(context, e.toString());
      return null;
    }
  }

  /// 解析 LiFi txData 的 value(十六进制 '0x..' 或十进制串)为 wei。
  BigInt _parseTxWei(dynamic v) {
    if (v == null) return BigInt.zero;
    final s = v.toString().trim();
    if (s.isEmpty) return BigInt.zero;
    if (s.startsWith('0x') || s.startsWith('0X')) {
      return BigInt.tryParse(s.substring(2), radix: 16) ?? BigInt.zero;
    }
    return BigInt.tryParse(s) ?? BigInt.zero;
  }

  void _showSnack(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  static const _chainSymbols = {
    BridgeChainIds.ethereum: 'ETH',
    BridgeChainIds.bsc: 'BNB',
    BridgeChainIds.polygon: 'MATIC',
    BridgeChainIds.arbitrum: 'ARB',
    BridgeChainIds.optimism: 'OP',
    BridgeChainIds.avalanche: 'AVAX',
    BridgeChainIds.base: 'BASE',
    BridgeChainIds.fantom: 'FTM',
  };

  String getChainSymbol(int chainId) => _chainSymbols[chainId] ?? 'ETH';

  // ─── 工具方法 ────────────────────────────────────────────────────────────────

  String formatAmount(String amount, int decimals) {
    try {
      final value = BigInt.parse(amount);
      final divisor = BigInt.from(10).pow(decimals);
      final whole = value ~/ divisor;
      final fraction = (value % divisor).toString().padLeft(decimals, '0');

      if (decimals == 0) return whole.toString();

      String trimmedFraction = fraction.replaceAll(trailingZeroRegex, '');
      if (trimmedFraction.isEmpty) return whole.toString();

      if (trimmedFraction.length > 6) {
        trimmedFraction = trimmedFraction.substring(0, 6);
      }

      return '$whole.$trimmedFraction';
    } catch (e) {
      return '0';
    }
  }

  // ─── 代币选择 Sheet ──────────────────────────────────────────────────────────

  Future<BridgeToken?> showTokenSelector(
    BuildContext context,
    List<BridgeToken> tokens,
    BridgeToken? selected,
  ) {
    return showModalBottomSheet<BridgeToken>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorTokens.of(context).bgBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ScreenUtil().setWidth(20)),
        ),
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
                  padding: EdgeInsets.all(AppSpacing.space8),
                  child: Text(
                    S.of(context).g_key_bridge_select_token,
                    style: AppTypography.headline.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColorTokens.of(context).textPrimary,
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
                                borderRadius: AppRadius.brMd,
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
                            ?  Icon(Icons.check, color: AppColorTokens.of(context).success)
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
}
