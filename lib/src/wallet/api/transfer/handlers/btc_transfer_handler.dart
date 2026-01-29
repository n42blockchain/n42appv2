// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/models/message_model.dart';
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
    'BTC',
    'LTC',
    'DOGE',
    'BCH',
    'DASH',
    'ZEC',
    'DGB',
    'RVN',
  };

  @override
  bool supports(String chainSymbol) {
    return supportedChains.contains(chainSymbol.toUpperCase());
  }

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    // TODO: Migrate from transfer_api.dart transferBtc method
    return createError('${params.chainSymbol} transfer not yet migrated');
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    // TODO: Implement gas estimation for UTXO chains
    return GasEstimation(
      gasLimit: BigInt.zero,
      gasPrice: BigInt.zero,
      totalFee: BigInt.zero,
      errorMessage: 'Not implemented',
    );
  }
}
