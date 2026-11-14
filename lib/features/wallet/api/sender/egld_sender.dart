// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/features/wallet/services/egld_quote_service.dart';
import 'package:n42_wallet/features/wallet/services/egld_transaction_hash.dart';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';
import 'package:n42_wallet/core/network/base_http.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import 'chain_sender.dart';

/// MultiversX (EGLD) sender.
class EgldSender implements ChainSender {
  final Trustdart _trustdart;
  final Object? Function() _ownerIdentity;
  final String? Function() _readMnemonic;
  final Future<dynamic> Function(String url) _getAccount;
  final Future<dynamic> Function(String url) _getNetworkConfig;
  final Future<dynamic> Function(String url, String signed) _broadcast;

  EgldSender({
    Trustdart? trustdart,
    Object? Function()? ownerIdentity,
    String? Function()? readMnemonic,
    Future<dynamic> Function(String url)? getAccount,
    Future<dynamic> Function(String url)? getNetworkConfig,
    Future<dynamic> Function(String url, String signed)? broadcast,
  }) : _trustdart = trustdart ?? Trustdart(),
       _ownerIdentity = ownerIdentity ?? _currentOwner,
       _readMnemonic = readMnemonic ?? _currentMnemonic,
       _getAccount = getAccount ?? _getJson,
       _getNetworkConfig = getNetworkConfig ?? _getJson,
       _broadcast = broadcast ?? _submit;

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

  static Future<dynamic> _getJson(String url) => BaseApi.requestEmptyH.get(
    url,
    params: {},
    defaultReturn: false,
    header: _header,
  );

  static Future<dynamic> _submit(String url, String signed) =>
      BaseApi.requestEmptyH.requestWithStatus(
        url,
        method: 'POST',
        data: signed,
        header: _header,
      );

  static const _mainnetUrl = 'https://api.multiversx.com';
  static const _testnetUrl = 'https://testnet-api.multiversx.com';
  static const _header = {'Content-Type': 'application/json'};

