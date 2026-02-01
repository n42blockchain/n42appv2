// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../core/aa_config.dart';
import '../core/aa_errors.dart';
import '../models/smart_account.dart';
import '../builder/calldata_builder.dart';

/// Factory for creating and managing smart accounts
///
/// Handles address calculation, deployment status checking,
/// and account creation for different account types.
class SmartAccountFactory {
  final String _ownerAddress;
  final int _chainId;
  final AAChainConfig _config;

  SmartAccountFactory({
    required String ownerAddress,
    required int chainId,
    AAChainConfig? config,
  })  : _ownerAddress = ownerAddress.toLowerCase(),
        _chainId = chainId,
        _config = config ?? AAConfig.getChainConfig(_chainIdToSymbol(chainId))!;

  /// Get the owner address
  String get ownerAddress => _ownerAddress;

  /// Get the chain ID
  int get chainId => _chainId;

  /// Calculate the counterfactual address for a SimpleAccount
  ///
  /// Uses CREATE2 formula: keccak256(0xff ++ factory ++ salt ++ keccak256(initCode))
  /// But for SimpleAccountFactory, we can call getAddress on the factory contract.
  Future<String> calculateSimpleAccountAddress({
    BigInt? salt,
  }) async {
    final accountSalt = salt ?? BigInt.zero;

    // For SimpleAccount, the address is deterministically calculated based on:
    // 1. Factory address
    // 2. Owner address
    // 3. Salt

    // Use CREATE2 calculation
    return _calculateCreate2Address(
      factoryAddress: _config.simpleAccountFactory,
      owner: _ownerAddress,
      salt: accountSalt,
    );
  }

  /// Calculate CREATE2 address
  String _calculateCreate2Address({
    required String factoryAddress,
    required String owner,
    required BigInt salt,
  }) {
    // CREATE2 address = keccak256(0xff ++ deployer ++ salt ++ keccak256(initCode))[12:]

    // For SimpleAccount, the salt is keccak256(abi.encodePacked(owner, salt))
    final ownerBytes = hexToBytes(owner.replaceFirst('0x', '').padLeft(64, '0'));
    final saltBytes = Uint8List(32);
    final saltValueBytes = intToBytes(salt);
    saltBytes.setAll(32 - saltValueBytes.length, saltValueBytes);

    final combinedSalt = Uint8List(64);
    combinedSalt.setAll(0, ownerBytes);
    combinedSalt.setAll(32, saltBytes);
    final hashedSalt = keccak256(combinedSalt);

    // Get init code hash (this is the bytecode hash of the SimpleAccount proxy)
    // Note: This is a simplified version. In production, you'd query the actual bytecode.
    final initCodeHash = _getSimpleAccountInitCodeHash();

    // CREATE2 formula
    final data = Uint8List(1 + 20 + 32 + 32);
    data[0] = 0xff;

    final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', ''));
    data.setAll(1, factoryBytes);
    data.setAll(21, hashedSalt);
    data.setAll(53, initCodeHash);

    final addressHash = keccak256(data);
    return '0x${bytesToHex(addressHash.sublist(12))}';
  }

  /// Get the init code hash for SimpleAccount
  /// This is the keccak256 of the proxy creation code + implementation address
  Uint8List _getSimpleAccountInitCodeHash() {
    // This is a placeholder. In production, this should be the actual
    // keccak256 hash of the SimpleAccount proxy creation bytecode.
    // The exact value depends on the factory implementation.

    // For eth-infinitism SimpleAccountFactory, this is deterministic
    // based on the implementation address.
    return hexToBytes(
      '0x${'0' * 64}', // Placeholder - needs actual bytecode hash
    );
  }

  /// Create a new SmartAccount model (does not deploy on-chain)
  SmartAccount createAccount({
    required SmartAccountType type,
    BigInt? salt,
    String? label,
  }) {
    final accountSalt = salt ?? BigInt.zero;

    // Calculate address (synchronous version using simplified calculation)
    final address = _calculateSimpleAddress(accountSalt);

    return SmartAccount(
      address: address,
      type: type,
      ownerAddress: _ownerAddress,
      state: SmartAccountState.notDeployed,
      chainId: _chainId,
      salt: accountSalt,
      factoryAddress: _config.simpleAccountFactory,
      createdAt: DateTime.now(),
      label: label,
    );
  }

