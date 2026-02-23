import 'package:flutter/material.dart';
import 'package:n42_wallet/src/wallet/models/coin_model.dart';
import 'package:n42_wallet/src/wallet/pages/send/send_profile.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_algo.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_dot.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_memo.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_sol.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_ton.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_trx.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_xrp.dart';
import 'package:n42_wallet/src/wallet/pages/send/wallet_chain_send_zil.dart';

/// 统一发送入口，根据链类型自动路由到正确的发送页。
///
/// Profile 分类：
/// - [SendProfile.evm]  → [WalletChainSend]（Ethereum 及所有 EVM 兼容链）
/// - [SendProfile.utxo] → [WalletChainSendBtc]（Bitcoin / Qtum / Decred）
/// - [SendProfile.xrp]  → [WalletChainSendXrp]（Ripple，含 destinationTag）
/// - [SendProfile.memo] → 各链专属页，或通用 [WalletChainSendMemo]
class UnifiedSendPage extends StatelessWidget {
  final CoinModel coinModel;
  const UnifiedSendPage(this.coinModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final bt = coinModel.coin['blockchainType'] as String? ?? '';
    final profile = resolveSendProfile(bt);
    return switch (profile) {
      SendProfile.evm => WalletChainSend(coinModel),
      SendProfile.utxo => WalletChainSendBtc(coinModel),
      SendProfile.xrp => WalletChainSendXrp(coinModel),
      SendProfile.memo => _buildMemoPage(bt),
    };
  }

  Widget _buildMemoPage(String bt) => switch (bt) {
        'Solana' => WalletChainSendSol(coinModel),
        'Tron' => WalletChainSendTrx(coinModel),
        'Algorand' => WalletChainSendAlgo(coinModel),
        'Filecoin' => WalletChainSendFil(coinModel),
        'Polkadot' => WalletChainSendDot(coinModel),
        'Sui' => WalletChainSendSui(coinModel),
        'TheOpenNetwork' => WalletChainSendTon(coinModel),
        'Zilliqa' => WalletChainSendZil(coinModel),
        _ => WalletChainSendMemo(coinModel),
      };
}
