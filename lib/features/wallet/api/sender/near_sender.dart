// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:fast_base58/fast_base58.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/chain_api/near_api.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';

import '../chain_api/near_transaction_hash.dart';
import 'chain_sender.dart';

/// NEAR Protocol sender.
class NearSender implements ChainSender {
  final Trustdart _trustdart;
  final NearApi Function(bool) _apiFactory;
  final Object? Function() _ownerIdentity;
  final (String, String) Function() _readCredentials;
  bool _sending = false;

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

  static (String, String) _currentCredentials() {
    if (!globalWapAdapter.isWalletReady) return ('', '');
    final wallet = globalWapAdapter.walletInfo;
    return (wallet.mnemonic ?? '', wallet.privateKey ?? '');
  }

  NearSender({
    Trustdart? trustdart,
    NearApi Function(bool)? apiFactory,
    Object? Function()? ownerIdentity,
    (String, String) Function()? readCredentials,
  }) : _trustdart = trustdart ?? Trustdart(),
       _apiFactory = apiFactory ?? ((test) => NearApi(isTest: test)),
       _ownerIdentity = ownerIdentity ?? _currentOwner,
       _readCredentials = readCredentials ?? _currentCredentials;

  @override
  Future<SendResult> send(SendParams params) async {
    if (_sending) return const SendResult.fail('A transfer is already pending');
    _sending = true;
    try {
      final owner = _ownerIdentity();
      final credentials = params.privateKey == null
          ? _readCredentials()
          : ('', params.privateKey!);
      bool current() =>
          _ownerIdentity() == owner &&
          (params.privateKey != null ||
              (owner != null && _readCredentials() == credentials));
      if (!current() || (credentials.$1.isEmpty && credentials.$2.isEmpty)) {
        return const SendResult.fail('Wallet is not ready');
      }
      return await _send(params, credentials, current);
    } catch (_) {
      return const SendResult.fail('Unable to prepare or send NEAR transfer');
    } finally {
      _sending = false;
    }
  }

