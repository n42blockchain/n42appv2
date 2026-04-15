// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';

import 'package:web3dart/web3dart.dart' show hexToBytes;

/// Social recovery module for AA smart accounts.
///
/// Allows users to designate trusted guardians who can collectively
/// recover access to a smart account if the primary signer (EOA/Passkey)
/// is lost. Implements M-of-N threshold recovery with time-lock delay.
///
/// Architecture:
/// - Recovery config stored on-chain in the smart account's guardian module
/// - Guardians are identified by their Ethereum addresses
/// - Recovery process has a mandatory time-lock delay (default 48 hours)
///   to allow the legitimate owner to cancel a malicious recovery attempt
///
/// Compatible account types:
/// - Safe (native guardian/module support)
/// - Biconomy Nexus (ERC-7579 module)
/// - SimpleAccount (via custom guardian extension)
class SocialRecoveryService {
  SocialRecoveryService._();

  /// Default time-lock delay for recovery execution (48 hours).
  static const Duration defaultTimeLock = Duration(hours: 48);

  /// Minimum number of guardians required.
  static const int minGuardians = 2;

  /// Maximum number of guardians supported.
  static const int maxGuardians = 10;

  /// Social Recovery Module contract addresses by chain ID.
  /// These are the deployed guardian module contracts.
  static const Map<int, String> moduleAddresses = {
    // Addresses will be populated after contract deployment
    // 1: '0x...', // Ethereum mainnet
    // 8453: '0x...', // Base
    // 42161: '0x...', // Arbitrum
  };

