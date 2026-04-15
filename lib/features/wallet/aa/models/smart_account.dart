// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// Signer type for AA smart accounts.
enum SignerType {
  /// Traditional EOA signer (secp256k1).
  eoa,

  /// Passkey signer (P-256 / secp256r1 via WebAuthn).
  passkey,

  /// MPC signer (key shares via Web3Auth or similar).
  mpc;

  static SignerType fromString(String value) {
    return SignerType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SignerType.eoa,
    );
  }
}

/// Smart Account model for ERC-4337 Account Abstraction
///
/// Represents a smart contract wallet that can be controlled by an EOA owner
/// or a Passkey signer (P-256).
class SmartAccount {
  /// Smart account address (counterfactual or deployed)
  final String address;

  /// Account type (e.g., SimpleAccount, Safe, Kernel)
  final SmartAccountType type;

  /// Owner EOA address that controls this smart account
  final String ownerAddress;

  /// Current deployment state
  SmartAccountState state;

  /// Chain ID where this account exists/will exist
  final int chainId;

  /// Salt used for address derivation (usually owner's nonce)
  final BigInt salt;

  /// Factory address used to deploy this account
  final String factoryAddress;

  /// Optional list of guardian addresses for social recovery
  List<String>? guardians;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last activity timestamp
  DateTime? lastActivityAt;

  /// Account label/name for UI display
  String? label;

  /// Signer type (EOA, Passkey, or MPC)
  final SignerType signerType;

  /// Passkey credential ID (when signerType == passkey)
  final String? passkeyCredentialId;

  /// Passkey P-256 public key X coordinate (hex, when signerType == passkey)
  final String? passkeyPublicKeyX;

  /// Passkey P-256 public key Y coordinate (hex, when signerType == passkey)
  final String? passkeyPublicKeyY;

  SmartAccount({
    required this.address,
    required this.type,
    required this.ownerAddress,
    required this.state,
    required this.chainId,
    required this.salt,
    required this.factoryAddress,
    this.guardians,
    required this.createdAt,
    this.lastActivityAt,
    this.label,
    this.signerType = SignerType.eoa,
    this.passkeyCredentialId,
    this.passkeyPublicKeyX,
    this.passkeyPublicKeyY,
  });

  /// Check if account is deployed on-chain
  bool get isDeployed => state == SmartAccountState.deployed;

  /// Check if account needs deployment
  bool get needsDeployment => state == SmartAccountState.notDeployed;

  /// Get display name
  String get displayName => label ?? '${type.name} Account';