  Future<SendResult> _send(
    SendParams params,
    (String, String) credentials,
    bool Function() current,
  ) async {
    if (params.contractAddress.isNotEmpty ||
        params.fromAddress.isEmpty ||
        params.toAddress.isEmpty) {
      return const SendResult.fail('Invalid native NEAR transfer');
    }
    final nearApi = _apiFactory(params.isTest);
    // Wallet Core derives NEAR's implicit account as the hex Ed25519 key.
    // Named accounts are authorized by view_access_key, not address equality.
    final derived = await _trustdart.generateAddress(
      CoinType.NEAR.name,
      params.path,
      'legacy',
      mnemonic: credentials.$2.isEmpty ? credentials.$1 : '',
      pk: credentials.$2,
      isTest: params.isTest,
    );
    final implicit = derived['legacy'];
    if (!current() ||
        implicit is! String ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(implicit)) {
      return const SendResult.fail('Invalid NEAR signing identity');
    }
    final keyBytes = List.generate(
      32,
      (i) => int.parse(implicit.substring(i * 2, i * 2 + 2), radix: 16),
    );
    final publicKey = 'ed25519:${Base58Encode(keyBytes)}';

    // Get balance
    final mmb = await nearApi.getTransferBalance(params.fromAddress);
    if (mmb.error) return SendResult.fail(mmb.data?.toString());
    final accountBalance = mmb.data as Map;
    final chainBalance = accountBalance['balance'] as BigInt;
    final storageReserve = accountBalance['storageReserve'] as BigInt;
    final available = chainBalance - storageReserve;
    if (storageReserve < BigInt.zero || available <= BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
    }
    if (chainBalance == BigInt.zero) {
      return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
    }

    // Get gas price
    final mmg = await nearApi.getGasPrice();
    if (mmg.error) return SendResult.fail(mmg.data?.toString());
    final gasPrice = mmg.data as BigInt;
    if (gasPrice <= BigInt.zero || chainBalance < BigInt.zero) {
      return const SendResult.fail('Invalid NEAR balance or gas price');
    }
    final gasUnits = BigInt.from(300000000000000); // Existing conservative 300 TGas reserve; fee estimation remains separate.
    final totalGas = gasPrice * gasUnits;

    BigInt valuePrice =
        params.valueWeiOverride ??
        ethToWeiString(params.amountDecimalString, params.decimals);
    double adjustedAmount = toEther(
      valuePrice.toString(),
      params.decimals,
    ).toDouble();
    if (valuePrice <= BigInt.zero || valuePrice >= (BigInt.one << 128)) {
      return const SendResult.fail('Invalid NEAR amount');
    }

    if (params.sendMax &&
        (valuePrice == chainBalance || valuePrice == available)) {
      if (totalGas >= available) {
        return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
      }
      valuePrice = available - totalGas;
      adjustedAmount = toEther(
        valuePrice.toString(),
        params.decimals,
      ).toDouble();
    }
    if (valuePrice <= BigInt.zero || totalGas + valuePrice > available) {
      return SendResult.fail(S.current.g_key_wallet_m5('NEAR'));
    }

    // Get block hash for transaction
    final mmblock = await nearApi.getLatestBlockHash();
    if (mmblock.error) return SendResult.fail(mmblock.data?.toString());
    final blockData = mmblock.data as Map<String, dynamic>;
    final blockHash = blockData['hash'] as String;

    final blockBytes = Base58Decode(blockHash);
    if (blockBytes.length != 32 ||
        Base58Encode(blockBytes) != blockHash ||
        !current()) {
      return const SendResult.fail('Invalid NEAR block or changed wallet');
    }
    final mmKey = await nearApi.getAccessKey(params.fromAddress, publicKey);
    if (mmKey.error || !current()) {
      return const SendResult.fail('Unable to authorize NEAR access key');
    }
    final keyData = mmKey.data;
    if (keyData is! Map || keyData['permission'] != 'FullAccess') {
      return const SendResult.fail('NEAR transfer requires a full-access key');
    }
    final nonceText = keyData['nonce'].toString();
    final previousNonce = RegExp(r'^[0-9]+$').hasMatch(nonceText)
        ? BigInt.tryParse(nonceText)
        : null;
    // Android currently parses a signed Long. Reject instead of overflowing.
    if (previousNonce == null ||
        previousNonce >= BigInt.from(0x7fffffffffffffff)) {
      return const SendResult.fail('Invalid or unsupported NEAR nonce');
    }
    // Wallet Core 4.8.7's NEAR serializer writes these bytes directly as
    // Borsh u128: fixed-width little endian (despite its proto comment).
    final amountHex = List.generate(
      16,
      (i) => ((valuePrice >> (8 * i)) & BigInt.from(255))
          .toInt()
          .toRadixString(16)
          .padLeft(2, '0'),
    ).join();
    final signMap = <String, dynamic>{
      'amount': amountHex,
      'receiverId': params.toAddress,
      'signerId': params.fromAddress,
      'nonce': (previousNonce + BigInt.one).toString(),
      'blockHash': blockBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
    };
    if (!current()) {
      return const SendResult.fail('Wallet changed before signing');
    }
    final signStr = await _trustdart.signTransaction(
      CoinType.NEAR.name,
      params.path,
      signMap,
      mnemonic: credentials.$2.isEmpty ? credentials.$1 : '',
      pk: credentials.$2,
    );
    if (!current()) {
      return const SendResult.fail('Wallet changed before submission');
    }
    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final String hash;
    try {
      hash = nearSignedTransactionHash(signStr);
    } catch (_) {
      return const SendResult.fail('Invalid signed NEAR transaction');
    }
    try {
      await params.beforeBroadcast?.call(hash);
    } catch (_) {
      return SendResult.notSubmitted(
        hash,
        'Unable to preserve transaction before submission',
      );
    }
    if (!current()) {
      return SendResult.notSubmitted(hash, 'Wallet changed before submission');
    }
    try {
      await params.onBroadcastStarting?.call(hash);
    } catch (_) {
      return SendResult.notSubmitted(
        hash,
        'Unable to record transaction dispatch',
      );
    }
    if (!current()) {
      return SendResult.notSubmitted(hash, 'Wallet changed before submission');
    }
    try {
      final result = await nearApi.sendTransaction(signStr);
      if (!result.error && result.data == hash) {
        return SendResult.ok(hash, actualAmount: adjustedAmount);
      }
    } catch (_) {
      // A response failure does not establish that the transaction was rejected.
    }
    return SendResult.uncertain(
      hash,
      'NEAR submission status is unknown; check the original transaction',
      actualAmount: adjustedAmount,
    );
  }
}
