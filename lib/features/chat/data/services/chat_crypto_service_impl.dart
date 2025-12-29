// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/src/component/enums/coin_type.dart';
import 'package:n42appv2/src/wallet/provider/trustdart.dart';
import 'package:n42appv2/src/wallet/utils/chain_util.dart';
import 'package:web3dart/crypto.dart';

/// Implementation of IChatCryptoService
///
/// Uses the wallet's keys for encryption/decryption operations.
/// Only the main wallet's keys are used for security.
class ChatCryptoServiceImpl implements IChatCryptoService {
  final ProviderContainer _container;

  /// Cached key pairs for performance
  Map<String, String>? _cachedKeyPairs;

  ChatCryptoServiceImpl(this._container);

  /// Get all wallets data
  List<WalletInfoData> _getAllWallets() {
    final wallets = _container.read(walletListProvider);
    return wallets.whenOrNull(data: (list) => list) ?? [];
  }

  /// Get the main wallet's data
  WalletInfoData? _getMainWallet() {
    final wallets = _getAllWallets();
    if (wallets.isEmpty) return null;

    // Find wallet marked as main
    final mainWallet = wallets.where((w) => w.isMainWallet).firstOrNull;
    if (mainWallet != null) return mainWallet;

    // Fallback to first wallet if no main wallet
    return wallets.first;
  }

  @override
  Future<String?> getPublicKeyForChat() async {
    final wallet = _getMainWallet();
    if (wallet == null) return null;

    try {
      final coinInfo = wallet.coinInfo;
      final astMap = coinInfo?[CoinType.N.name];
      if (astMap == null) return null;

      final int pathIndex = astMap['pathIndex'] ?? 0;
      final addrType = astMap['addrType'] ?? 'legacy';
      final path = getPathWithIndex(
        astMap["baseInfo"]["path"][addrType],
        pathIndex,
      );

      final publicKey = await Trustdart().getPublicKey(
        CoinType.N.name,
        path,
        mnemonic: wallet.mnemonic ?? "",
        pk: wallet.privateKey ?? "",
      );

      final pk = base64Decode(publicKey);
      return bytesToHex(pk);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getPrivateKeyForChat() async {
    final wallet = _getMainWallet();
    if (wallet == null) return null;

    try {
      final coinInfo = wallet.coinInfo;
      final astMap = coinInfo?[CoinType.N.name];
      if (astMap == null) return null;

      final int pathIndex = astMap['pathIndex'] ?? 0;
      final addrType = astMap['addrType'] ?? 'legacy';
      final path = getPathWithIndex(
        astMap["baseInfo"]["path"][addrType],
        pathIndex,
      );

      String? privateKey = wallet.privateKey;
      if (privateKey == null && wallet.mnemonic != null) {
        privateKey = await Trustdart().getPrivateKey(
          wallet.mnemonic!,
          CoinType.N.name,
          path,
        );
      }

      if (privateKey == null) return null;

      final pk = base64Decode(privateKey);
      return bytesToHex(pk);
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
    // Return cached if available
    if (_cachedKeyPairs != null) {
      return _cachedKeyPairs!;
    }

    final Map<String, String> keyPairs = {};
    final wallets = _getAllWallets();
    final trustdart = Trustdart();

    for (final wallet in wallets) {
      // Only process main wallets (for security)
      if (!wallet.isMainWallet) continue;

      try {
        final coinInfo = wallet.coinInfo;
        final astMap = coinInfo?[CoinType.N.name];
        if (astMap == null) continue;

        final int pathIndex = astMap['pathIndex'] ?? 0;
        final addrType = astMap['addrType'] ?? 'legacy';
        final path = getPathWithIndex(
          astMap["baseInfo"]["path"][addrType],
          pathIndex,
        );

        // Get both public and private key pair
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
      } catch (e) {
        // Continue with next wallet
        continue;
      }
    }

    // Cache the result
    _cachedKeyPairs = keyPairs;
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

  /// Clear cached key pairs (call when wallet list changes)
  void clearCache() {
    _cachedKeyPairs = null;
  }

  void dispose() {
    _cachedKeyPairs = null;
  }
}

/// Provider for IChatCryptoService
final chatCryptoServiceProvider = Provider<IChatCryptoService>((ref) {
  // We need the container - in a real app this would be injected
  // For now, create a temporary container (will be improved during full migration)
  final container = ProviderContainer();
  final service = ChatCryptoServiceImpl(container);
  ref.onDispose(() {
    service.dispose();
    container.dispose();
  });
  return service;
});

