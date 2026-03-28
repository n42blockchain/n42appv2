// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/models/message_model.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Zilliqa chain
///
/// ZIL transfers require pre-computed parameters (gas, nonce) obtained
/// through the full UI flow (TransferApi.transferWallet -> transferZilSend).
/// Direct transfer() is not supported; use transferFromModel() instead.
class ZilTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'ZIL';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'ZIL';

  @override
  Future<MessageModel> transfer(TransferParams params) =>
      notYetMigrated();

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.Zilliqa.name,
        coinType: CoinType.ZIL.name,
        isTest: params.isTest,
      );
}
