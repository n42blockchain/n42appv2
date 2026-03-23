import 'package:n42_wallet/core/wallet_sdk/wallet_address.dart';
import 'package:n42_wallet/core/wallet_sdk/wallet_key_manager.dart';
import 'package:n42_wallet/core/wallet_sdk/wallet_signer.dart';
import 'package:n42_wallet/features/wallet/provider/trustdart.dart';

export 'models/wallet_sdk_models.dart';
export 'wallet_address.dart';
export 'wallet_key_manager.dart';
export 'wallet_signer.dart';

/// Unified Wallet SDK entry point.
///
/// Provides type-safe access to wallet-core operations through sub-modules:
/// - [keyManager] — Mnemonic generation/validation, HD key derivation, keystore
/// - [address] — Address generation, validation, chain-specific utilities
/// - [signer] — Transaction signing (all chains), message signing
///
/// ## Architecture
///
/// ```
/// Business Layer (Providers, Pages, Handlers)
///        │
///        ▼
///   ┌─────────────────────────┐
///   │      WalletSdk          │  ← Type-safe Dart API
///   │  ┌───────┬────────┬───┐ │
///   │  │KeyMgr │Address │Sign│ │
///   │  └───┬───┴────┬───┴─┬─┘ │
///   │      │        │     │   │
///   │      ▼        ▼     ▼   │
///   │     Trustdart (MethodChannel) │
///   └─────────────────────────┘
///        │
///        ▼
///   Native (Android/iOS) wallet-core
/// ```
///
/// ## Responsibility boundary
///
/// **WalletSdk (wallet-core)**: key derivation, transaction signing, address generation
/// **web3dart**: ABI encoding/decoding, contract call building, gas estimation, nonce mgmt
/// **TokenView API**: on-chain data queries, transaction broadcasting
class WalletSdk {
  final Trustdart _trustdart;

  late final WalletKeyManager keyManager;
  late final WalletAddress address;
  late final WalletSigner signer;

  WalletSdk({Trustdart? trustdart}) : _trustdart = trustdart ?? Trustdart() {
    keyManager = WalletKeyManager(_trustdart);
    address = WalletAddress(_trustdart);
    signer = WalletSigner(_trustdart);
  }

  /// Access to the underlying [Trustdart] MethodChannel wrapper.
  ///
  /// Use this only for operations not yet covered by the SDK sub-modules
  /// (e.g. LiveActivity, Permissions). Prefer the typed sub-module APIs
  /// for all wallet-core operations.
  Trustdart get raw => _trustdart;
}
