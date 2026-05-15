// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/zil_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// Zilliqa sender.
class ZilSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType.toUpperCase();
    final isContract = params.contractAddress.isNotEmpty;
    final gas = getCoinGas(coinType, contract: isContract);
    final zilApi = ZilApi(isTest: params.isTest);

    // Get balance
    final mmb = await _tokenViewApi.getBalance(
      BlockchainType.Zilliqa.name,
      CoinType.ZIL.name,
      params.fromAddress,
      isTest: false,
    ) ?? MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get gas price
    final mmg = await _tokenViewApi.getGasPrice(
      BlockchainType.Zilliqa.name,
      CoinType.ZIL.name,
      isTest: false,
    ) ?? MessageModel.error();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice = ethToWeiString(params.amount.toString(), params.decimals);
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGasPrice >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5(coinType));
      }
      valuePrice = valuePrice - totalGasPrice;
      adjustedAmount = toEther(valuePrice.toString(), params.decimals).toDouble();
    }
    if (valuePrice <= BigInt.zero || totalGasPrice + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get chain state
    final networkIdMM = await zilApi.getNetworkId();
    if (networkIdMM.error) return SendResult.fail(networkIdMM.data?.toString());

    final latestBlockMM = await zilApi.getLatestTxBlock();
    if (latestBlockMM.error) return SendResult.fail(latestBlockMM.data?.toString());
    final version = (latestBlockMM.data as Map<String, dynamic>)['header']['Version'] as int;

    final balanceMM = await zilApi.getBalance(params.fromAddress, nonce: true);
    int nonce = 0;
    if (balanceMM.error) {
      final errStr = balanceMM.data.toString();
      if (!errStr.contains('not found') && !errStr.contains('-5')) {
        return SendResult.fail(errStr);
      }
    } else {
      nonce = ((balanceMM.data as Map<String, dynamic>)['nonce'] as int? ?? 0) + 1;
    }

    final signMap = <String, dynamic>{
      'version': version,
      'nonce': nonce,
      'toAddress': params.toAddress,
      'amount': _dataUtils.bigIntToHex(valuePrice, need0x: false),
      'gasPrice': _dataUtils.bigIntToHex(gasPrice, need0x: false),
      'gasLimit': gas.toString(),
      'code': '',
      'data': '',
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
        coinType, params.path, signMap, pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final Map<String, dynamic> signedData = json.decode(signStr) as Map<String, dynamic>;
    final txParams = <String, dynamic>{
      'version': signedData['version'],
      'nonce': signedData['nonce'],
      'toAddr': signedData['toAddr'],
      'amount': signedData['amount'],
      'pubKey': signedData['pubKey'],
      'gasPrice': signedData['gasPrice'],
      'gasLimit': signedData['gasLimit'],
      'code': signedData['code'] ?? '',
      'data': signedData['data'] ?? '',
      'signature': signedData['signature'],
    };

    final sendMm = await zilApi.createTransaction(txParams);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
