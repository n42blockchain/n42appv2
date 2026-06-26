// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xrp_api.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';
import 'package:n42_wallet/features/wallet/utils/validation/signature_validator.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// XRP (Ripple) sender.
class XrpSender implements ChainSender {
  final _tokenViewApi = TokenViewApi();
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final xrpApi = XrpApi();

    // Check destination account activation
    final mmDest = await xrpApi.getAccountInfoXrp(
      params.toAddress,
      params.isTest,
    );
    if (mmDest.error) {
      return SendResult.fail(S.current.g_key_t_45(params.toAddress));
    }
    final isCreate = (mmDest.data as Map<String, dynamic>)['account'] == true;
    if (!isCreate && params.amount < 10) {
      return SendResult.fail(S.current.g_key_t_54);
    }

    // Get balance
    final mmb =
        await _tokenViewApi.getBalance(
          BlockchainType.Ripple.name,
          CoinType.XRP.name,
          params.fromAddress,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('XRP'));
    }

    // Get gas price
    final mmg =
        await _tokenViewApi.getGasPrice(
          BlockchainType.Ripple.name,
          CoinType.XRP.name,
          isTest: false,
        ) ??
        MessageModel.error();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    final gas = getCoinGas(CoinType.XRP.name, contract: false);
    final totalGasPrice = gasPrice * BigInt.from(gas);

    BigInt valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGasPrice >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('XRP'));
      }
      valuePrice = valuePrice - totalGasPrice;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        totalGasPrice + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('XRP'));
    }

    // Get sequence
    final mmSeq = await xrpApi.getAccountInfoXrp(
      params.fromAddress,
      params.isTest,
    );
    if (mmSeq.error) return SendResult.fail(mmSeq.data?.toString());
    final sequence = (mmSeq.data as Map<String, dynamic>)['sequence'] ?? 0;

    // Get ledger index
    final mmLedger = await xrpApi.getLedgerXrp(isTest: params.isTest);
    if (mmLedger.error) return SendResult.fail(mmLedger.data?.toString());
    final ledgerIndex = mmLedger.data;

    final signMap = <String, dynamic>{
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'sequence': sequence,
      'ledgerIndex': ledgerIndex,
      'fee': totalGasPrice.toString(),
      'txType': 'XRP',
      'issuer': '',
      'currency': '',
      if (params.destinationTag != null)
        'destinationTag': params.destinationTag,
    };

    final wi = globalWapAdapter.walletInfo;
    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.XRP.name,
        params.path,
        signMap,
        mnemonic: wi.mnemonic ?? '',
        pk: wi.privateKey ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.XRP.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Validate signature
    final sigResult = SignatureValidator.validateSignedTransaction(
      signedTx: signStr,
      coinType: CoinType.XRP.name,
    );
    if (!sigResult.isValid) {
      return SendResult.fail(
        sigResult.errorMessage ?? 'Signature validation failed',
      );
    }

    final sendMm = await xrpApi.sendTxXrp(signStr, params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
