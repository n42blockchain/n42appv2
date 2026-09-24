// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// Hedera (HBAR) sender.
class HbarSender implements ChainSender {
  final _trustdart = Trustdart();

  static const _header = {'Content-Type': 'application/json'};

  String _mirrorNodeBase(bool isTest) => isTest
      ? 'https://testnet.mirrornode.hedera.com'
      : 'https://mainnet.mirrornode.hedera.com';

  @override
  Future<SendResult> send(SendParams params) async {
    final mirrorBase = _mirrorNodeBase(params.isTest);

    // Get account info from Mirror Node
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$mirrorBase/api/v1/accounts/${params.fromAddress}',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      final accountData = data as Map<String, dynamic>;
      final balanceTinybars = (accountData['balance']?['balance'] as int?) ?? 0;
      final chainBalance = BigInt.from(balanceTinybars);

      if (chainBalance == BigInt.zero) {
        return SendResult.fail(S.current.g_key_wallet_m5('HBAR'));
      }

      // Fixed fee: 1 HBAR = 100,000,000 tinybars; ~0.01 HBAR fee
      const int feeTinybars = 1000000; // 0.01 HBAR

      // 1 HBAR = 1e8 tinybars
      BigInt valuePrice = ethToWeiString(
        params.amountDecimalString,
        params.decimals,
      );
      double adjustedAmount = params.amount;

      if (valuePrice == chainBalance && params.sendMax) {
        final feeBig = BigInt.from(feeTinybars);
        if (feeBig >= valuePrice) {
          return SendResult.fail(S.current.g_key_wallet_m5('HBAR'));
        }
        valuePrice = valuePrice - feeBig;
        adjustedAmount = toEther(
          valuePrice.toString(),
          params.decimals,
        ).toDouble();
      }
      if (valuePrice <= BigInt.zero ||
          BigInt.from(feeTinybars) + valuePrice > chainBalance) {
        return SendResult.fail(S.current.g_key_wallet_m5('HBAR'));
      }

      final validStartNanos = DateTime.now().microsecondsSinceEpoch * 1000;

      final signMap = <String, dynamic>{
        'toAccount': params.toAddress,
        'amount': valuePrice.toString(),
        'memo': params.memo ?? '',
        'validStartNanos': validStartNanos,
        'isTest': params.isTest,
      };

      String signStr;
      if (params.privateKey == null) {
        if (!AppGlobals.appContext.mounted) {
          return const SendResult.fail('Context is no longer valid');
        }
        signStr = await _trustdart.signTransaction(
          CoinType.HBAR.name,
          params.path,
          signMap,
          mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
        );
      } else {
        signStr = await _trustdart.signTransaction(
          CoinType.HBAR.name,
          params.path,
          signMap,
          pk: params.privateKey!,
        );
      }

      if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

      // Broadcast via Hedera REST API
      final restBase = params.isTest
          ? 'https://testnet.hedera.com'
          : 'https://mainnet.hedera.com';
      final resp = await BaseApi.requestEmptyH.post(
        '$restBase/api/v1/transactions',
        params: {},
        data: signStr,
        defaultReturn: false,
        header: _header,
        enableRetry: false,
      );
      final txId = (resp as Map<String, dynamic>)['transaction_id']?.toString();
      if (txId == null || txId.isEmpty) {
        return SendResult.fail(
          resp['message']?.toString() ?? 'Broadcast failed',
        );
      }
      return SendResult.ok(txId, actualAmount: adjustedAmount);
    } catch (e) {
      return SendResult.fail(e.toString());
    }
  }
}
