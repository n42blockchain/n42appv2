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
import '../../utils/cardano/signing_inputs.dart';
import '../../utils/cardano/signed_transfer.dart';

/// Cardano (ADA) sender — uses Blockfrost API.
class AdaSender implements ChainSender {
  final Trustdart _trustdart;
  final AdaApi _api;
  final Object? Function() _ownerIdentity;
  final String? Function() _readMnemonic;

  AdaSender({
    Trustdart? trustdart,
    AdaApi? api,
    Object? Function()? ownerIdentity,
    String? Function()? readMnemonic,
  }) : _trustdart = trustdart ?? Trustdart(),
       _api = api ?? AdaApi(projectId: _projectId),
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

  /// Blockfrost project_id — obtained from chain config or environment.
  static const _projectId = String.fromEnvironment(
    'BLOCKFROST_PROJECT_ID',
    defaultValue: '',
  );

  @override
  Future<SendResult> send(SendParams params) async {
    if (_api.projectId.isEmpty) {
      return const SendResult.fail('ADA: Blockfrost project_id not configured');
    }
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
    final adaApi = _api;

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
    final CardanoSigningInputs inputs;
    try {
      inputs = CardanoSigningInputs.fromBlockfrost(
        mmUtxos.data,
        params.fromAddress,
      );
    } on FormatException catch (error) {
      return SendResult.fail(error.message);
    }
    // Only the selected spendable inputs can fund this operation. Never count
    // assets retained in excluded multi-asset UTxOs or another API page.
    chainBalance = inputs.balance;
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    final block = await adaApi.getLatestBlock(isTest: params.isTest);
    if (block.error) return SendResult.fail(block.data?.toString());
    final String ttl;
    try {
      ttl = CardanoSigningInputs.ttl(block.data);
    } on FormatException catch (error) {
      return SendResult.fail(error.message);
    }

    final valuePrice = ethToWeiString(
      params.amountDecimalString,
      params.decimals,
    );
    final useMaxAmount = params.sendMax && valuePrice == chainBalance;
    if (valuePrice <= BigInt.zero || valuePrice > chainBalance) {
      return SendResult.fail(
        inputs.excludesNativeAssets
            ? 'Insufficient ADA-only inputs; native-token inputs remain unspent'
            : S.current.g_key_wallet_m5('ADA'),
      );
    }

    final signMap = <String, dynamic>{
      'utxos': inputs.utxos,
      'ttl': ttl,
      'toAddress': params.toAddress,
      'amount': valuePrice.toString(),
      'changeAddress': params.fromAddress,
      'useMaxAmount': useMaxAmount,
      'returnMetadata': true,
    };

    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    final Map derived;
    try {
      derived = await _trustdart.generateAddress(
        CoinType.ADA.name,
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
    // Match the native-derived account exactly; do not accept a caller-supplied
    // verification flag or silently substitute a different change account.
    final address = derived['legacy'];
    if (address is! String ||
        address.isEmpty ||
        address != params.fromAddress) {
      return const SendResult.fail('Signing key does not match sender');
    }
    final signStr = await _trustdart.signTransaction(
      CoinType.ADA.name,
      params.path,
      signMap,
      mnemonic: mnemonic ?? '',
      pk: params.privateKey ?? '',
    );
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }

    if (signStr.isEmpty) return SendResult.fail(S.current.g_key_wallet_m6);

    final CardanoSignedTransfer signed;
    try {
      signed = CardanoSignedTransfer.parse(
        signStr,
        requested: valuePrice,
        available: chainBalance,
        sendMax: useMaxAmount,
      );
    } on FormatException catch (error) {
      return SendResult.fail(error.message);
    }
    final actualAmount = toEther(
      signed.amount.toString(),
      params.decimals,
    ).toDouble();
    try {
      await params.beforeBroadcast?.call(signed.txHash);
    } catch (_) {
      return const SendResult.fail(
        'Unable to preserve transaction before submission',
      );
    }
    if (!signerIsCurrent()) {
      return const SendResult.fail('Wallet signing context changed');
    }
    try {
      final sendMm = await adaApi.sendTransaction(
        signed.encoded,
        isTest: params.isTest,
      );
      if (sendMm.error ||
          sendMm.data is! String ||
          (sendMm.data as String).toLowerCase() != signed.txHash) {
        return SendResult.uncertain(
          signed.txHash,
          'Cardano submission status is unknown; check the original transaction',
          actualAmount: actualAmount,
        );
      }
      return SendResult.ok(signed.txHash, actualAmount: actualAmount);
    } catch (_) {
      return SendResult.uncertain(
        signed.txHash,
        'Cardano submission status is unknown; check the original transaction',
        actualAmount: actualAmount,
      );
    }
  }
}
