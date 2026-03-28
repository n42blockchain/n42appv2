// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/models/message_model.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for XRP Ledger chain
class XrpTransferHandler extends BaseTransferHandler {
  @override
  String get chainSymbol => 'XRP';

  @override
  bool supports(String chainSymbol) => chainSymbol.toUpperCase() == 'XRP';

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('XRP chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>;
    final int decimals = baseInfo['decimals'] ?? 6;
    final String path = baseInfo['path'] is Map
        ? baseInfo['path'][chainMap['addrType']] ?? ''
        : baseInfo['path']?.toString() ?? '';

    return transferApi.transferXrp(
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
        blockchainType: BlockchainType.Ripple.name,
        coinType: CoinType.XRP.name,
        isTest: params.isTest,
      );
}
