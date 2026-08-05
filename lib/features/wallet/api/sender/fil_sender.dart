// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/fil_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// Filecoin sender.
class FilSender implements ChainSender {
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final filApi = FilApi();

    // Get balance
    final mmb = await filApi.getBalance(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('FIL'));
    }

    // Get gas params
    final mmNonce = await filApi.getNonce(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (mmNonce.error) return SendResult.fail(mmNonce.data?.toString());
    final nonce = mmNonce.data.toString();

    final valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    );

    final mmGas = await filApi.getGasLimit(
      params.fromAddress,
      params.toAddress,
      valuePrice,
      isTest: params.isTest,
    );
    if (mmGas.error) return SendResult.fail(mmGas.data?.toString());
    final gasData = mmGas.data as Map<String, dynamic>;
    final gasLimit = gasData['GasLimit']?.toString() ?? '0';
    final gasFeeCap = gasData['GasFeeCap']?.toString() ?? '0';
    final gasPremium = gasData['GasPremium']?.toString() ?? '0';

    // totalGasPrice estimate for balance check
    final gasLimitInt = int.tryParse(gasLimit) ?? 0;
    final gasFeeCapBig = BigInt.tryParse(gasFeeCap) ?? BigInt.zero;
    final totalGas = gasFeeCapBig * BigInt.from(gasLimitInt);

    BigInt sendValue = valuePrice;
    double adjustedAmount = params.amount;
    if (sendValue == chainBalance && params.sendMax) {
      if (totalGas >= sendValue) {
        return SendResult.fail(S.current.g_key_wallet_m5('FIL'));
      }
      sendValue = sendValue - totalGas;
      adjustedAmount = toEther(
        sendValue.toString(),
        params.decimals,
      ).toDouble();
    }
    if (sendValue <= BigInt.zero || totalGas + sendValue > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('FIL'));
    }

    final signMap = <String, dynamic>{
      'amount': _dataUtils.bigIntToHex(sendValue, need0x: false),
      'toAddress': params.toAddress,
      'nonce': nonce,
      'gasLimit': gasLimit,
      'gasFeeCap': _dataUtils.bigIntToHex(
        BigInt.parse(gasFeeCap),
        need0x: false,
      ),
      'gasPremium': _dataUtils.bigIntToHex(
        BigInt.parse(gasPremium),
        need0x: false,
      ),
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.FIL.name,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.FIL.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: CoinType.FIL.name,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    final sendMm = await filApi.sendTx(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