  String _base(bool isTest) => isTest ? _testnetUrl : _mainnetUrl;

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
    final base = _base(params.isTest);
    final Map<String, dynamic> accountData;
    try {
      final data = await _getAccount('$base/accounts/${params.fromAddress}');
      if (!signerIsCurrent()) {
        return const SendResult.fail('Wallet signing context changed');
      }
      if (data is! Map<String, dynamic> ||
          data['nonce'] is! int ||
          (data['nonce'] as int) < 0 ||
          data['balance'] is! String ||
          !RegExp(r'^[0-9]+$').hasMatch(data['balance'] as String)) {
        return const SendResult.fail('Invalid account response');
      }
      accountData = data;
    } catch (_) {
      return const SendResult.fail('Unable to load account');
    }
    final nonce = accountData['nonce'] as int? ?? 0;
    final balanceStr = accountData['balance']?.toString() ?? '0';
    final chainBalance = BigInt.tryParse(balanceStr) ?? BigInt.zero;

    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('EGLD'));
    }

    final EgldFeeQuote quote;
    try {
      final response = await _getNetworkConfig('$base/network/config');
      if (!signerIsCurrent()) {
        return const SendResult.fail('Wallet signing context changed');
      }
      quote = EgldFeeQuote.parse(
        response,
        isTest: params.isTest,
        decimals: params.decimals,
        memo: params.memo ?? '',
      );
    } catch (_) {
      return const SendResult.fail('Unable to validate network fees');
    }
    final totalGas = quote.fee;
    if (params.expectedFeeBaseUnits != null &&
        params.expectedFeeBaseUnits != totalGas) {
      return SendResult.fail(S.current.g_audit_quote_changed);
    }

    BigInt valuePrice = ethToWeiString(
      params.amountDecimalString,
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
      'nonce': nonce.toString(),
      'amount': valuePrice.toString(),
      'toAddress': params.toAddress,
      'gasLimit': quote.gasLimit.toString(),
      'gasPrice': quote.gasPrice.toString(),
      'chainId': params.isTest ? 'T' : '1',
      'version': quote.version.toString(),
      'data': params.memo ?? '',
    };

    final String signStr;
    try {
      final derived = await _trustdart.generateAddress(
        CoinType.EGLD.name,
        params.path,
        'legacy',
        mnemonic: mnemonic ?? '',
        pk: params.privateKey ?? '',
        isTest: params.isTest,
      );
      if (!signerIsCurrent()) {
        return const SendResult.fail('Wallet signing context changed');
      }
      final address = derived['legacy'];
      if (address is! String ||
          address.isEmpty ||
          address != params.fromAddress) {
        return const SendResult.fail('Signing key does not match sender');
      }
      signStr = await _trustdart.signTransaction(
        CoinType.EGLD.name,
        params.path,
        signMap,
        mnemonic: mnemonic ?? '',
        pk: params.privateKey ?? '',
      );
    } catch (_) {
      return const SendResult.fail('Unable to sign transaction');
    }
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final String localHash;
    try {
      localHash = EgldTransactionHash.compute(signStr);
      final signed = jsonDecode(signStr) as Map<String, dynamic>;
      // Native output is a boundary: never broadcast different reviewed fields.
      if (signed['sender'] != params.fromAddress ||
          signed['receiver'] != params.toAddress ||
          signed['value'] != valuePrice.toString() ||
          signed['nonce'] != nonce ||
          signed['gasLimit'] != quote.gasLimit.toInt() ||
          signed['gasPrice'] != quote.gasPrice ||
          signed['chainID'] != signMap['chainId'] ||
          signed['version'] != quote.version ||
          (signed['options'] ?? 0) != 0 ||
          (signed['data'] ?? '') !=
              base64Encode(utf8.encode(params.memo ?? ''))) {
        return const SendResult.fail(
          'Signed transaction differs from reviewed transfer',
        );
      }
    } catch (_) {
      return const SendResult.fail('Invalid signed transaction');
    }

    try {
      await params.beforeBroadcast?.call(localHash);
    } catch (_) {
      return SendResult.notSubmitted(
        localHash,
        'Unable to preserve transaction before submission',
      );
    }
    if (!signerIsCurrent()) {
      return SendResult.notSubmitted(
        localHash,
        'Wallet signing context changed',
      );
    }
    try {
      await params.onBroadcastStarting?.call(localHash);
    } catch (_) {
      return SendResult.notSubmitted(
        localHash,
        'Unable to record transaction dispatch',
      );
    }
    if (!signerIsCurrent()) {
      return SendResult.notSubmitted(
        localHash,
        'Wallet signing context changed',
      );
    }

    SendResult unknown() => SendResult.uncertain(
      localHash,
      'MultiversX submission status is unknown; check the original transaction',
      actualAmount: adjustedAmount,
    );
    try {
      final raw = await _broadcast('$base/transactions', signStr);
      final response = raw is HttpStatusResult
          ? raw
          : HttpStatusResult(200, raw);
      final status = response.statusCode;
      if (status == 400) {
        // The MultiversX API answers 400 when the gateway refused the
        // transaction (bad nonce, insufficient funds, invalid signature...):
        // it is not in any pool and the signed bytes can never be executed.
        final problem = response.jsonObject;
        final message = problem?['message'];
        if (problem != null &&
            problem['statusCode'] == 400 &&
            problem['error'] == 'Bad Request') {
          return SendResult.rejected(
            localHash,
            message is String && message.isNotEmpty
                ? 'MultiversX rejected the transaction: $message'
                : 'MultiversX rejected the transaction',
          );
        }
      }
      if (status == null || status < 200 || status > 202) return unknown();
      final data = response.jsonObject;
      if (data is! Map<String, dynamic> ||
          data['txHash'] is! String ||
          (data['txHash'] as String).toLowerCase() != localHash) {
        return unknown();
      }
      return SendResult.ok(localHash, actualAmount: adjustedAmount);
    } catch (_) {
      // A transport error is not proof of rejection. Never replace the hash or
      // repeat the POST; callers retain this exact submission for lookup.
      return unknown();
    }
  }
}
