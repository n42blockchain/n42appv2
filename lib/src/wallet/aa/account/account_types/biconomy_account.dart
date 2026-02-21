// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../core/aa_config.dart';

/// Helper for Biconomy Nexus v1 (ERC-7579 modular) account type.
///
/// Architecture:
///   NexusAccountFactory (0x0000000000BBc222D4Ca2ae6c3a42b9B5E1Ca3F0)
///   └─ createAccount(initData, salt) → deploys Nexus proxy via ERC-1967 CREATE2
///   └─ computeAccountAddress(initData, salt) → view, returns expected address
///
/// The initData is passed to Nexus.initializeAccount(bytes data), which does:
///   (bootstrap, bootstrapCall) = abi.decode(data, (address, bytes))
///   bootstrap.delegatecall(bootstrapCall)
///
/// For single EOA owner via K1Validator:
///   bootstrap     = NexusBootstrap
///   bootstrapCall = NexusBootstrap.initNexusWithSingleValidator(BootstrapConfig)
///   BootstrapConfig = {module: K1Validator, initData: abi.encode(ownerAddr)}
///
/// Deployed addresses (same across all EVM chains):
///   NexusFactory  : 0x0000000000BBc222D4Ca2ae6c3a42b9B5E1Ca3F0
///   K1Validator   : 0x0000002D6DB27c52E3C11c1Cf24072004AC75cBa
///   NexusBootstrap: 0x6D1DaD347A3E0C0A74B73A29Cfa9bE7A1Ac8a39C
class BiconomyAccountHelper {
  // NexusBootstrap v1.0.0 — same address on all EVM chains
  static const String nexusBootstrapAddress =
      '0x6D1DaD347A3E0C0A74B73A29Cfa9bE7A1Ac8a39C';

  final String factoryAddress;
  final String k1ValidatorAddress;
  final String entryPointAddress;

  BiconomyAccountHelper({
    required this.factoryAddress,
    required this.k1ValidatorAddress,
    required this.entryPointAddress,
  });