  /// Get short address for display
  String get shortAddress {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Whether this account uses a Passkey signer.
  bool get isPasskeySigner => signerType == SignerType.passkey;

  factory SmartAccount.fromJson(Map<String, dynamic> json) {
    return SmartAccount(
      address: json['address'] as String,
      type: SmartAccountType.fromString(json['type'] as String),
      ownerAddress: json['ownerAddress'] as String,
      state: SmartAccountState.fromString(json['state'] as String),
      chainId: json['chainId'] as int,
      salt: BigInt.parse(json['salt'] as String),
      factoryAddress: json['factoryAddress'] as String,
      guardians: (json['guardians'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt'] as String)
          : null,
      label: json['label'] as String?,
      signerType: json['signerType'] != null
          ? SignerType.fromString(json['signerType'] as String)
          : SignerType.eoa,
      passkeyCredentialId: json['passkeyCredentialId'] as String?,
      passkeyPublicKeyX: json['passkeyPublicKeyX'] as String?,
      passkeyPublicKeyY: json['passkeyPublicKeyY'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'type': type.name,
      'ownerAddress': ownerAddress,
      'state': state.name,
      'chainId': chainId,
      'salt': salt.toString(),
      'factoryAddress': factoryAddress,
      'guardians': guardians,
      'createdAt': createdAt.toIso8601String(),
      'lastActivityAt': lastActivityAt?.toIso8601String(),
      'label': label,
      'signerType': signerType.name,
      if (passkeyCredentialId != null) 'passkeyCredentialId': passkeyCredentialId,
      if (passkeyPublicKeyX != null) 'passkeyPublicKeyX': passkeyPublicKeyX,
      if (passkeyPublicKeyY != null) 'passkeyPublicKeyY': passkeyPublicKeyY,
    };
  }

  SmartAccount copyWith({
    String? address,
    SmartAccountType? type,
    String? ownerAddress,
    SmartAccountState? state,
    int? chainId,
    BigInt? salt,
    String? factoryAddress,
    List<String>? guardians,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? label,
    SignerType? signerType,
    String? passkeyCredentialId,
    String? passkeyPublicKeyX,
    String? passkeyPublicKeyY,
  }) {
    return SmartAccount(
      address: address ?? this.address,
      type: type ?? this.type,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      state: state ?? this.state,
      chainId: chainId ?? this.chainId,
      salt: salt ?? this.salt,
      factoryAddress: factoryAddress ?? this.factoryAddress,
      guardians: guardians ?? this.guardians,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      label: label ?? this.label,
      signerType: signerType ?? this.signerType,
      passkeyCredentialId: passkeyCredentialId ?? this.passkeyCredentialId,
      passkeyPublicKeyX: passkeyPublicKeyX ?? this.passkeyPublicKeyX,
      passkeyPublicKeyY: passkeyPublicKeyY ?? this.passkeyPublicKeyY,
    );
  }

  @override
  String toString() {
    return 'SmartAccount(address: $shortAddress, type: ${type.name}, state: ${state.name}, chainId: $chainId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartAccount &&
        other.address.toLowerCase() == address.toLowerCase() &&
        other.chainId == chainId;
  }

  @override
  int get hashCode => address.toLowerCase().hashCode ^ chainId.hashCode;
}

/// Smart account types
enum SmartAccountType {
  /// SimpleAccount from eth-infinitism
  simpleAccount,

  /// Simple7702Account - EIP-7702 hybrid EOA/smart account (v0.8)
  /// Allows EOA to temporarily act as a smart account
  simple7702Account,

  /// Safe (Gnosis Safe) multisig
  safe,

  /// Kernel from ZeroDev
  kernel,

  /// Biconomy modular account
  biconomy,

  /// Custom account implementation
  custom;

  static SmartAccountType fromString(String value) {
    return SmartAccountType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SmartAccountType.custom,
    );
  }

  /// Get human-readable name
  String get displayName {
    switch (this) {
      case SmartAccountType.simpleAccount:
        return 'Simple Account';
      case SmartAccountType.simple7702Account:
        return 'EIP-7702 Account';
      case SmartAccountType.safe:
        return 'Safe';
      case SmartAccountType.kernel:
        return 'Kernel';
      case SmartAccountType.biconomy:
        return 'Biconomy';
      case SmartAccountType.custom:
        return 'Custom';
    }
  }

  /// Check if this account type requires v0.8 EntryPoint
  bool get requiresV08 => this == SmartAccountType.simple7702Account;

  /// Check if this is an EIP-7702 based account
  bool get isEIP7702 => this == SmartAccountType.simple7702Account;
}

/// Smart account deployment state
enum SmartAccountState {
  /// Address calculated but not deployed
  notDeployed,

  /// Deployment transaction pending
  deploying,

  /// Successfully deployed on-chain
  deployed,

  /// Deployment failed
  error;

  static SmartAccountState fromString(String value) {
    return SmartAccountState.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SmartAccountState.notDeployed,
    );
  }

  /// Check if account can execute transactions
  bool get canExecute => this == SmartAccountState.deployed;

  /// Check if account needs first-time deployment
  bool get needsInitCode => this == SmartAccountState.notDeployed;
}

/// Smart account information stored in wallet
class AAAccountInfo {
  /// Smart accounts organized by chain ID
  final Map<int, List<SmartAccount>> smartAccounts;

  /// Whether to prefer AA for transfers
  bool preferAA;

  /// Default paymaster addresses by chain ID
  Map<int, String>? defaultPaymasters;

  AAAccountInfo({
    required this.smartAccounts,
    this.preferAA = false,
    this.defaultPaymasters,
  });

  /// Get smart accounts for a specific chain
  List<SmartAccount> getAccountsForChain(int chainId) {
    return smartAccounts[chainId] ?? [];
  }

  /// Get the primary smart account for a chain
  SmartAccount? getPrimaryAccount(int chainId) {
    final accounts = getAccountsForChain(chainId);
    return accounts.isNotEmpty ? accounts.first : null;
  }

  /// Add a smart account
  void addAccount(SmartAccount account) {
    smartAccounts.putIfAbsent(account.chainId, () => []);
    smartAccounts[account.chainId]!.add(account);
  }

  /// Remove a smart account
  bool removeAccount(String address, int chainId) {
    final accounts = smartAccounts[chainId];
    if (accounts == null) return false;
    final lowerAddress = address.toLowerCase();
    final index = accounts.indexWhere(
      (a) => a.address.toLowerCase() == lowerAddress,
    );
    if (index < 0) return false;
    accounts.removeAt(index);
    return true;
  }

  /// Find account by address across all chains
  SmartAccount? findAccount(String address) {
    final lowerAddress = address.toLowerCase();
    for (final accounts in smartAccounts.values) {
      for (final account in accounts) {
        if (account.address.toLowerCase() == lowerAddress) {
          return account;
        }
      }
    }
    return null;
  }

  factory AAAccountInfo.fromJson(Map<String, dynamic> json) {
    final rawAccounts = json['smartAccounts'] as Map<String, dynamic>?;
    final accountsMap = rawAccounts?.map(
      (key, value) => MapEntry(
        int.parse(key),
        (value as List<dynamic>)
            .map((e) => SmartAccount.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    ) ?? {};

    final rawPaymasters = json['defaultPaymasters'] as Map<String, dynamic>?;
    final paymasters = rawPaymasters?.map(
      (key, value) => MapEntry(int.parse(key), value as String),
    );

    return AAAccountInfo(
      smartAccounts: accountsMap,
      preferAA: json['preferAA'] as bool? ?? false,
      defaultPaymasters: paymasters?.isNotEmpty == true ? paymasters : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smartAccounts': smartAccounts.map(
        (key, value) => MapEntry(key.toString(), value.map((a) => a.toJson()).toList()),
      ),
      'preferAA': preferAA,
      'defaultPaymasters': defaultPaymasters?.map(
        (key, value) => MapEntry(key.toString(), value),
      ) ?? <String, String>{},
    };
  }

  /// Get total number of smart accounts across all chains
  int get totalAccounts {
    return smartAccounts.values.fold(0, (sum, list) => sum + list.length);
  }
}
