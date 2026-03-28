// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/models/message_model.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Filecoin chain
///
/// FIL transfers require pre-computed nonce, gasLimit, gasFeeCap, and
/// gasPremium which are obtained through the full UI flow
/// (TransferApi.transferWallet -> transferFilSend). Direct transfer()
/// is not supported; use transferFromModel() instead.
class FilTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'FIL';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'FIL';

  @override
  Future<MessageModel> transfer(TransferParams params) =>
      notYetMigrated();

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.Filecoin.name,
        coinType: CoinType.FIL.name,
        isTest: params.isTest,
      );
}
