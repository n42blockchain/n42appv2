// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42appv2/src/models/message_model.dart';
import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Algorand chain
class AlgoTransferHandler extends BaseTransferHandler {
  // Active implementation: see transfer_api.dart for the working transfer methods

  @override
  String get chainSymbol => 'ALGO';

  @override
  bool supports(String chainSymbol) {
    return chainSymbol.toUpperCase() == 'ALGO';
  }

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    // TODO: Migrate from transfer_api.dart transferAlgo method
    return createError('ALGO transfer not yet migrated');
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    // TODO: Implement gas estimation
    return GasEstimation(
      gasLimit: BigInt.zero,
      gasPrice: BigInt.zero,
      totalFee: BigInt.zero,
      errorMessage: 'Not implemented',
    );
  }
}
