// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/xlm_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// Stellar (XLM) sender.
class XlmSender implements ChainSender {
  final Trustdart _trustdart;
  final XlmApi _api;
  final Object? Function() _ownerIdentity;
  final String? Function() _readMnemonic;

  XlmSender({
    Trustdart? trustdart,
    XlmApi? api,
    Object? Function()? ownerIdentity,
    String? Function()? readMnemonic,
  }) : _trustdart = trustdart ?? Trustdart(),
       _api = api ?? XlmApi(),
       _ownerIdentity = ownerIdentity ?? _currentOwner,
       _readMnemonic = readMnemonic ?? _currentMnemonic;

  static Object? _currentOwner() {
    try {
      if (!globalWapAdapter.isWalletReady) return null;
      return (
        AppGlobals.walletStorageUuid,
        AppGlobals.userInfo,
        globalWapAdapter.walletIndex,
        globalWapAdapter.walletInfo,
      );
    } catch (_) {
      return null;
    }
  }

  static String? _currentMnemonic() {
    try {
      return globalWapAdapter.isWalletReady
          ? globalWapAdapter.walletInfo.mnemonic
          : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SendResult> send(SendParams params) async {
    final Object? owner;
    final String? mnemonic;
    try {
      owner = _ownerIdentity();
      mnemonic = params.privateKey == null ? _readMnemonic() : null;
    } catch (_) {
      return const SendResult.fail('Wallet is not ready');
    }
    bool signerIsCurrent() {
      try {
        return _ownerIdentity() == owner &&
            (params.privateKey != null ||
                (owner != null && mnemonic == _readMnemonic()));
      } catch (_) {
        return false;
      }
    }

    if (!signerIsCurrent() ||
        (params.privateKey ?? mnemonic ?? '').trim().isEmpty) {
      return const SendResult.fail('Wallet signing context is unavailable');
    }
    final xlmApi = _api;

    // Get account info (balance + sequence)
    final mmAccount = await xlmApi.getAccount(
      params.fromAddress,
      isTest: params.isTest,
    );
    if (mmAccount.error) return SendResult.fail(mmAccount.data?.toString());
    final accountData = mmAccount.data as Map<String, dynamic>;

    // Extract native XLM balance
    BigInt chainBalance = BigInt.zero;
    final balances = accountData['balances'] as List<dynamic>? ?? [];
    for (final b in balances) {
      final bMap = b as Map<String, dynamic>;
      if (bMap['asset_type'] == 'native') {
        final balStr = bMap['balance']?.toString() ?? '0';
        chainBalance = ethToWeiString(
          balStr,
          7,
        ); // XLM uses 7 decimal places (stroops)
        break;
      }
    }

    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('XLM'));
    }

    const int fee = 100; // base fee in stroops
    BigInt valuePrice = ethToWeiString(
      params.amountDecimalString,
      7,
    ); // 1 XLM = 10,000,000 stroops
    double adjustedAmount = params.amount;

    if (valuePrice == chainBalance && params.sendMax) {
      final feeBig = BigInt.from(fee);
      if (feeBig >= valuePrice) {
        return SendResult.fail(S.current.g_key_wallet_m5('XLM'));
      }
      valuePrice = valuePrice - feeBig;
      adjustedAmount = toEther(valuePrice.toString(), 7).toDouble();
    }
    if (valuePrice <= BigInt.zero ||
        BigInt.from(fee) + valuePrice > chainBalance) {
      return SendResult.fail(S.current.g_key_wallet_m5('XLM'));
    }

    final sequence = accountData['sequence']?.toString() ?? '0';
    final nextSequence = (BigInt.parse(sequence) + BigInt.one).toString();

    final signMap = <String, dynamic>{
      'toAddress': params.toAddress,
      'amount': valuePrice.toString(),
      'sequence': nextSequence,
      'memo': params.memo ?? '',
      'fee': fee.toString(),
      'passphrase': params.isTest
          ? 'Test SDF Network ; September 2015'
          : 'Public Global Stellar Network ; September 2015',
    };

    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    final Map derived;
    try {
      derived = await _trustdart.generateAddress(
        CoinType.XLM.name,
        params.path,
        'legacy',
        mnemonic: mnemonic ?? '',
        pk: params.privateKey ?? '',
        isTest: params.isTest,
      );
    } catch (_) {
      return const SendResult.fail('Unable to verify signing address');
    }
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    // Stellar account IDs are case-sensitive. Never normalize a different ID
    // into the confirmed sender, or trust a caller-provided verification flag.
    final address = derived['legacy'];
    if (address is! String ||
        address.isEmpty ||
        address != params.fromAddress) {
      return const SendResult.fail('Signing key does not match sender');
    }
    final signStr = await _trustdart.signTransaction(
      CoinType.XLM.name,
      params.path,
      signMap,
      mnemonic: mnemonic ?? '',
      pk: params.privateKey ?? '',
    );
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final sendMm = await xlmApi.sendTransaction(signStr, isTest: params.isTest);
    if (sendMm.error) return SendResult.fail(sendMm.data?.toString());

    final txHash =
        (sendMm.data as Map<String, dynamic>?)?['hash']?.toString() ??
        sendMm.data?.toString();
    return SendResult.ok(txHash, actualAmount: adjustedAmount);
  }
}
