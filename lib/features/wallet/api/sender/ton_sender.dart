// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ton_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// TON (The Open Network) sender.
class TonSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final coinType = params.coinType.toUpperCase();
    final isContract = params.contractAddress.isNotEmpty;
    final gas = getCoinGas(coinType, contract: isContract);
    final tonApi = TonApi(isTest: params.isTest);

    // Get balance
    final mmb =
        await _tokenViewApi.getBalance(
          BlockchainType.TheOpenNetwork.name,
          CoinType.TON.name,
          params.fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5(coinType));
    }

    // Get gas price
    final mmg =
        await _tokenViewApi.getGasPrice(
          BlockchainType.TheOpenNetwork.name,
          CoinType.TON.name,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
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

    // Get seqno
    final sequenceNumber = await tonApi.getSeqnoTon(params.fromAddress);
    if (sequenceNumber.error) {
      return SendResult.fail(sequenceNumber.data?.toString());
    }

    final expireAt =
        DateTime.now()
            .add(const Duration(seconds: 60))
            .millisecondsSinceEpoch ~/
        1000;
    final signMap = <String, dynamic>{
      'amount': _dataUtils.bigIntToHex(valuePrice, need0x: false),
      'toAddress': params.toAddress,
      'sequenceNumber': sequenceNumber.data,
      'fromAddress': params.fromAddress,
      'contractAddress': params.contractAddress,
      'maxGasAmount': _dataUtils.bigIntToHex(totalGasPrice, need0x: false),
      'expireAt': expireAt,
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

    final sendMm = await tonApi.submitTon(signStr);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
