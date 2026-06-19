// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/core/providers/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import 'chain_sender.dart';

/// MultiversX (EGLD) sender.
class EgldSender implements ChainSender {
  final _trustdart = Trustdart();

  static const _mainnetUrl = 'https://api.multiversx.com';
  static const _testnetUrl = 'https://testnet-api.multiversx.com';
  static const _header = {'Content-Type': 'application/json'};

  String _base(bool isTest) => isTest ? _testnetUrl : _mainnetUrl;

  @override
  Future<SendResult> send(SendParams params) async {
    final base = _base(params.isTest);

    // Get account info (nonce + balance)
    MessageModel mmAccount;
    try {
      final data = await BaseApi.requestEmptyH.get(
        '$base/accounts/${params.fromAddress}',
        params: {},
        defaultReturn: false,
        header: _header,
      );
      mmAccount = MessageModel()..data = data;
    } catch (e) {
      return SendResult.fail(e.toString());
    }

    final accountData = mmAccount.data as Map<String, dynamic>;
    final nonce = accountData['nonce'] as int? ?? 0;
    final balanceStr = accountData['balance']?.toString() ?? '0';
    final chainBalance = BigInt.tryParse(balanceStr) ?? BigInt.zero;

    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('EGLD'));
    }

    const int gasLimit = 50000;
    const int gasPrice = 1000000000;
    final totalGas = BigInt.from(gasLimit) * BigInt.from(gasPrice);

    BigInt valuePrice = ethToWeiString(
      params.amount.toString(),
      params.decimals,
    );
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      if (totalGas >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('EGLD'));
      }
      valuePrice = valuePrice - totalGas;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero || totalGas + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('EGLD'));
    }

    final signMap = <String, dynamic>{
      'nonce': nonce,
      'value': valuePrice.toString(),
      'receiver': params.toAddress,
      'gasLimit': gasLimit,
      'gasPrice': gasPrice,
      'chainID': params.isTest ? 'T' : '1',
      'version': 1,
      'data': params.memo ?? '',
    };

    String signStr;
    if (params.privateKey == null) {
      if (!AppGlobals.appContext.mounted) {
        return const SendResult.fail('Context is no longer valid');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.EGLD.name,
        params.path,
        signMap,
        mnemonic: globalWapAdapter.walletInfo.mnemonic ?? '',
      );
    } else {
      signStr = await _trustdart.signTransaction(
        CoinType.EGLD.name,
        params.path,
        signMap,
        pk: params.privateKey!,
      );
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    // Broadcast
    try {
      final data = await BaseApi.requestEmptyH.post(
        '$base/transactions',
        params: {},
        data: signStr,
        defaultReturn: false,
        header: _header,
        enableRetry: false,
      );
      final txHash = (data as Map<String, dynamic>)['txHash']?.toString();
      if (txHash == null || txHash.isEmpty) {
        return SendResult.fail(data['error']?.toString() ?? 'Broadcast failed');
      }
      return SendResult.ok(txHash, actualAmount: adjustedAmount);
    } catch (e) {
      return SendResult.fail(e.toString());
    }
  }
}
