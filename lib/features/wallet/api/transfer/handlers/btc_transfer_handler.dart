// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/models/message_model.dart';
import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Bitcoin and UTXO-based chains
///
/// Supports: BTC, LTC, DOGE, BCH, DASH, ZEC, DGB, RVN
// Active implementation: see transfer_api.dart for the working transfer methods
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
  // TODO: Migrate from transfer_api.dart transferBtc method
  Future<MessageModel> transfer(TransferParams params) => notYetMigrated();

  @override
  // TODO: Implement gas estimation for UTXO chains
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      notImplementedGas();
}
