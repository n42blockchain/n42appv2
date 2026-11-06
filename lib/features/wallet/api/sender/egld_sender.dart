// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/core/network/base_api.dart';
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
      BaseApi.requestEmptyH.post(
        url,
        params: {},
        data: signed,
        defaultReturn: false,
        header: _header,
        enableRetry: false,
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

    final BigInt gasLimit;
    final int gasPrice;
    final int version;
    try {
      final response = await _getNetworkConfig('$base/network/config');
      if (!signerIsCurrent()) {
        return const SendResult.fail('Wallet signing context changed');
      }
      if (response is! Map ||
          response['code'] != 'successful' ||
          response['data'] is! Map ||
          response['data']['config'] is! Map) {
        throw const FormatException('Invalid network configuration');
      }
      final config = response['data']['config'] as Map;
      int integer(String key, {bool zeroAllowed = false}) {
        final value = config[key];
        if (value is! int || value < (zeroAllowed ? 0 : 1)) {
          throw const FormatException('Invalid network parameter');
        }
        return value;
      }

      if (config['erd_chain_id'] != (params.isTest ? 'T' : '1') ||
          integer('erd_denomination') != params.decimals) {
        throw const FormatException('Network does not match transfer');
      }
      final minimum = integer('erd_min_gas_limit');
      final perByte = integer('erd_gas_per_data_byte', zeroAllowed: true);
      final maximum = integer('erd_max_gas_per_transaction');
      gasPrice = integer('erd_min_gas_price');
      version = integer('erd_min_transaction_version');
      if (version > 0x7fffffff) {
        throw const FormatException('Invalid transaction version');
      }
      gasLimit =
          BigInt.from(minimum) +
          BigInt.from(perByte) *
              BigInt.from(utf8.encode(params.memo ?? '').length);
      if (gasLimit > BigInt.from(maximum)) {
        throw const FormatException('Transfer exceeds network gas limit');
      }
    } catch (_) {
      return const SendResult.fail('Unable to validate network fees');
    }
    final totalGas = gasLimit * BigInt.from(gasPrice);

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
      'gasLimit': gasLimit.toString(),
      'gasPrice': gasPrice.toString(),
      'chainId': params.isTest ? 'T' : '1',
      'version': version.toString(),
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

    // Broadcast
    try {
      final data = await _broadcast('$base/transactions', signStr);
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