  /// Create from chain configuration.
  factory BiconomyAccountHelper.fromChain(String chainSymbol) {
    final config = AAConfig.getChainConfig(chainSymbol);
    if (config == null) {
      throw ArgumentError('Unsupported chain: $chainSymbol');
    }
    return BiconomyAccountHelper(
      factoryAddress: config.biconomyFactory ?? AAConfig.biconomyNexusFactory,
      k1ValidatorAddress: AAConfig.biconomyK1Validator,
      entryPointAddress: config.entryPoint,
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Compute the counterfactual Nexus account address via factory eth_call.
  ///
  /// Calls factory.computeAccountAddress(initData, salt) view function.
  /// Returns `null` if the RPC call fails.
  Future<String?> computeAddress({
    required String owner,
    required BigInt salt,
    required String rpcUrl,
  }) async {
    try {
      final initData = buildInitData(owner: owner);
      final saltBytes = _uint256ToBytes32(salt);

      // computeAccountAddress(bytes calldata initData, bytes32 salt)
      // selector = keccak256("computeAccountAddress(bytes,bytes32)")[:4]
      final selectorFull = keccak256(
        Uint8List.fromList(utf8.encode('computeAccountAddress(bytes,bytes32)')),
      );
      final selector = bytesToHex(selectorFull.sublist(0, 4));

      // ABI encode: (bytes initData, bytes32 salt)
      //   head: offset to initData (32) + salt (32) = 64 bytes
      //   tail: length + initData + padding
      final offsetToInitData = _uint256ToBytes32(BigInt.from(64));
      final initDataLength = _uint256ToBytes32(BigInt.from(initData.length));
      final padding = (32 - initData.length % 32) % 32;
      final initDataPadded = Uint8List(initData.length + padding);
      initDataPadded.setAll(0, initData);

      final calldata = Uint8List(4 + 32 + 32 + 32 + initDataPadded.length);
      var pos = 0;
      calldata.setAll(pos, hexToBytes(selector)); pos += 4;
      calldata.setAll(pos, offsetToInitData); pos += 32;
      calldata.setAll(pos, saltBytes); pos += 32;
      calldata.setAll(pos, initDataLength); pos += 32;
      calldata.setAll(pos, initDataPadded);

      final result = await _ethCall(
        rpcUrl: rpcUrl,
        to: factoryAddress,
        data: '0x${bytesToHex(calldata)}',
      );
      if (result == null || result.length < 66) return null;

      // Returns abi.encode(address): 32-byte padded address
      final resultBytes = hexToBytes(result.replaceFirst('0x', ''));
      if (resultBytes.length < 32) return null;

      // Address is right-aligned in 32-byte word (bytes[12:32])
      return '0x${bytesToHex(resultBytes.sublist(12, 32))}';
    } catch (e) {
      if (kDebugMode) debugPrint('[BiconomyAccount] computeAddress error: $e');
      return null;
    }
  }

  /// Build the initData for Nexus.initializeAccount(bytes).
  ///
  /// initData = abi.encode(bootstrapAddress, bootstrapCalldata)
  /// bootstrapCalldata = initNexusWithSingleValidator(BootstrapConfig({k1Validator, abi.encode(owner)}))
  Uint8List buildInitData({required String owner}) {
    final bootstrapCalldata = _buildInitNexusWithSingleValidatorCalldata(owner: owner);

    // abi.encode(address bootstrap, bytes bootstrapCalldata)
    //   head: offset to bootstrap(32) + offset to bootstrapCalldata(32) = 64 bytes
    //   but address is static (32) while bytes is dynamic
    // Correct layout:
    //   [0:32]   bootstrap address (static, padded)
    //   [32:64]  offset to bootstrapCalldata = 64
    //   [64:96]  bootstrapCalldata length
    //   [96:...]  bootstrapCalldata data + padding

    final bootstrapPadded = _addressToBytes32(nexusBootstrapAddress);
    final calldataOffset = _uint256ToBytes32(BigInt.from(64));
    final calldataLength = _uint256ToBytes32(BigInt.from(bootstrapCalldata.length));
    final padding = (32 - bootstrapCalldata.length % 32) % 32;
    final calldataPadded = Uint8List(bootstrapCalldata.length + padding);
    calldataPadded.setAll(0, bootstrapCalldata);

    final result = Uint8List(32 + 32 + 32 + calldataPadded.length);
    var pos = 0;
    result.setAll(pos, bootstrapPadded); pos += 32;
    result.setAll(pos, calldataOffset); pos += 32;
    result.setAll(pos, calldataLength); pos += 32;
    result.setAll(pos, calldataPadded);

    return result;
  }

  /// Build initCode for inclusion in a UserOperation.
  ///
  /// Format: factory address (20 bytes) ++ createAccount calldata
  Uint8List getInitCode({
    required String owner,
    required BigInt salt,
  }) {
    final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', '').padLeft(40, '0'));
    final calldata = _buildCreateAccountCalldata(owner: owner, salt: salt);
    final result = Uint8List(20 + calldata.length);
    result.setAll(0, factoryBytes);
    result.setAll(20, calldata);
    return result;
  }

  // ── Private: calldata builders ──────────────────────────────────────────────

  /// Build NexusBootstrap.initNexusWithSingleValidator(BootstrapConfig validator) calldata.
  ///
  /// BootstrapConfig = struct { address module; bytes initData; }
  /// selector = keccak256("initNexusWithSingleValidator((address,bytes))")[:4]
  Uint8List _buildInitNexusWithSingleValidatorCalldata({required String owner}) {
    // selector
    final selectorFull = keccak256(
      Uint8List.fromList(utf8.encode('initNexusWithSingleValidator((address,bytes))')),
    );
    final selector = selectorFull.sublist(0, 4);

    // BootstrapConfig = (address module, bytes initData)
    // As a tuple in ABI:
    //   head of struct: module(32) + offset to initData (from start of struct) = 64
    //   tail: initData.length=20 + ownerAddr bytes + padding
    //
    // The outer call takes one (address,bytes) struct as dynamic parameter,
    // so the outer layout is:
    //   [0:32]  offset to struct = 32
    //   [32:64] struct.module (address, static)
    //   [64:96] offset to struct.initData (from start of struct) = 64
    //   [96:128] struct.initData.length = 32 (abi.encode(address) = 32 bytes)
    //   [128:160] struct.initData[0..31] = ownerAddr right-padded

    final ownerEncoded = _addressToBytes32(owner);
    // initData for K1Validator = abi.encode(ownerAddress) = 32 bytes
    final validatorInitData = ownerEncoded; // abi.encode(address) is 32 bytes

    // struct BootstrapConfig in memory:
    //   offset to struct from outer param head = 32
    //   struct layout:
    //     module (address,static) at offset 0  within struct = 32 bytes
    //     offset to initData within struct      = 64 (pointing past the two 32-byte head slots)
    //     initData.length = 32
    //     initData data   = validatorInitData (32 bytes)
    final structModule = _addressToBytes32(k1ValidatorAddress);
    const structInitDataRelOffset = 64; // 2 * 32 bytes past struct start
    final structInitDataLength = _uint256ToBytes32(BigInt.from(32)); // abi.encode(address) = 32

    final calldata = Uint8List(4 + 5 * 32);
    var pos = 0;
    calldata.setAll(pos, selector); pos += 4;
    calldata.setAll(pos, _uint256ToBytes32(BigInt.from(32))); pos += 32; // offset to struct
    calldata.setAll(pos, structModule); pos += 32;            // struct.module
    calldata.setAll(pos, _uint256ToBytes32(BigInt.from(structInitDataRelOffset))); pos += 32; // relative offset
    calldata.setAll(pos, structInitDataLength); pos += 32;   // initData.length
    calldata.setAll(pos, validatorInitData);                  // initData bytes

    return calldata;
  }

  /// Build factory.createAccount(bytes initData, bytes32 salt) calldata.
  /// selector = keccak256("createAccount(bytes,bytes32)")[:4]
  Uint8List _buildCreateAccountCalldata({
    required String owner,
    required BigInt salt,
  }) {
    final selectorFull = keccak256(
      Uint8List.fromList(utf8.encode('createAccount(bytes,bytes32)')),
    );
    final selector = selectorFull.sublist(0, 4);

    final initData = buildInitData(owner: owner);
    final saltBytes = _uint256ToBytes32(salt);

    // (bytes initData, bytes32 salt)
    //   head: offset to initData = 64, salt = static 32
    final initDataOffset = _uint256ToBytes32(BigInt.from(64));
    final initDataLength = _uint256ToBytes32(BigInt.from(initData.length));
    final padding = (32 - initData.length % 32) % 32;
    final initDataPadded = Uint8List(initData.length + padding);
    initDataPadded.setAll(0, initData);

    final calldata = Uint8List(4 + 32 + 32 + 32 + initDataPadded.length);
    var pos = 0;
    calldata.setAll(pos, selector); pos += 4;
    calldata.setAll(pos, initDataOffset); pos += 32;
    calldata.setAll(pos, saltBytes); pos += 32;
    calldata.setAll(pos, initDataLength); pos += 32;
    calldata.setAll(pos, initDataPadded);

    return calldata;
  }

  // ── Private: ABI encoding utilities ────────────────────────────────────────

  Uint8List _addressToBytes32(String addr) {
    final out = Uint8List(32);
    final addrBytes = hexToBytes(addr.replaceFirst('0x', '').padLeft(40, '0'));
    out.setAll(12, addrBytes);
    return out;
  }

  Uint8List _uint256ToBytes32(BigInt v) {
    final out = Uint8List(32);
    final vBytes = intToBytes(v);
    if (vBytes.isNotEmpty) out.setAll(32 - vBytes.length, vBytes);
    return out;
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
    } catch (_) {
      return null;
    }
  }
}

/// Gas constants for Biconomy Nexus account operations.
class BiconomyAccountGasConstants {
  BiconomyAccountGasConstants._();

  /// Overhead for K1Validator signature check
  static const int signatureValidation = 60000;

  /// Base execute overhead (ERC-7579 execute)
  static const int executeOverhead = 50000;

  /// Deployment gas (includes Nexus initialization)
  static const int deploymentGas = 400000;
}
