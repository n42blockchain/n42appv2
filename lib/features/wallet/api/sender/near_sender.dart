// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// NEAR Protocol sender.
class NearSender implements ChainSender {
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final nearApi = NearApi(isTest: params.isTest);

    // Get balance
    final mmb = await nearApi.getBalance(params.fromAddress);
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
    }

    // Get gas price
    final mmg = await nearApi.getGasPrice();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    final gasUnits = BigInt.from(
      300000000000000,
    ); // 30 TGas for simple transfer
    final totalGas = gasPrice * gasUnits;

    BigInt valuePrice = ethToWeiString(
      params.amountDecimalString,
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGas >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
      }
      valuePrice = valuePrice - totalGas;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero || totalGas + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
    }

    // Get block hash for transaction
    final mmblock = await nearApi.getLatestBlockHash();
    if (mmblock.error) return SendResult.fail(mmblock.data?.toString());
    final blockData = mmblock.data as Map<String, dynamic>;
    final blockHash = blockData['hash'] as String;

    // Get nonce via access key — 公钥必须由「将用于签名的同一把密钥」派生。
    // 否则传入 params.privateKey（指定账户）时，公钥/nonce 取自活跃钱包而签名用
    // 另一账户 → 账户错配（与签名账户一致性 bug 同族）。仅在未传私钥时才读活跃钱包。
    final String signingMnemonic;
    final String signingPk;
    if (params.privateKey != null) {
      signingMnemonic = '';
      signingPk = params.privateKey!;
    } else {
      final wi = globalWapAdapter.walletInfo;
      signingMnemonic = wi.mnemonic ?? '';
      signingPk = wi.privateKey ?? '';
    }
    final pubKeyMm = await _trustdart.generateAddress(
      CoinType.NEAR.name,
      params.path,
      'legacy',
      mnemonic: signingMnemonic,
      pk: signingPk,
    );
    final publicKey =
        pubKeyMm['publicKey']?.toString() ??
        pubKeyMm['legacy']?.toString() ??
        '';

    int nonce = 0;
    if (publicKey.isNotEmpty) {
      final mmKey = await nearApi.getAccessKey(
        params.fromAddress,
        'ed25519:$publicKey',
      );
      if (!mmKey.error) {
        nonce =
            ((mmKey.data as Map<String, dynamic>)['nonce'] as int? ?? 0) + 1;
      }
    }

    final signMap = <String, dynamic>{
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'nonce': nonce,
      'blockHash': blockHash,
      'fromAddress': params.fromAddress,
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.NEAR.name,
        params.path,
        signMap,
        mnemonic: signingMnemonic,
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.NEAR.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final sendMm = await nearApi.sendTransaction(signStr);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
