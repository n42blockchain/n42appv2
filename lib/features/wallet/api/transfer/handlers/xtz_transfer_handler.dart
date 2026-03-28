// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Tezos chain
class XtzTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'XTZ';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'XTZ';

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('XTZ chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>;
    final int decimals = baseInfo['decimals'] ?? 6;
    final String path = baseInfo['path'] is Map
        ? baseInfo['path'][chainMap['addrType']] ?? ''
        : baseInfo['path']?.toString() ?? '';

    return transferApi.transferXtz(
      params.fromAddress,
      params.toAddress,
      params.value,
      decimals,
      path,
      maxValue: params.maxValue,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.Tezos.name,
        coinType: CoinType.XTZ.name,
        isTest: params.isTest,
      );
}
