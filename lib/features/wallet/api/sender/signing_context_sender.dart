// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:n42_wallet/core/wallet_sdk/trustdart.dart';
import 'package:n42_wallet/features/wallet/api/sender/chain_sender.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/utils/chain/chain_url_registry.dart';

typedef WalletSigningContextReader = WalletSigningContext Function(
  SendParams params,
);

/// Captures and validates the signer before a chain sender performs network I/O.
///
/// The shared guard protects every sender created by the factory: the key
/// must derive the address the transaction claims as `from`, and mnemonic based
/// senders receive the same immutable snapshot after any later account switch.
class WalletSigningContextSender implements ChainSender {
  final ChainSender delegate;
  final Trustdart _trustdart;
  final WalletSigningContextReader _readSigningContext;

  WalletSigningContextSender({
    required this.delegate,
    required this._readSigningContext,
    Trustdart? trustdart,
  }) : _trustdart = trustdart ?? Trustdart();

  @override
  Future<SendResult> send(SendParams params) async {
    final WalletSigningContext context;
    try {
      context = params.signingContext ?? _readSigningContext(params);
    } catch (_) {
      return const SendResult.fail('Wallet is not ready');
    }

    if (context.addressVerified) {
      return delegate.send(params.withSigningContext(context));
    }

    final key = params.privateKey ?? context.privateKey;
    final mnemonic = context.mnemonic;
    if (key == null && (mnemonic == null || mnemonic.trim().isEmpty)) {
      return const SendResult.fail('Signing key is unavailable');
    }
    if (key != null && key.trim().isEmpty) {
      return const SendResult.fail('Signing key is unavailable');
    }

    final Map<Object?, Object?> derived;
    try {
      derived = await _trustdart.generateAddress(
        params.coinType,
        params.path,
        params.addressType,
        mnemonic: key == null ? mnemonic! : '',
        pk: key ?? '',
        isTest: params.isTest,
      );
    } catch (_) {
      return const SendResult.fail('Unable to verify signing address');
    }

    final derivedAddress = derived[params.addressType]?.toString().trim() ?? '';
    if (derivedAddress.isEmpty) {
      return const SendResult.fail('Unable to verify signing address');
    }
    if (!_addressesMatch(params, derivedAddress)) {
      return const SendResult.fail('Signing key does not match sender address');
    }

    return delegate.send(params.withSigningContext(context.verified()));
  }

  bool _addressesMatch(SendParams params, String derivedAddress) {
    final coinType = params.coinType.toUpperCase();
    final rawConfig =
        params.chainConfig ?? allChainUrlMap[coinType] as Map<String, dynamic>?;
    final baseInfo = resolveChainBaseInfo(rawConfig);
    final blockchainType = baseInfo == null
        ? ''
        : CoinConfigView(baseInfo).blockchainType;
    if (blockchainType == 'Ethereum') {
      return derivedAddress.toLowerCase() ==
          params.fromAddress.trim().toLowerCase();
    }
    return derivedAddress == params.fromAddress.trim();
  }
}
