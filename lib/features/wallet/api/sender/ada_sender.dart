// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/ada_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// Cardano (ADA) sender — uses Blockfrost API.
class AdaSender implements ChainSender {
  final _trustdart = Trustdart();

  /// Blockfrost project_id — obtained from chain config or environment.
  static const _projectId = String.fromEnvironment(
    'BLOCKFROST_PROJECT_ID',
    defaultValue: '',
  );

  @override
  Future<SendResult> send(SendParams params) async {
    if (_projectId.isEmpty) {
      return const SendResult.fail('ADA: Blockfrost project_id not configured');
    }
    final adaApi = AdaApi(projectId: _projectId);

    // Get address info (lovelace balance)
    final mmAddr = await adaApi.getAddressInfo(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (mmAddr.error) return SendResult.fail(mmAddr.data?.toString());
    final addrData = mmAddr.data as Map<String, dynamic>;

    // Extract ADA balance from amounts list
    BigInt chainBalance = BigInt.zero;
    final amounts = addrData['amount'] as List<dynamic>? ?? [];
    for (final a in amounts) {
      final aMap = a as Map<String, dynamic>;
      if (aMap['unit'] == 'lovelace') {
        chainBalance = BigInt.parse(aMap['quantity']?.toString() ?? '0');
        break;
      }
    }

    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('ADA'));
    }

    // Get UTxOs
    final mmUtxos = await adaApi.getAddressUtxos(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (mmUtxos.error) return SendResult.fail(mmUtxos.data?.toString());
    final utxos = mmUtxos.data as List<dynamic>;

    // Estimated fee (174000 lovelace minimum fee)
    const int estimatedFee = 174000;
    BigInt valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    ); // decimals=6 for ADA
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      final feeBig = BigInt.from(estimatedFee);
      if (feeBig >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('ADA'));
      }
      valuePrice = valuePrice - feeBig;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        BigInt.from(estimatedFee) + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('ADA'));
    }

    // Build sign map for trustdart
    final utxoList = utxos.map((u) {
      final uMap = u as Map<String, dynamic>;
      return {
        'txHash': uMap['tx_hash'],
        'outputIndex': uMap['output_index'],
        'amount': uMap['amount'],
      };
    }).toList();

    final signMap = <String, dynamic>{
      'utxos': utxoList,
      'toAddress': params.toAddress,
      'amount': valuePrice.toString(),
      'changeAddress': params.fromAddress,
      'fee': estimatedFee,
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.ADA.name,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.ADA.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final sendMm = await adaApi.sendTransaction(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());
    return SendResult.ok(sendMm.data?.toString(), actualAmount: adjustedAmount);
  }
}
