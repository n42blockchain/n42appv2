// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/sui_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';
import 'sui_transaction_message.dart';
import '../../pages/send/sui_amount_utils.dart';

/// Sui chain sender.
class SuiSender implements ChainSender {
  final Trustdart _trustdart;
  final SuiApi Function(bool) _apiFactory;
  bool _sending = false;

  SuiSender({Trustdart? trustdart, SuiApi Function(bool)? apiFactory})
    : _trustdart = trustdart ?? Trustdart(),
      _apiFactory = apiFactory ?? ((isTest) => SuiApi(isTest: isTest));

  @override
  Future<SendResult> send(SendParams params) async {
    if (_sending) return const SendResult.fail('A transfer is already pending');
    _sending = true;
    try {
      return await _send(params);
    } catch (_) {
      return const SendResult.fail('Unable to prepare or send Sui transfer');
    } finally {
      _sending = false;
    }
  }

  Future<SendResult> _send(SendParams params) async {
    if (params.contractAddress.isNotEmpty) {
      return const SendResult.fail(
        'Sui token transfers require a token-specific transaction',
      );
    }
    if (params.decimals != 9) {
      return const SendResult.fail('Invalid Sui decimals');
    }
    final maxU64 = (BigInt.one << 64) - BigInt.one;
    var valuePrice =
        params.valueWeiOverride ??
        suiAmountToBaseUnits(params.amountDecimalString, params.decimals);
    if (valuePrice == null ||
        valuePrice <= BigInt.zero ||
        valuePrice > maxU64) {
      return const SendResult.fail('Invalid Sui transfer amount');
    }
    final suiApi = _apiFactory(params.isTest);

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
    if (gasPrice <= BigInt.zero || gasPrice > maxU64) {
      return const SendResult.fail('Invalid Sui reference gas price');
    }
    final totalGas = suiTransferGasBudget;

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

    if (ownedObjects.isEmpty) {
      return const SendResult.fail('No spendable Sui coins');
    }
    final signMap = <String, dynamic>{
      'type': 'SUI_TRANSFER',
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'fromAddress': params.fromAddress,
      'gasBudget': totalGas.toString(),
      'referenceGasPrice': gasPrice.toString(),
      'utxo': ownedObjects.map((o) {
        final data = (o as Map)['data'] as Map;
        return {
          'objectId': data['objectId'],
          'version': data['version'],
          'objectDigest': data['digest'],
        };
      }).toList(),
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

    final signed = SuiSignedTransaction.parse(signStr);
    if (signed == null) {
      return const SendResult.fail('Invalid Sui signing output');
    }
    final sendMm = await suiApi.submit(signed.transaction, signed.signature);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());

    final txHash = _extractSuiTxHash(sendMm.data);
    if (txHash == null || txHash.isEmpty) {
      return const SendResult.fail('Missing Sui transaction digest');
    }
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
