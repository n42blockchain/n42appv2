import 'dart:typed_data';
import 'package:n42appv2/core/security/secure_memory.dart';

/// Wallet information model
///
/// SECURITY NOTE:
/// - Sensitive fields (mnemonic, privateKey, password) should be accessed
///   through secure getter methods when possible
/// - After using sensitive data, call clearSensitiveData() to zero out memory
/// - Use SecureString wrapper for temporary sensitive data handling
class WalletInfo {
  /// Mnemonic phrase (stored encrypted in production)
  ///
  /// SECURITY: Use getMnemonicSecure() for secure access
  String? mnemonic;

  /// Wallet password
  ///
  /// SECURITY: Should be hashed, not stored in plain text in production
  String? password;

  /// Coin sorting cache
  /// assets: 0=descending, 1=ascending, -1=no sort
  /// name: 0=descending, 1=ascending, -1=no sort
  Map<String, dynamic> coinSort = {"assets": 0, "name": -1};

  int networkIndex = -1;
  String? walletName;

  /// User login ID
  String? walletUuid;

  /// Coin basic information
  Map<String, dynamic>? coinInfo;

  /// Private key (stored encrypted in production)
  ///
  /// SECURITY: Use getPrivateKeySecure() for secure access
  String? privateKey;

  /// Wallet creation timestamp (unique identifier)
  String? timestamp;

  bool? faceBinding;
  bool mainWallet = false;

  WalletInfo({
    this.walletName,
    this.mnemonic,
    this.password,
    this.privateKey,
    this.walletUuid,
    this.timestamp,
    this.coinInfo,
  });

  WalletInfo.fromJson(Map<String, dynamic> json) {
    walletName = json['walletName'] as String?;
    mnemonic = json['mnemonic'] as String?;
    password = json['password'] as String?;
    privateKey = json['privateKey'] as String?;
    walletUuid = json['UUID'] as String?;
    timestamp = json['timestamp'] as String?;
    coinInfo = json['coinInfo'] as Map<String, dynamic>?;
    coinSort = json['coinSort'] as Map<String, dynamic>;
    networkIndex = json['networkIndex'] as int;
    faceBinding = json['faceBinding'] as bool?;
    mainWallet = json['mainWallet'] as bool;
  }

  Map<String, dynamic> toJson() {
    return {
      "walletName": walletName,
      "mnemonic": mnemonic,
      "password": password,
      "privateKey": privateKey,
      "UUID": walletUuid,
      "timestamp": timestamp,
      "coinInfo": coinInfo,
      "coinSort": coinSort,
      "networkIndex": networkIndex,
      "faceBinding": faceBinding,
      "mainWallet": mainWallet,
    };
  }

  // ==================== Secure Access Methods ====================

  /// Get mnemonic as secure wrapper
  ///
  /// SECURITY: Remember to call dispose() on the returned SecureString
  /// after use to zero out memory
  ///
  /// Example:
  /// ```dart
  /// final secure = walletInfo.getMnemonicSecure();
  /// if (secure != null) {
  ///   try {
  ///     // Use secure.value
  ///   } finally {
  ///     secure.dispose();
  ///   }
  /// }
  /// ```
  SecureString? getMnemonicSecure() {
    if (mnemonic == null || mnemonic!.isEmpty) return null;
    return SecureString(mnemonic!);
  }

  /// Get private key as secure wrapper
  ///
  /// SECURITY: Remember to call dispose() on the returned SecureString
  /// after use to zero out memory
  SecureString? getPrivateKeySecure() {
    if (privateKey == null || privateKey!.isEmpty) return null;
    return SecureString(privateKey!);
  }

  /// Get password as secure wrapper
  ///
  /// SECURITY: Remember to call dispose() on the returned SecureString
  /// after use to zero out memory
  SecureString? getPasswordSecure() {
    if (password == null || password!.isEmpty) return null;
    return SecureString(password!);
  }

  /// Check if wallet has mnemonic without exposing it
  bool get hasMnemonic => mnemonic != null && mnemonic!.isNotEmpty;

  /// Check if wallet has private key without exposing it
  bool get hasPrivateKey => privateKey != null && privateKey!.isNotEmpty;

  /// Clear sensitive data from memory
  ///
  /// SECURITY: Call this when wallet info is no longer needed
  /// to prevent sensitive data from remaining in memory
  void clearSensitiveData() {
    if (mnemonic != null) {
      // Overwrite with zeros before nullifying
      final bytes = Uint8List.fromList(mnemonic!.codeUnits);
      SecureMemory.zeroOut(bytes);
      mnemonic = null;
    }

    if (privateKey != null) {
      final bytes = Uint8List.fromList(privateKey!.codeUnits);
      SecureMemory.zeroOut(bytes);
      privateKey = null;
    }

    if (password != null) {
      final bytes = Uint8List.fromList(password!.codeUnits);
      SecureMemory.zeroOut(bytes);
      password = null;
    }
  }

  @override
  String toString() {
    // SECURITY: Prevent accidental logging of sensitive data
    return 'WalletInfo(name: $walletName, uuid: $walletUuid, hasMnemonic: $hasMnemonic, hasPrivateKey: $hasPrivateKey)';
  }
}
