// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/dot_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';

import 'chain_sender.dart';

/// Polkadot / Kusama sender.
class DotSender implements ChainSender {
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType.toUpperCase();
    final gas = getCoinGas(
      coinType,
      contract: params.contractAddress.isNotEmpty,
    );
    final dotApi = DotApi();

    // Get balance
    final mm = await dotApi.getTokens(
      params.fromAddress,
      coinType,
      isTest: false,
    );
    if (mm.error) return SendResult.fail(mm.data?.toString());
    final chainBalance = mm.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Fixed gas estimate (DOT/KSM)
    final gasPrice = BigInt.from(10000000); // 0.01 DOT in planck
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGasPrice >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
      valuePrice = valuePrice - totalGasPrice;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        totalGasPrice + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get chain data
    final genesisHash = await dotApi.getGenesisHash(
      index: 0,
      isTest: params.isTest,
    );
    if (genesisHash.error) return SendResult.fail(genesisHash.data?.toString());

    final nonce = await dotApi.getNonce(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (nonce.error) return SendResult.fail(nonce.data?.toString());

    final runtimeVersion = await dotApi.getRuntimeVersion(
      isTest: params.isTest,
    );
    if (runtimeVersion.error)
      return SendResult.fail(runtimeVersion.data?.toString());

    final blockHash = await dotApi.getGenesisHash(isTest: params.isTest);
    if (blockHash.error) return SendResult.fail(blockHash.data?.toString());

    final blockNumber = await dotApi.getChainHeader(isTest: params.isTest);
    if (blockNumber.error) return SendResult.fail(blockNumber.data?.toString());

    final signMap = <String, dynamic>{
      'amount': _dataUtils.bigIntToHex(valuePrice, need0x: true),
      'toAddress': params.toAddress,
      'genesisHash': genesisHash.data,
      'blockHash': blockHash.data,
      'nonce': nonce.data,
      'specVersion':
          (runtimeVersion.data as Map<String, dynamic>)['specVersion'],
      'transactionVersion':
          (runtimeVersion.data as Map<String, dynamic>)['transactionVersion'],
      'blockNumber': _dataUtils
          .hexToBigInt((blockNumber.data as Map<String, dynamic>)['number'])
          .toInt(),
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        coinType,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        coinType,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final sendMm = await dotApi.submitTxHash(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
