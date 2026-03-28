// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Solana chain
class SolTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'SOL';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'SOL';

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('SOL chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>?;
    if (baseInfo == null) return createError('SOL baseInfo not found');
    final int decimals = baseInfo['decimals'] ?? 9;
    final int pathIndex = chainMap['pathIndex'] ?? 0;
    final String path = baseInfo['path'] is Map
        ? getPathWithIndex(baseInfo['path'][chainMap['addrType']] ?? '', pathIndex)
        : '';
    final int tokenDecimals = params.token?['decimals'] ?? 0;

    return transferApi.transferSol(
      chainMap,
      params.fromAddress,
      params.toAddress,
      params.value,
      decimals,
      path,
      contractAddress: params.contractAddress,
      tokenDecimals: tokenDecimals,
      maxValue: params.maxValue,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.Solana.name,
        coinType: CoinType.SOL.name,
        hasContract: params.contractAddress.isNotEmpty,
        isTest: params.isTest,
      );
}
