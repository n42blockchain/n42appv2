// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:math';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/vet_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// VeChain (VET) sender.
class VetSender implements ChainSender {
  final _trustdart = Trustdart();
  final _dataUtils = DataUtils();

  @override
  Future<SendResult> send(SendParams params) async {
    final vetApi = VetApi();

    // Get account balance
    final mmAccount = await vetApi.getAccount(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (mmAccount.error) return SendResult.fail(mmAccount.data?.toString());
    final accountData = mmAccount.data as Map<String, dynamic>;

    // VET balance is in hex (wei)
    final balanceHex = accountData['balance']?.toString() ?? '0x0';
    final chainBalance = _dataUtils.hexToBigInt(
      balanceHex.startsWith('0x') ? balanceHex.substring(2) : balanceHex,
    );

    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('VET'));
    }

    // Get best block for blockRef
    final mmBlock = await vetApi.getBestBlock(isTest: params.isTest);
    if (mmBlock.error) return SendResult.fail(mmBlock.data?.toString());
    final blockData = mmBlock.data as Map<String, dynamic>;
    final blockId = blockData['id']?.toString() ?? '0x0000000000000000';
    // blockRef = first 8 bytes of block id
    final blockRef = blockId.length >= 18 ? blockId.substring(0, 18) : blockId;

    const int gasLimit = 21000;
    // VTHO cost = gasLimit * gasPriceCoef. At coef=0, minimal cost from energy.
    // For native VET transfer, no explicit fee from VET balance (paid in VTHO).
    BigInt valuePrice = ethToWeiString(
      params.amountDecimalString,
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('VET'));
    }

    if (valuePrice == chainBalance && params.sendMax) {
      // VET transfer fee is in VTHO, not VET — so max = full balance
      // Just use exact balance
    }

    final valueHex = _dataUtils.bigIntToHex(valuePrice, need0x: true);

    final signMap = <String, dynamic>{
      'toAddress': params.toAddress,
      'amount': valueHex,
      'gas': gasLimit,
      'chainTag': params.isTest ? 0x27 : 0x4a, // 0x4a = mainnet, 0x27 = testnet
      'blockRef': blockRef,
      'expiration': 32,
      'clauses': [
        {'to': params.toAddress, 'value': valueHex, 'data': '0x'},
      ],
      'gasPriceCoef': 0,
      'nonce': Random().nextInt(0xFFFFFFFF),
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.VET.name,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.VET.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final sendMm = await vetApi.sendTransaction(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());

    final txId =
        (sendMm.data as Map<String, dynamic>?)?['id']?.toString() ??
        sendMm.data?.toString();
    return SendResult.ok(txId, actualAmount: adjustedAmount);
  }
}
