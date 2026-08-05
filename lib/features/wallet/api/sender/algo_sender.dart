// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/algo_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:web3dart/web3dart.dart';

import 'chain_sender.dart';

/// Algorand sender.
class AlgoSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final algoApi = AlgoApi();

    // Get balance
    final mmb =
        await _tokenViewApi.getBalance(
          BlockchainType.Algorand.name,
          CoinType.ALGO.name,
          params.fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('ALGO'));
    }

    // Get gas price from transaction params
    final mminfo = await algoApi.getTransactionsParams(isTest: params.isTest);
    if (mminfo.error) return SendResult.fail(mminfo.data?.toString());
    final txParams = mminfo.data as Map<String, dynamic>;
    final minFee = BigInt.from(txParams['min-fee'] as int);
    final gas = getCoinGas(CoinType.ALGO.name, contract: false);
    final totalGasPrice = minFee * BigInt.from(gas);

    BigInt valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGasPrice >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('ALGO'));
      }
      valuePrice = valuePrice - totalGasPrice;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        totalGasPrice + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('ALGO'));
    }

    final txData = <String, dynamic>{
      'type': params.contractAddress.isEmpty ? 'ALGO' : 'TOKEN',
      'toAddress': params.toAddress,
      'amount': valuePrice.toString(),
      'assetId': params.contractAddress,
      'fee': txParams['min-fee'],
      'genesisId': txParams['genesis-id'],
      'genesisHash': txParams['genesis-hash'],
      'round': txParams['last-round'],
    };

    Map<dynamic, dynamic> rValue;
    if (params.privateKey != null) {
      rValue = await _trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        params.path,
        txData,
        pk: params.privateKey!,
      );
    } else {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      rValue = await _trustdart.signTransactionByteArray(
        CoinType.ALGO.name,
        params.path,
        txData,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    }

    if (rValue['result'] != true) {
      return SendResult.fail(S.current.g_key_wallet_m6);
    }
    final Uint8List signBytes = hexToBytes(rValue['signHash'] as String);

    final sendMm =
        await _tokenViewApi.sendTx(
          BlockchainType.Algorand.name,
          CoinType.ALGO.name,
          signBytes,
          netMode: params.isTest ? 'test' : 'main',
        ) ??
        MessageModel.error();

    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