  /// Simplified address calculation for sync usage
  String _calculateSimpleAddress(BigInt salt) {
    // Simplified CREATE2-like calculation
    // In production, this should match the factory's getAddress function

    final ownerBytes = hexToBytes(_ownerAddress.replaceFirst('0x', '').padLeft(40, '0'));
    final saltBytes = Uint8List(32);
    final saltValueBytes = intToBytes(salt);
    if (saltValueBytes.isNotEmpty) {
      saltBytes.setAll(32 - saltValueBytes.length, saltValueBytes);
    }

    // Combine factory + owner + salt for deterministic address
    final combined = Uint8List(20 + 20 + 32);
    final factoryBytes = hexToBytes(_config.simpleAccountFactory.replaceFirst('0x', ''));
    combined.setAll(0, factoryBytes);
    combined.setAll(20, ownerBytes);
    combined.setAll(40, saltBytes);

    final hash = keccak256(combined);
    return '0x${bytesToHex(hash.sublist(12))}';
  }

  /// Get init code for deploying a SimpleAccount
  Uint8List getInitCode({
    BigInt? salt,
  }) {
    final accountSalt = salt ?? BigInt.zero;

    return CalldataBuilder.buildSimpleAccountInitCode(
      factoryAddress: _config.simpleAccountFactory,
      owner: _ownerAddress,
      salt: accountSalt,
    );
  }

  /// Check if account is deployed at the given address
  /// This should be called via RPC (eth_getCode)
  static bool isDeployed(String? code) {
    if (code == null) return false;
    final cleaned = code.replaceFirst('0x', '');
    return cleaned.isNotEmpty && cleaned != '0' && cleaned != '00';
  }

  /// Create SmartAccount from existing data
  static SmartAccount fromExisting({
    required String address,
    required String ownerAddress,
    required int chainId,
    SmartAccountType type = SmartAccountType.simpleAccount,
    SmartAccountState state = SmartAccountState.deployed,
    BigInt? salt,
    String? factoryAddress,
    String? label,
  }) {
    final config = AAConfig.getChainConfig(_chainIdToSymbol(chainId));
    if (config == null) {
      throw AAUnsupportedChainError(_chainIdToSymbol(chainId));
    }

    return SmartAccount(
      address: address.toLowerCase(),
      type: type,
      ownerAddress: ownerAddress.toLowerCase(),
      state: state,
      chainId: chainId,
      salt: salt ?? BigInt.zero,
      factoryAddress: factoryAddress ?? config.simpleAccountFactory,
      createdAt: DateTime.now(),
      label: label,
    );
  }

  /// Convert chain ID to symbol
  static String _chainIdToSymbol(int chainId) {
    final entry = AAConfig.chainIds.entries.firstWhere(
      (e) => e.value == chainId,
      orElse: () => const MapEntry('UNKNOWN', 0),
    );
    return entry.key;
  }
}

/// Extension methods for SmartAccount
extension SmartAccountExtension on SmartAccount {
  /// Get init code if account needs deployment
  Uint8List? getInitCodeIfNeeded() {
    if (!needsDeployment) return null;

    return CalldataBuilder.buildSimpleAccountInitCode(
      factoryAddress: factoryAddress,
      owner: ownerAddress,
      salt: salt,
    );
  }

  /// Update state based on on-chain code check
  SmartAccount updateDeploymentState(bool isDeployed) {
    return copyWith(
      state: isDeployed
          ? SmartAccountState.deployed
          : SmartAccountState.notDeployed,
      lastActivityAt: isDeployed ? DateTime.now() : null,
    );
  }

  /// Mark as deploying
  SmartAccount markDeploying() {
    return copyWith(state: SmartAccountState.deploying);
  }

  /// Mark deployment as failed
  SmartAccount markDeploymentFailed() {
    return copyWith(state: SmartAccountState.error);
  }
}
