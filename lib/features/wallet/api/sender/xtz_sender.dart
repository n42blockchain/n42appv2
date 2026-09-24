// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xtz_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// Tezos sender.
class XtzSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final xtzApi = XtzApi();

    // Get balance
    final mmb =
        await _tokenViewApi.getBalance(
          BlockchainType.Tezos.name,
          CoinType.XTZ.name,
          params.fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('XTZ'));
    }

    // Get gas price
    final mmg =
        await _tokenViewApi.getGasPrice(
          BlockchainType.Tezos.name,
          CoinType.XTZ.name,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    final gas = getCoinGas(CoinType.XTZ.name, contract: false);
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice = ethToWeiString(
      params.amountDecimalString,
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGasPrice >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('XTZ'));
      }
      valuePrice = valuePrice - totalGasPrice;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        totalGasPrice + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('XTZ'));
    }

    // Get counter and branch
    final mmCounter = await xtzApi.getCounterXtz(
      params.fromAddress,
      params.isTest,
    );
    if (mmCounter.error) return SendResult.fail(mmCounter.data?.toString());

    final mmBranch = await xtzApi.getBranchXgz(params.isTest);
    if (mmBranch.error) return SendResult.fail(mmBranch.data?.toString());

    final mmReveal = await xtzApi.getBalanceXtz(
      params.fromAddress,
      '',
      'revealed',
      params.isTest,
    );
    if (mmReveal.error) return SendResult.fail(mmReveal.data?.toString());

    final signMap = <String, dynamic>{
      'amount': valuePrice.toInt(),
      'toAddress': params.toAddress,
      'fee': 500,
      'counter': int.parse(mmCounter.data.toString()) + 1,
      'gasLimit': 1101,
      'storageLimit': 257,
      'reveal': mmReveal.data,
      'contractAddres': '',
      'branch': mmBranch.data.toString(),
    };

    final wi = globalWapAdapter.walletInfo;
    String signStr;
    if (!AppGlobals.appContext.mounted) {
      return const SendResult.fail('Context is no longer valid');
    }
    signStr = await _trustdart.signTransaction(
      CoinType.XTZ.name,
      params.path,
      signMap,
      mnemonic: params.privateKey == null ? (wi.mnemonic ?? '') : '',
      pk: params.privateKey ?? wi.privateKey ?? '',
    );

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: CoinType.XTZ.name,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    final sendMm = await xtzApi.sendTxXtz(signStr, params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
