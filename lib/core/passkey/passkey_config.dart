// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Passkey (WebAuthn) configuration for N42 Wallet.
///
/// Defines the Relying Party (RP) identity and platform-specific settings
/// used during Passkey registration and authentication flows.
class PasskeyConfig {
  /// Relying Party ID — must match the domain serving
  /// `.well-known/assetlinks.json` (Android) and
  /// `apple-app-site-association` (iOS).
  static const String rpId = 'n42.ai';

  /// Relying Party display name shown in system Passkey prompts.
  static const String rpName = 'N42 Wallet';

  /// WebAuthn origin for web platform.
  /// Must be HTTPS and rpId must be a registrable suffix of this origin.
  static const String webOrigin = 'https://wallet.n42.ai';

  /// Timeout for WebAuthn operations in milliseconds.
  static const int timeout = 60000;

  /// Whether to require resident key (discoverable credential).
  /// `true` enables username-less login.
  static const bool requireResidentKey = true;

  /// Attestation preference.
  /// `none` is recommended for privacy and widest compatibility.
  static const String attestation = 'none';

  /// Authenticator attachment preference.
  /// `platform` restricts to built-in authenticators (Face ID, Windows Hello).
  /// `cross-platform` allows security keys.
  /// `null` allows both.
  static const String authenticatorAttachment = 'platform';

  /// User verification requirement.
  /// `required` ensures biometric or PIN is used.
  static const String userVerification = 'required';

  /// Supported public key algorithms in COSE format.
  /// -7 = ES256 (P-256 / secp256r1) — required for AA on-chain verification.
  /// -257 = RS256 — fallback for broader compatibility.
  static const List<Map<String, dynamic>> pubKeyCredParams = [
    {'type': 'public-key', 'alg': -7}, // ES256 (P-256)
  ];

  /// RIP-7212 P256 precompile address (deployed on Base, OP, Arbitrum, etc.)
  static const String p256PrecompileAddress =
      '0x0000000000000000000000000000000000000100';

  /// Chain IDs where RIP-7212 P256 precompile is available.
  static const Set<int> p256PrecompileChains = {
    8453, // Base
    10, // Optimism
    42161, // Arbitrum One
    534352, // Scroll
    59144, // Linea
    324, // zkSync Era
    7777777, // Zora
  };

  /// Check if a chain supports the P256 precompile natively.
  static bool hasP256Precompile(int chainId) =>
      p256PrecompileChains.contains(chainId);
}
