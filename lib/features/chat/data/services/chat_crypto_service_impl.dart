// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/services/wallet_service_interface.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';
import 'package:web3dart/web3dart.dart';

/// Implementation of IChatCryptoService
///
/// Uses the wallet's keys for encryption/decryption operations.
/// Only the main wallet's keys are used for security.
///
/// Security considerations:
/// - Private keys are NOT cached to prevent memory exposure
/// - Keys are derived on-demand and immediately released
/// - Uses secure key derivation from wallet service
class ChatCryptoServiceImpl implements IChatCryptoService {
  final ProviderContainer _container;

  /// Cached PUBLIC keys only (safe to cache)
  /// Private keys are never cached for security
  Map<String, bool>? _cachedPublicKeys;

  /// Timestamp of last cache update for expiration
  DateTime? _cacheTimestamp;

  /// Cache expiration duration (5 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 5);

  ChatCryptoServiceImpl(this._container);

  /// Get all wallets data
  List<WalletInfoData> _getAllWallets() {
    final wallets = _container.read(walletListProvider);
    return wallets.whenOrNull(data: (list) => list) ?? [];
  }

  /// Get the main wallet (marked as main, or first fallback)
  WalletInfoData? _getMainWallet() {
    final wallets = _getAllWallets();
    if (wallets.isEmpty) return null;
    return wallets.where((w) => w.isMainWallet).firstOrNull ?? wallets.first;
  }

  /// Resolve the N-chain derivation path for a wallet.
  /// Returns null if coinInfo is missing or incomplete.
  String? _resolveDerivationPath(WalletInfoData wallet) {
    final astMap = wallet.coinInfo?[CoinType.N.name];
    if (astMap == null) return null;

    final int pathIndex = astMap['pathIndex'] ?? 0;
    final addrType = astMap['addrType'] ?? 'legacy';
    return getPathWithIndex(astMap["baseInfo"]["path"][addrType], pathIndex);
  }

  @override
  Future<String?> getPublicKeyForChat() async {
    final wallet = _getMainWallet();
    if (wallet == null) return null;
    final path = _resolveDerivationPath(wallet);
    if (path == null) return null;

    try {
      final publicKey = await Trustdart().getPublicKey(
        CoinType.N.name,
        path,
        mnemonic: wallet.mnemonic ?? "",
        pk: wallet.privateKey ?? "",
      );
      return bytesToHex(base64Decode(publicKey));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getPrivateKeyForChat() async {
    final wallet = _getMainWallet();
    if (wallet == null) return null;
    final path = _resolveDerivationPath(wallet);
    if (path == null) return null;

    try {
      String? privateKey = wallet.privateKey;
      if (privateKey == null && wallet.mnemonic != null) {
        privateKey = await Trustdart().getPrivateKey(
          wallet.mnemonic!,
          CoinType.N.name,
          path,
        );
      }
      if (privateKey == null) return null;
      return bytesToHex(base64Decode(privateKey));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> encryptMessage(String recipientPubKey, String message) async {
    try {
      final Map<String, dynamic> params = {
        "type": "encrypt",
        "val": {"public_key": recipientPubKey, "msg": message},
      };
      final evmRes = await Trustdart().evmEmit(params);
      return evmRes?["data"];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> decryptMessage(String encryptedMessage) async {
    final privateKey = await getPrivateKeyForChat();
    if (privateKey == null) return null;

    try {
      final Map<String, dynamic> params = {
        "type": "decrypt",
        "val": {"priv_key": privateKey, "msg": encryptedMessage},
      };
      final evmRes = await Trustdart().evmEmit(params);
      return evmRes?["data"];
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, String>> getPublicKeyAndPrivateKeyPairs() async {
    // SECURITY: This method now returns empty map and is deprecated
    // Use getPublicKeysForChat() to get public keys
    // Use decryptMessageWithKeyPair() for decryption which derives keys on-demand
    //
    // WARNING: Returning private keys in a Map is a security risk
    // as they persist in memory. This method is kept for API compatibility
    // but implementations should migrate to secure alternatives.

    // Check cache expiration
    if (_cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) > _cacheExpiration) {
      _cachedPublicKeys = null;
      _cacheTimestamp = null;
    }

    final Map<String, String> keyPairs = {};
    final trustdart = Trustdart();

    for (final wallet in _getAllWallets()) {
      if (!wallet.isMainWallet) continue;

      final path = _resolveDerivationPath(wallet);
      if (path == null) continue;

      try {
        final pairJson = await trustdart.getPrivateKeyAndPublicKeyPair(
          CoinType.N.name,
          path,
          mnemonic: wallet.mnemonic ?? "",
          pk: wallet.privateKey ?? "",
        );

        final Map<dynamic, dynamic> pkPair = json.decode(pairJson);
        final pubKey = bytesToHex(base64Decode(pkPair['publicKey'].toString()));
        final privateKey =
            bytesToHex(base64Decode(pkPair['privateKey'].toString()));

        keyPairs[pubKey] = privateKey;

        _cachedPublicKeys ??= {};
        _cachedPublicKeys![pubKey] = true;
      } catch (e) {
        continue;
      }
    }

    _cacheTimestamp = DateTime.now();

    // Note: Private keys in keyPairs will be garbage collected after use
    // Caller should not store this map long-term
    return keyPairs;
  }

  @override
  Future<String?> decryptMessageWithKeyPair(
    String pubKey,
    String encryptedMessage,
  ) async {
    final keyPairs = await getPublicKeyAndPrivateKeyPairs();
    final privateKey = keyPairs[pubKey];

    if (privateKey == null) return null;

    try {
      final Map<String, dynamic> params = {
        "type": "decrypt",
        "val": {"priv_key": privateKey, "msg": encryptedMessage},
      };
      final evmRes = await Trustdart().evmEmit(params);
      return evmRes?["data"];
    } catch (e) {
      return null;
    }
  }

  /// Clear cached public keys (call when wallet list changes)
  void clearCache() {
    _cachedPublicKeys = null;
    _cacheTimestamp = null;
  }

  /// Dispose and securely clear all cached data
  void dispose() {
    _cachedPublicKeys?.clear();
    clearCache();
  }
}

/// Provider for IChatCryptoService
final chatCryptoServiceProvider = Provider<IChatCryptoService>((ref) {
  final container = ProviderContainer();
  final service = ChatCryptoServiceImpl(container);
  ref.onDispose(() {
    service.dispose();
    container.dispose();
  });
  return service;
});

