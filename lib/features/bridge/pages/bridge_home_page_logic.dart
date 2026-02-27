// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/presentation/themes/theme_adapter.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/features/bridge/pages/bridge_history_page.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
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
            backgroundColor: Colors.orange,
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
      final chainSymbol = getChainSymbol(fromChainId);

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
      return extractTxHash(signedTx);
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
  String? extractTxHash(String signedTx) {
    if (signedTx.isEmpty) return null;
    return signedTx;
  }

  String getChainSymbol(int chainId) {
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

  String formatAmount(String amount, int decimals) {
    try {
      final value = BigInt.parse(amount);
      final divisor = BigInt.from(10).pow(decimals);
      final whole = value ~/ divisor;
      final fraction =
          (value % divisor).toString().padLeft(decimals, '0');

      if (decimals == 0) return whole.toString();

      String trimmedFraction =
          fraction.replaceAll(trailingZeroRegex, '');
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
}
