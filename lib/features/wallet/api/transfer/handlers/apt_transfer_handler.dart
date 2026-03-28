// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/models/message_model.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Aptos chain
class AptTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'APT';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'APT';

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('APT chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>?;
    if (baseInfo == null) return createError('APT baseInfo not found');
    final int decimals = baseInfo['decimals'] ?? 8;
    final int pathIndex = chainMap['pathIndex'] ?? 0;
    final String path = baseInfo['path'] is Map
        ? getPathWithIndex(baseInfo['path'][chainMap['addrType']] ?? '', pathIndex)
        : '';
    final String coinType = baseInfo['coinType'] ?? CoinType.APT.name;
    final int chainId = params.isTest
        ? (baseInfo['chainId_test'] ?? 2)
        : (baseInfo['chainId'] ?? 1);
    final int tokenDecimals = params.token?['decimals'] ?? 0;

    return transferApi.transferApt(
      params.fromAddress,
      params.toAddress,
      params.value,
      decimals,
      path,
      coinType,
      chainId,
      contractAddress: params.contractAddress,
      tokenDecimals: tokenDecimals,
      maxValue: params.maxValue,
      privateKey: params.privateKey,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.Aptos.name,
        coinType: CoinType.APT.name,
        hasContract: params.contractAddress.isNotEmpty,
        isTest: params.isTest,
      );
}
