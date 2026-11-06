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

import '../../utils/stellar/spendable_balance.dart';
import '../../utils/stellar/signed_transaction.dart';

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
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    final ledger = await xlmApi.getLatestLedger(isTest: params.isTest);
    if (ledger.error) return SendResult.fail(ledger.data?.toString());
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    final StellarSpendableBalance funds;
    final BigInt requested;
    try {
      funds = StellarSpendableBalance.parse(mmAccount.data, ledger.data);
      var amountText = params.amountDecimalString;
      if (params.decimalAmountOverride == null && amountText.contains('e')) {
        final expanded = params.amount.toStringAsFixed(7);
        if (double.tryParse(expanded) != params.amount) {
          throw const FormatException('Stellar amount exceeds seven decimals');
        }
        amountText = expanded;
      }
      requested = StellarSpendableBalance.stroops(amountText);
    } on FormatException catch (error) {
      return SendResult.fail(error.message);
    }
    if (params.expectedFeeBaseUnits != null &&
        params.expectedFeeBaseUnits != funds.fee) {
      return SendResult.fail(S.current.g_audit_quote_changed);
    }
    // Only an explicit full-balance request can be reduced automatically.
    // An ordinary payment retains the exact user-entered amount.
    final valuePrice = params.sendMax && requested == funds.balance
        ? funds.spendable
        : requested;
    if (valuePrice <= BigInt.zero || valuePrice > funds.spendable) {
      return SendResult.fail(S.current.g_key_wallet_m5('XLM'));
    }
    final adjustedAmount = toEther(valuePrice.toString(), 7).toDouble();
    final fee = funds.fee;
    final nextSequence = funds.nextSequence.toString();

    final signMap = <String, dynamic>{
      'toAddress': params.toAddress,
      'amount': valuePrice.toString(),
      'sequence': nextSequence,
      'memo': params.memo ?? '',
      'fee': fee.toString(),
      'returnMetadata': true,
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

    final StellarSignedTransaction signed;
    try {
      signed = StellarSignedTransaction.parse(signStr);
    } on FormatException catch (error) {
      return SendResult.fail(error.message);
    }
    try {
      await params.beforeBroadcast?.call(signed.txHash);
    } catch (_) {
      return SendResult.notSubmitted(
        signed.txHash,
        'Unable to preserve transaction before submission',
      );
    }
    if (!signerIsCurrent()) {
      return SendResult.notSubmitted(
        signed.txHash,
        'Wallet signing context changed',
      );
    }
    try {
      await params.onBroadcastStarting?.call(signed.txHash);
    } catch (_) {
      return SendResult.notSubmitted(
        signed.txHash,
        'Unable to record transaction dispatch',
      );
    }
    if (!signerIsCurrent()) {
      return SendResult.notSubmitted(
        signed.txHash,
        'Wallet signing context changed',
      );
    }
    try {
      final result = await xlmApi.sendTransaction(
        signed.encoded,
        isTest: params.isTest,
      );
      final data = result.data;
      if (!result.error &&
          data is Map &&
          data['hash'] is String &&
          (data['hash'] as String).toLowerCase() == signed.txHash) {
        return SendResult.ok(signed.txHash, actualAmount: adjustedAmount);
      }
    } catch (_) {
      // A lost response cannot prove rejection. Do not sign or submit again.
    }
    return SendResult.uncertain(
      signed.txHash,
      'Stellar submission status is unknown; check the original transaction',
      actualAmount: adjustedAmount,
    );
  }
}
