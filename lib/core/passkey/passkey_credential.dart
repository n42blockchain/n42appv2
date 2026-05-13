// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'dart:typed_data';

/// A registered Passkey credential with its P-256 public key coordinates.
///
/// Stores both the WebAuthn credential metadata and the raw elliptic curve
/// point needed for on-chain signature verification (ERC-4337 + RIP-7212).
class PasskeyCredential {
  /// Base64URL-encoded credential ID from the authenticator.
  final String credentialId;

  /// X coordinate of the P-256 public key (32 bytes, hex-encoded).
  final String publicKeyX;

  /// Y coordinate of the P-256 public key (32 bytes, hex-encoded).
  final String publicKeyY;

  /// Relying Party ID this credential is bound to.
  final String rpId;

  /// User-assigned label (e.g., "iPhone 15 Pro", "Pixel 9").
  String label;

  /// When the credential was registered.
  final DateTime createdAt;

  /// When the credential was last used for authentication.
  DateTime? lastUsedAt;

  /// Platform the credential was created on.
  final PasskeyPlatform platform;

  /// Whether this credential is backed up (synced via iCloud/Google).
  final bool backedUp;

  PasskeyCredential({
    required this.credentialId,
    required this.publicKeyX,
    required this.publicKeyY,
    required this.rpId,
    required this.label,
    required this.createdAt,
    required this.platform,
    this.lastUsedAt,
    this.backedUp = false,
  });

  /// The full uncompressed P-256 public key (65 bytes: 0x04 || x || y).
  Uint8List get uncompressedPublicKey {
    final x = _hexToBytes(publicKeyX);
    final y = _hexToBytes(publicKeyY);
    final result = Uint8List(65);
    result[0] = 0x04;
    result.setAll(1, x);
    result.setAll(33, y);
    return result;
  }

  /// Public key X as BigInt (for on-chain encoding).
  BigInt get publicKeyXInt => BigInt.parse(publicKeyX, radix: 16);

  /// Public key Y as BigInt (for on-chain encoding).
  BigInt get publicKeyYInt => BigInt.parse(publicKeyY, radix: 16);

  /// Credential ID as raw bytes.
  Uint8List get credentialIdBytes => base64Url.decode(credentialId);

  factory PasskeyCredential.fromJson(Map<String, dynamic> json) {
    return PasskeyCredential(
      credentialId: json['credentialId'] as String,
      publicKeyX: json['publicKeyX'] as String,
      publicKeyY: json['publicKeyY'] as String,
      rpId: json['rpId'] as String,
      label: json['label'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      platform: PasskeyPlatform.fromString(json['platform'] as String),
      backedUp: json['backedUp'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'credentialId': credentialId,
      'publicKeyX': publicKeyX,
      'publicKeyY': publicKeyY,
      'rpId': rpId,
      'label': label,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'platform': platform.name,
      'backedUp': backedUp,
    };
  }

  static Uint8List _hexToBytes(String hex) {
    final h = hex.replaceFirst('0x', '');
    final padded = h.padLeft(64, '0');
    final result = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      result[i] = int.parse(padded.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  @override
  String toString() =>
      'PasskeyCredential(label: $label, platform: ${platform.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasskeyCredential && other.credentialId == credentialId;

  @override
  int get hashCode => credentialId.hashCode;
}

/// Result of a WebAuthn authentication (assertion) ceremony.
///
/// Contains all fields needed to construct a P-256 on-chain signature
/// that a smart contract can verify via RIP-7212 or a Solidity verifier.
class PasskeyAuthResult {
  /// Base64URL-encoded credential ID used.
  final String credentialId;

  /// Raw authenticatorData bytes from the assertion.
  final Uint8List authenticatorData;

  /// Raw clientDataJSON bytes from the assertion.
  final Uint8List clientDataJSON;

  /// P-256 signature r component (32 bytes, big-endian).
  final BigInt r;

  /// P-256 signature s component (32 bytes, big-endian).
  final BigInt s;

  /// Byte offset where the challenge value content starts in [clientDataJSON].
  ///
  /// Points to the byte **immediately after** the opening `"` of the
  /// `"challenge"` field's value. Consumed by the EIP-7212 / P-256 WebAuthn
  /// verifier contract to re-parse the user-operation hash on-chain.
  ///
  /// See [PasskeyPlatformAdapter._jsonStringValueStart] for the parsing
  /// contract — the offset semantics must match the on-chain reader byte-for-
  /// byte or AA signature verification will silently accept arbitrary
  /// challenges.
  final int challengeIndex;

  /// Byte offset where the type value content starts in [clientDataJSON].
  ///
  /// Same semantics as [challengeIndex]: points to the first byte after the
  /// opening `"` of the `"type"` field's value. The verifier contract uses
  /// this to assert `type == "webauthn.get"`.
  final int typeIndex;

  PasskeyAuthResult({
    required this.credentialId,
    required this.authenticatorData,
    required this.clientDataJSON,
    required this.r,
    required this.s,
    required this.challengeIndex,
    required this.typeIndex,
  });

  /// The challenge that was signed, extracted from clientDataJSON.
  String get challenge {
    final json = utf8.decode(clientDataJSON);
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map['challenge'] as String;
  }
}

/// Platform where a Passkey was created.
enum PasskeyPlatform {
  android,
  ios,
  macos,
  web,
  windows;

  static PasskeyPlatform fromString(String value) {
    return PasskeyPlatform.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PasskeyPlatform.android,
    );
  }
}

// SignerType is defined in smart_account.dart to avoid circular imports.
// Import from: package:n42_wallet/features/wallet/aa/models/smart_account.dart
