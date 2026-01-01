// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/core/app/app_globals.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
import 'package:n42appv2/shared/di/service_locator.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';

/// Chat Utility Class
///
/// Provides encryption/decryption and caching utilities for chat feature.
/// Uses IChatCryptoService for wallet key operations (boundary compliant).
class ChatUtil {
  /// Get the chat crypto service from service locator
  IChatCryptoService? get _cryptoService =>
      ServiceLocatorSetup.chatCryptoService;

  /// Encrypt a message using recipient's public key
  Future<String?> chatEnCode(String pubKey, String msg) async {
    final service = _cryptoService;
    if (service == null) {
      // Fallback: service not initialized
      return null;
    }
    return await service.encryptMessage(pubKey, msg);
  }

  /// Decrypt a message using wallet's private key
  Future<String?> chatDecode(String privateKey, String msg) async {
    final service = _cryptoService;
    if (service == null) {
      return null;
    }
    return await service.decryptMessage(msg);
  }

  /// Get N chain private key for chat encryption
  ///
  /// Uses IChatCryptoService to get the key securely.
  Future<String?> getAstPrivateKey() async {
    final service = _cryptoService;
    if (service == null) {
      return "";
    }
    return await service.getPrivateKeyForChat();
  }

  /// Get N chain public key for chat encryption
  ///
  /// Uses IChatCryptoService to get the key securely.
  Future<String?> getAstPubKey() async {
    final service = _cryptoService;
    if (service == null) {
      return "";
    }
    return await service.getPublicKeyForChat();
  }

  /// Cache a chat message locally
  Future cacheChatMessage(String key, String message) async {
    final chatCacheKey = "${AppGlobals.userInfo?.uuid}_chatKey";
    final data = await getChatCacheMessage();
    Map<String, dynamic> map = {};
    map[key] = message;
    if (data != null) {
      map.addAll(data);
    }
    return await SPUtil().putObject(chatCacheKey, map);
  }

  /// Get cached chat messages
  Future getChatCacheMessage() async {
    final chatCacheKey = "${AppGlobals.userInfo?.uuid}_chatKey";
    return await SPUtil().getObject(chatCacheKey);
  }
}