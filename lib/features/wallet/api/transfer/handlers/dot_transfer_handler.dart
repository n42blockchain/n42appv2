// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../transfer_handler.dart';
import 'base_transfer_handler.dart';

/// Transfer handler for Polkadot ecosystem chains
///
/// Supports: DOT, KSM
class DotTransferHandler extends BaseTransferHandler {
  final String _chainSymbol;

  DotTransferHandler([this._chainSymbol = 'DOT']);

  @override
  String get chainSymbol => _chainSymbol;

  /// Set of supported Polkadot ecosystem chain symbols
  static const Set<String> supportedChains = {'DOT', 'KSM'};

  @override
  bool supports(String chainSymbol) =>
      supportedChains.contains(chainSymbol.toUpperCase());

  @override
  Future<MessageModel> transfer(TransferParams params) async {
    final chainMap = params.chainMap ?? getChainMap(params.chainSymbol);
    if (chainMap == null) {
      return createError('${params.chainSymbol} chain map not found');
    }

    final baseInfo = chainMap['baseInfo'] as Map<String, dynamic>;
    final int decimals = baseInfo['decimals'] ?? 10;
    final String path = baseInfo['path'] is Map
        ? baseInfo['path'][chainMap['addrType']] ?? ''
        : baseInfo['path']?.toString() ?? '';
    final String coinType = params.chainSymbol.toUpperCase();

    return transferApi.transferDot(
      params.fromAddress,
      params.toAddress,
      params.value,
      decimals,
      path,
      coinType,
      contractAddress: params.contractAddress,
      tokenDecimals: params.token?['decimals'] ?? 0,
      maxValue: params.maxValue,
      privateKey: params.privateKey,
    );
  }

  @override
  Future<GasEstimation> estimateGas(TransferParams params) async =>
      estimateGasSimple(
        blockchainType: BlockchainType.Polkadot.name,
        coinType: CoinType.DOT.name,
        isTest: params.isTest,
      );
}
