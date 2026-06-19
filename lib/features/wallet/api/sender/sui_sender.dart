// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// Sui chain sender.
class SuiSender implements ChainSender {
  final _trustdart = Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final suiApi = SuiApi(isTest: params.isTest);

    // Get balance
    final mmb = await suiApi.getBalanceSui(params.fromAddress);
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final chainBalance = mmb.data as BigInt;
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('SUI'));
    }

    // Get gas price
    final mmg = await suiApi.getGasPriceSui();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    final gasLimit = BigInt.from(2000000); // 2M MIST budget
    final totalGas = gasPrice * gasLimit;

    BigInt valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGas >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('SUI'));
      }
      valuePrice = valuePrice - totalGas;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero || totalGas + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('SUI'));
    }

    // Get owned objects (coins) for gas
    final ownedObjects = await suiApi.getOwnedObjects(params.fromAddress);

    final signMap = <String, dynamic>{
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'fromAddress': params.fromAddress,
      'gasBudget': totalGas.toString(),
      'gasPrice': gasPrice.toString(),
      'coins': ownedObjects
          .map((o) => (o as Map<String, dynamic>)['data']?['objectId'])
          .toList(),
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.SUI.name,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.SUI.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // SUI needs transactionBlock + signature separately
    // The trustdart returns "txBlock|signature" format
    String txBlock;
    String sig;
    if (signStr.contains('|')) {
      final parts = signStr.split('|');
      txBlock = parts[0];
      sig = parts[1];
    } else {
      txBlock = signStr;
      sig = signStr;
    }

    final sendMm = await suiApi.submit(txBlock, sig);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());

    final txHash = _extractSuiTxHash(sendMm.data);
    return SendResult.ok(txHash, actualAmount: adjustedAmount);
  }

  String? _extractSuiTxHash(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      return data['digest']?.toString() ??
          (data['effects'] as Map?)?['transactionDigest']?.toString();
    }
    return null;
  }
}
