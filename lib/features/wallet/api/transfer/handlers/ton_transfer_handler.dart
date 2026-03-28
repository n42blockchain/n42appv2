// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for TON (The Open Network) chain
class TonTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'TON';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'TON';

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    // TON doesn't have a standalone transferTon() method in the legacy API.
    // Use the high-level TransferApi.transfer() which routes through the
    // switch-case and handles TON via the Cosmos-family mixin path.
    return transferApi.transfer(
      params.chainSymbol,
      params.toAddress,
      params.value,
      contractAddress: params.contractAddress,
      fromAddress: params.fromAddress,
      isTest: params.isTest,
      maxValue: params.maxValue,
      message: params.message,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.TheOpenNetwork.name,
        coinType: CoinType.TON.name,
        isTest: params.isTest,
      );
}
