// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../core/aa_config.dart';
import '../core/aa_errors.dart';
import '../models/smart_account.dart';
import '../builder/calldata_builder.dart';
import 'account_types/safe_account.dart';
import 'account_types/biconomy_account.dart';

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

  /// Calculate the counterfactual address for a SimpleAccount.
  ///
  /// Uses eth_call to factory.getAddress(owner, salt) via the bundler RPC,
  /// which is the most reliable method.
  Future<String> calculateSimpleAccountAddress({
    BigInt? salt,
  }) async {
    final accountSalt = salt ?? BigInt.zero;
    final rpcUrl = _config.bundlerUrl;

    final calldata = CalldataBuilder.buildGetAddress(
      owner: _ownerAddress,
      salt: accountSalt,
    );
    final result = await _ethCall(
      rpcUrl: rpcUrl,
      to: _config.simpleAccountFactory,
      data: '0x${bytesToHex(calldata)}',
    );

    if (result != null && result.length >= 66) {
      final bytes = hexToBytes(result.replaceFirst('0x', ''));
      if (bytes.length >= 32) {
        return '0x${bytesToHex(bytes.sublist(12, 32))}';
      }
    }

    // Fallback: approximate local calculation
    return _calculateSimpleAddress(accountSalt);
  }

  /// Compute the counterfactual address for ANY supported account type.
  ///
  /// Uses type-specific helpers and RPC calls. Returns null if RPC fails.
  Future<String?> computeAddressForType(
    SmartAccountType type, {
    BigInt? salt,
  }) async {
    final accountSalt = salt ?? BigInt.zero;
    final rpcUrl = _config.bundlerUrl;

    switch (type) {
      case SmartAccountType.simpleAccount:
        return calculateSimpleAccountAddress(salt: accountSalt);

      case SmartAccountType.simple7702Account:
        // EIP-7702: the smart account address IS the EOA address
        return _ownerAddress;

      case SmartAccountType.safe:
        final helper = SafeAccountHelper(
          factoryAddress: _config.safeFactory ?? AAConfig.safeProxyFactory,
          singletonAddress: AAConfig.safeL2Singleton,
          fallbackHandlerAddress: AAConfig.safeFallbackHandler,
          entryPointAddress: _config.entryPoint,
        );
        return helper.computeAddress(
          owner: _ownerAddress,
          saltNonce: accountSalt,
          rpcUrl: rpcUrl,
        );

      case SmartAccountType.biconomy:
        final helper = BiconomyAccountHelper(
          factoryAddress: _config.biconomyFactory ?? AAConfig.biconomyNexusFactory,
          k1ValidatorAddress: AAConfig.biconomyK1Validator,
          entryPointAddress: _config.entryPoint,
        );
        return helper.computeAddress(
          owner: _ownerAddress,
          salt: accountSalt,
          rpcUrl: rpcUrl,
        );

      case SmartAccountType.kernel:
      case SmartAccountType.custom:
        return null; // Not yet implemented
    }
  }

  /// Create a new SmartAccount model (does not deploy on-chain).
  ///
  /// [address] must be provided when calling from the create page
  /// (already computed via [computeAddressForType]). Falls back to the local
  /// SimpleAccount approximation if not supplied.
  SmartAccount createAccount({
    required SmartAccountType type,
    String? address,
    BigInt? salt,
    String? label,
  }) {
    final accountSalt = salt ?? BigInt.zero;

    final resolvedAddress = address ?? _calculateSimpleAddress(accountSalt);
    final factoryAddr = _factoryAddressForType(type);

    return SmartAccount(
      address: resolvedAddress,
      type: type,
      ownerAddress: _ownerAddress,
      state: SmartAccountState.notDeployed,
      chainId: _chainId,
      salt: accountSalt,
      factoryAddress: factoryAddr,
      createdAt: DateTime.now(),
      label: label,
    );
  }

  /// Return the appropriate factory address for a given account type.
  String _factoryAddressForType(SmartAccountType type) {
    switch (type) {
      case SmartAccountType.simpleAccount:
        return _config.simpleAccountFactory;
      case SmartAccountType.simple7702Account:
        return AAConfig.simple7702AccountFactory;
      case SmartAccountType.safe:
        return _config.safeFactory ?? AAConfig.safeProxyFactory;
      case SmartAccountType.biconomy:
        return _config.biconomyFactory ?? AAConfig.biconomyNexusFactory;
      case SmartAccountType.kernel:
      case SmartAccountType.custom:
        return _config.simpleAccountFactory;
    }
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
  Uint8List getInitCode({BigInt? salt}) {
    return CalldataBuilder.buildSimpleAccountInitCode(
      factoryAddress: _config.simpleAccountFactory,
      owner: _ownerAddress,
      salt: salt ?? BigInt.zero,
    );
  }

  // ── Private: eth_call ───────────────────────────────────────────────────────

  static Future<String?> _ethCall({
    required String rpcUrl,
    required String to,
    required String data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'eth_call',
          'params': [
            {'to': to, 'data': data},
            'latest',
          ],
        }),
      );
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.containsKey('error')) return null;
      final result = json['result'];
      return result is String ? result : null;
    } catch (e) {
      if (kDebugMode) debugPrint('[SmartAccountFactory] ethCall error: $e');
      return null;
    }
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
