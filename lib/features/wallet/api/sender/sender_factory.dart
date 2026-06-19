// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

import 'chain_sender.dart';
import 'evm_sender.dart';
import 'btc_sender.dart';
import 'cosmos_sender.dart';
import 'sol_sender.dart';
import 'trx_sender.dart';
import 'dot_sender.dart';
import 'apt_sender.dart';
import 'ton_sender.dart';
import 'near_sender.dart';
import 'sui_sender.dart';
import 'xrp_sender.dart';
import 'algo_sender.dart';
import 'xtz_sender.dart';
import 'zil_sender.dart';
import 'fil_sender.dart';
import 'xlm_sender.dart';
import 'ada_sender.dart';
import 'vet_sender.dart';
import 'egld_sender.dart';
import 'hbar_sender.dart';
import 'strk_sender.dart';

/// Factory that creates/caches [ChainSender] instances by coin type.
///
/// Dispatch is based on `blockchainType` from [allChainUrlMap].
class SenderFactory {
  SenderFactory._();

  static final SenderFactory instance = SenderFactory._();

  final Map<String, ChainSender> _cache = {};

  /// Returns a sender for the given [coinType].
  ///
  /// Reads [allChainUrlMap] to determine the blockchain type, then returns
  /// the appropriate [ChainSender] implementation.
  ChainSender getSender(String coinType) {
    final key = coinType.toUpperCase();
    if (_cache.containsKey(key)) return _cache[key]!;

    final sender = _createSender(key);
    _cache[key] = sender;
    return sender;
  }

  ChainSender _createSender(String coinType) {
    final chainConfig = allChainUrlMap[coinType] as Map<String, dynamic>?;
    final baseInfo = chainConfig?['baseInfo'] as Map<String, dynamic>?;
    final blockchainType = baseInfo == null
        ? ''
        : CoinConfigView(baseInfo).blockchainType;

    return switch (blockchainType) {
      'Ethereum' => EvmSender(),
      'Bitcoin' => BtcSender(),
      'Cosmos' => CosmosSender(),
      'Solana' => SolSender(),
      'Tron' => TrxSender(),
      'Polkadot' => DotSender(),
      'Aptos' => AptSender(),
      'TheOpenNetwork' => TonSender(),
      'Near' => NearSender(),
      'Sui' => SuiSender(),
      'Ripple' => XrpSender(),
      'Algorand' => AlgoSender(),
      'Tezos' => XtzSender(),
      'Zilliqa' => ZilSender(),
      'Filecoin' => FilSender(),
      'Stellar' => XlmSender(),
      'Cardano' => AdaSender(),
      'VeChain' => VetSender(),
      'MultiversX' => EgldSender(),
      'Hedera' => HbarSender(),
      'Starknet' => StrkSender(),
      // Fallback: attempt EVM for unknown EVM-like chains
      _ => _fallbackSender(coinType, blockchainType),
    };
  }

  ChainSender _fallbackSender(String coinType, String blockchainType) {
    // Some chains have blockchainType that is just their coin symbol
    // (e.g., EOSIO, Waves, Neo, etc.) — return a stub for unimplemented ones.
    return _UnsupportedSender(
      'Transfer not supported for $coinType (blockchainType: $blockchainType)',
    );
  }
}

/// Sender for chains that are not yet implemented.
class _UnsupportedSender implements ChainSender {
  final String _message;
  const _UnsupportedSender(this._message);

  @override
  Future<SendResult> send(SendParams params) async => SendResult.fail(_message);
}
