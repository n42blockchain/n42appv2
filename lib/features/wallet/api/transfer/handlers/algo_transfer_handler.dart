// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Algorand chain
class AlgoTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'ALGO';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'ALGO';

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('ALGO chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>?;
    if (baseInfo == null) return createError('ALGO baseInfo not found');
    final int decimals = baseInfo['decimals'] ?? 6;
    final int pathIndex = chainMap['pathIndex'] ?? 0;
    final String path = baseInfo['path'] is Map
        ? getPathWithIndex(baseInfo['path'][chainMap['addrType']] ?? '', pathIndex)
        : '';

    return transferApi.transferAlgo(
      params.fromAddress,
      params.toAddress,
      params.value,
      decimals,
      path,
      maxValue: params.maxValue,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async {
    // ALGO has special gas parsing: min-fee may come as a Map
    final gasLimit = BigInt.from(
      getCoinGas(CoinType.ALGO.name, contract: false),
    );

    final mmg = await tokenViewApi.getGasPrice(
      BlockchainType.Algorand.name,
      CoinType.ALGO.name,
      isTest: params.isTest,
    );

    if (mmg == null || mmg.error) {
      return GasEstimation(
        gasLimit: gasLimit,
        gasPrice: BigInt.zero,
        totalFee: BigInt.zero,
        errorMessage: mmg?.data?.toString() ?? 'Failed to get gas price',
      );
    }

    final BigInt gasPrice =
        mmg.data is Map ? BigInt.from(mmg.data['min-fee']) : mmg.data as BigInt;
    return GasEstimation(
      gasLimit: gasLimit,
      gasPrice: gasPrice,
      totalFee: gasPrice * gasLimit,
    );
  }
}
