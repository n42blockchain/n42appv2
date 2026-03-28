// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Bitcoin and UTXO-based chains
///
/// Supports: BTC, LTC, DOGE, BCH, DASH, ZEC, DGB, RVN
class BtcTransferHandler extends BaseTransferHandler {
  final String _chainSymbol;

  BtcTransferHandler([this._chainSymbol = 'BTC']);

  @override
  String get chainSymbol => _chainSymbol;

  /// Set of supported UTXO-based chain symbols
  static const Set<String> supportedChains = {
    'BTC', 'LTC', 'DOGE', 'BCH', 'DASH', 'ZEC', 'DGB', 'RVN',
  };

  @override
  bool supports(String chainSymbol) =>
      supportedChains.contains(chainSymbol.toUpperCase());

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('${params.chainSymbol} chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>;
    final String path = baseInfo['path'] is Map
        ? baseInfo['path'][chainMap['addrType']] ?? ''
        : baseInfo['path']?.toString() ?? '';
    final String coinType = params.chainSymbol.toUpperCase();
    final String fromAddress =
        processAddress(params.fromAddress, coinType);

    return transferApi.transferBtc(
      coinType,
      fromAddress,
      params.toAddress,
      params.value,
      path,
      maxValue: params.maxValue,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    final coinType = params.chainSymbol.toUpperCase();
    // BTC-family uses dynamic fee from UTXO calculation;
    // getCoinGas provides a base fee rate estimate.
    final gasLimit = BigInt.from(getCoinGas(coinType, contract: false));

    // Bitcoin has no getGasPrice endpoint; return the base fee rate
    // as both gasPrice and totalFee so callers have a rough estimate.
    return GasEstimation(
      gasLimit: gasLimit,
      gasPrice: gasLimit,
      totalFee: gasLimit,
    );
  }
}