  /// Validate a recovery configuration before submitting on-chain.
  static RecoveryValidation validateConfig(RecoveryConfig config) {
    final errors = <String>[];

    if (config.guardians.length < minGuardians) {
      errors.add('At least $minGuardians guardians required (have ${config.guardians.length})');
    }
    if (config.guardians.length > maxGuardians) {
      errors.add('Maximum $maxGuardians guardians allowed (have ${config.guardians.length})');
    }
    if (config.threshold < 1) {
      errors.add('Threshold must be at least 1');
    }
    if (config.threshold > config.guardians.length) {
      errors.add('Threshold (${config.threshold}) cannot exceed guardian count (${config.guardians.length})');
    }
    if (config.timeLockSeconds < 3600) {
      errors.add('Time-lock must be at least 1 hour');
    }

    // Check for duplicate guardians
    final unique = config.guardians.map((g) => g.address.toLowerCase()).toSet();
    if (unique.length != config.guardians.length) {
      errors.add('Duplicate guardian addresses found');
    }

    // Check that owner is not a guardian
    if (config.ownerAddress != null) {
      final ownerLower = config.ownerAddress!.toLowerCase();
      if (config.guardians.any((g) => g.address.toLowerCase() == ownerLower)) {
        errors.add('Account owner cannot be a guardian');
      }
    }

    return RecoveryValidation(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Build the calldata to install the social recovery module on a smart account.
  ///
  /// For Safe accounts, this adds the guardian module as a Safe module.
  /// For ERC-7579 accounts, this installs a validator module.
  static Uint8List buildInstallCalldata({
    required RecoveryConfig config,
    required String smartAccountAddress,
    required int chainId,
  }) {
    // ABI encode the guardian configuration
    // initData: abi.encode(address[] guardians, uint256 threshold, uint256 timeLock)
    final guardianAddresses = config.guardians
        .map((g) => g.address)
        .toList();

    // Simplified ABI encoding — in production use proper ABI encoder
    final encoded = _abiEncodeRecoveryConfig(
      guardians: guardianAddresses,
      threshold: config.threshold,
      timeLockSeconds: config.timeLockSeconds,
    );

    return encoded;
  }

  /// Build calldata to initiate a recovery process.
  ///
  /// A guardian calls this to propose a new owner for the account.
  /// Other guardians then confirm. After threshold is met and time-lock
  /// expires, the recovery can be executed.
  static Uint8List buildInitiateRecoveryCalldata({
    required String smartAccountAddress,
    required String newOwnerAddress,
  }) {
    // function initiateRecovery(address account, address newOwner)
    // selector: keccak256("initiateRecovery(address,address)")[:4]
    final selector = hexToBytes('e9413d38');
    final accountBytes = _addressToBytes32(smartAccountAddress);
    final newOwnerBytes = _addressToBytes32(newOwnerAddress);

    final result = Uint8List(4 + 64);
    result.setAll(0, selector);
    result.setAll(4, accountBytes);
    result.setAll(36, newOwnerBytes);
    return result;
  }

  /// Build calldata for a guardian to confirm a pending recovery.
  static Uint8List buildConfirmRecoveryCalldata({
    required String smartAccountAddress,
  }) {
    // function confirmRecovery(address account)
    final selector = hexToBytes('78e3214e');
    final accountBytes = _addressToBytes32(smartAccountAddress);

    final result = Uint8List(4 + 32);
    result.setAll(0, selector);
    result.setAll(4, accountBytes);
    return result;
  }

  /// Build calldata to execute a recovery after time-lock expires.
  static Uint8List buildExecuteRecoveryCalldata({
    required String smartAccountAddress,
  }) {
    // function executeRecovery(address account)
    final selector = hexToBytes('5680e691');
    final accountBytes = _addressToBytes32(smartAccountAddress);

    final result = Uint8List(4 + 32);
    result.setAll(0, selector);
    result.setAll(4, accountBytes);
    return result;
  }

  /// Build calldata for the legitimate owner to cancel a pending recovery.
  static Uint8List buildCancelRecoveryCalldata({
    required String smartAccountAddress,
  }) {
    // function cancelRecovery(address account)
    final selector = hexToBytes('b80c2046');
    final accountBytes = _addressToBytes32(smartAccountAddress);

    final result = Uint8List(4 + 32);
    result.setAll(0, selector);
    result.setAll(4, accountBytes);
    return result;
  }

  // ==================== Internal ====================

  static Uint8List _abiEncodeRecoveryConfig({
    required List<String> guardians,
    required int threshold,
    required int timeLockSeconds,
  }) {
    final numGuardians = guardians.length;
    final totalSize = 96 + 32 + numGuardians * 32;
    final result = Uint8List(totalSize);

    _writeUint256(result, 0, BigInt.from(96));
    _writeUint256(result, 32, BigInt.from(threshold));
    _writeUint256(result, 64, BigInt.from(timeLockSeconds));
    _writeUint256(result, 96, BigInt.from(numGuardians));
    for (var i = 0; i < numGuardians; i++) {
      final addrBytes = _addressToBytes32(guardians[i]);
      result.setAll(128 + i * 32, addrBytes);
    }

    return result;
  }

  static Uint8List _addressToBytes32(String address) {
    final result = Uint8List(32);
    final hex = address.replaceFirst('0x', '').padLeft(40, '0');
    final addrBytes = hexToBytes(hex);
    result.setAll(12, addrBytes);
    return result;
  }

  static void _writeUint256(Uint8List buffer, int offset, BigInt value) {
    var v = value;
    for (var i = 31; i >= 0; i--) {
      buffer[offset + i] = (v & BigInt.from(0xFF)).toInt();
      v >>= 8;
    }
  }
}

/// Recovery configuration for a smart account.
class RecoveryConfig {
  /// List of guardian addresses and labels.
  final List<Guardian> guardians;

  /// Number of guardian confirmations required to execute recovery (M of N).
  final int threshold;

  /// Time-lock delay in seconds before recovery can be executed.
  /// Gives the legitimate owner time to cancel a malicious recovery.
  final int timeLockSeconds;

  /// The smart account owner address (for validation).
  final String? ownerAddress;

  RecoveryConfig({
    required this.guardians,
    required this.threshold,
    this.timeLockSeconds = 172800, // 48 hours
    this.ownerAddress,
  });

  /// Suggested threshold: ceil(guardians.length / 2) + 1 for strong security.
  static int suggestedThreshold(int guardianCount) {
    if (guardianCount <= 2) return guardianCount;
    return (guardianCount ~/ 2) + 1;
  }

  factory RecoveryConfig.fromJson(Map<String, dynamic> json) {
    return RecoveryConfig(
      guardians: (json['guardians'] as List<dynamic>)
          .map((g) => Guardian.fromJson(g as Map<String, dynamic>))
          .toList(),
      threshold: json['threshold'] as int,
      timeLockSeconds: json['timeLockSeconds'] as int? ?? 172800,
      ownerAddress: json['ownerAddress'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'guardians': guardians.map((g) => g.toJson()).toList(),
        'threshold': threshold,
        'timeLockSeconds': timeLockSeconds,
        'ownerAddress': ownerAddress,
      };
}

/// A guardian for social recovery.
class Guardian {
  /// Guardian's Ethereum address.
  final String address;

  /// Human-readable label (e.g., friend's name, device name).
  final String label;

  /// How the guardian was discovered (chat friend, manual entry, etc.).
  final GuardianSource source;

  /// When this guardian was added.
  final DateTime addedAt;

  Guardian({
    required this.address,
    required this.label,
    this.source = GuardianSource.manual,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      address: json['address'] as String,
      label: json['label'] as String,
      source: GuardianSource.fromString(json['source'] as String? ?? 'manual'),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'label': label,
        'source': source.name,
        'addedAt': addedAt.toIso8601String(),
      };
}

/// How a guardian was discovered/added.
enum GuardianSource {
  /// Manually entered address.
  manual,

  /// Discovered from N42 Chat contacts.
  chatFriend,

  /// Another device owned by the user.
  ownDevice,

  /// Hardware wallet as guardian.
  hardwareWallet;

  static GuardianSource fromString(String value) {
    return GuardianSource.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => GuardianSource.manual,
    );
  }
}

/// Status of a pending recovery process.
class RecoveryStatus {
  /// New owner proposed by the recovery.
  final String newOwnerAddress;

  /// Guardians who have confirmed so far.
  final List<String> confirmedGuardians;

  /// Required number of confirmations.
  final int threshold;

  /// When the recovery was initiated.
  final DateTime initiatedAt;

  /// When the time-lock expires (recovery can be executed after this).
  final DateTime executeAfter;

  RecoveryStatus({
    required this.newOwnerAddress,
    required this.confirmedGuardians,
    required this.threshold,
    required this.initiatedAt,
    required this.executeAfter,
  });

  /// Whether enough guardians have confirmed.
  bool get hasEnoughConfirmations => confirmedGuardians.length >= threshold;

  /// Whether the time-lock has expired and recovery can be executed.
  bool get canExecute =>
      hasEnoughConfirmations && DateTime.now().isAfter(executeAfter);

  /// Remaining time until time-lock expires.
  Duration get remainingTimeLock {
    final remaining = executeAfter.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Result of recovery config validation.
class RecoveryValidation {
  final bool isValid;
  final List<String> errors;

  const RecoveryValidation({
    required this.isValid,
    required this.errors,
  });
}
