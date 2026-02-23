// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../core/aa_config.dart';

/// Helper for Safe (Gnosis Safe v1.4.1) account type.
///
/// Implements the counterfactual address computation using the CREATE2 formula
/// as defined by SafeProxyFactory v1.4.1:
///   - CREATE2 salt = keccak256(keccak256(initializer) ++ bytes32(saltNonce))
///   - initCode     = SafeProxy.creationCode ++ abi.encode(singleton)
///   - address      = keccak256(0xff ++ factory ++ salt ++ keccak256(initCode))[12:]
///
/// Singleton:  SafeL2 v1.4.1  — 0x29fcB43b46531BcA003ddC8FCB67FFE91900C762
/// Factory:    SafeProxyFactory v1.4.1 — 0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67
/// FallbackH:  CompatibilityFallbackHandler v1.4.1 — 0xfd0732Dc9E303f09fCEf3a7388Ad10A83459Ec99
class SafeAccountHelper {
  final String factoryAddress;
  final String singletonAddress;
  final String fallbackHandlerAddress;
  final String entryPointAddress;

  SafeAccountHelper({
    required this.factoryAddress,
    required this.singletonAddress,
    required this.fallbackHandlerAddress,
    required this.entryPointAddress,
  });

  /// Create from chain configuration.
  factory SafeAccountHelper.fromChain(String chainSymbol) {
    final config = AAConfig.getChainConfig(chainSymbol);
    if (config == null) {
      throw ArgumentError('Unsupported chain: $chainSymbol');
    }
    return SafeAccountHelper(
      factoryAddress: config.safeFactory ?? AAConfig.safeProxyFactory,
      singletonAddress: AAConfig.safeL2Singleton,
      fallbackHandlerAddress: AAConfig.safeFallbackHandler,
      entryPointAddress: config.entryPoint,
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Compute the counterfactual Safe address via the CREATE2 formula.
  ///
  /// Internally fetches [proxyCreationCode()] from the factory via eth_call,
  /// then applies the Safe-specific CREATE2 formula.
  /// Returns `null` if the RPC call fails.
  Future<String?> computeAddress({
    required String owner,
    required BigInt saltNonce,
    required String rpcUrl,
  }) async {
    try {
      // Step 1: Fetch SafeProxy.creationCode from factory
      final creationCode = await _fetchProxyCreationCode(rpcUrl);
      if (creationCode == null) return null;

      // Step 2: initCode = creationCode ++ uint256(uint160(singleton))
      //         This matches: abi.encodePacked(type(SafeProxy).creationCode, uint256(uint160(_singleton)))
      final singletonPadded = _addressAsUint256(singletonAddress);
      final initCode = Uint8List(creationCode.length + 32);
      initCode.setAll(0, creationCode);
      initCode.setAll(creationCode.length, singletonPadded);
      final initCodeHash = keccak256(initCode);

      // Step 3: Build the setup() calldata — this is the "initializer"
      final initializer = _buildSetupCalldata(owner: owner);

      // Step 4: CREATE2 salt = keccak256(keccak256(initializer) ++ bytes32(saltNonce))
      final saltPreimage = Uint8List(64);
      saltPreimage.setAll(0, keccak256(initializer));
      saltPreimage.setAll(32, _uint256ToBytes32(saltNonce));
      final create2Salt = keccak256(saltPreimage);

      // Step 5: CREATE2 address = keccak256(0xff ++ factory ++ salt ++ initCodeHash)[12:]
      final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', '').padLeft(40, '0'));
      final data = Uint8List(1 + 20 + 32 + 32);
      data[0] = 0xff;
      data.setAll(1, factoryBytes);
      data.setAll(21, create2Salt);
      data.setAll(53, initCodeHash);

      final addressHash = keccak256(data);
      return '0x${bytesToHex(addressHash.sublist(12))}';
    } catch (e) {
      if (kDebugMode) debugPrint('[SafeAccount] computeAddress error: $e');
      return null;
    }
  }

  /// Build the initCode for inclusion in a UserOperation.
  ///
  /// Format: factory address (20 bytes) ++ createProxyWithNonce calldata
  Uint8List getInitCode({
    required String owner,
    required BigInt saltNonce,
  }) {
    final factoryBytes = hexToBytes(factoryAddress.replaceFirst('0x', '').padLeft(40, '0'));
    final calldata = _buildCreateProxyWithNonce(owner: owner, saltNonce: saltNonce);
    final result = Uint8List(20 + calldata.length);
    result.setAll(0, factoryBytes);
    result.setAll(20, calldata);
    return result;
  }

  // ── Private: ABI helpers ────────────────────────────────────────────────────

  /// Fetch SafeProxy.creationCode from SafeProxyFactory.proxyCreationCode().
  ///
  /// Returns the raw bytes of the creation code (without constructor args).
  Future<Uint8List?> _fetchProxyCreationCode(String rpcUrl) async {
    // proxyCreationCode() selector = keccak256("proxyCreationCode()")[:4]
    final selectorFull = keccak256(
      Uint8List.fromList(utf8.encode('proxyCreationCode()')),
    );
    final selector = bytesToHex(selectorFull.sublist(0, 4));

    final result = await _ethCall(
      rpcUrl: rpcUrl,
      to: factoryAddress,
      data: '0x$selector',
    );
    if (result == null || result.length < 4) return null;

    // Decode ABI-encoded bytes: 32 (offset) + 32 (length) + data
    final bytes = hexToBytes(result.replaceFirst('0x', ''));
    if (bytes.length < 64) return null;

    final length = _bytesToInt(bytes.sublist(32, 64)).toInt();
    if (bytes.length < 64 + length) return null;

    return bytes.sublist(64, 64 + length);
  }

  /// Build the setup() calldata for a single-owner Safe.
  ///
  /// setup(address[] owners, uint256 threshold, address to, bytes data,
  ///       address fallbackHandler, address paymentToken, uint256 payment,
  ///       address paymentReceiver)
  ///
  /// Selector: keccak256("setup(address[],uint256,address,bytes,address,address,uint256,address)")[:4]
  ///         = 0xb63e800d
  Uint8List _buildSetupCalldata({required String owner}) {
    const selector = 'b63e800d';

    // Parameters: owners(dyn), threshold(32), to(32), data(dyn), fallbackHandler(32),
    //             paymentToken(32), payment(32), paymentReceiver(32)
    //
    // 8 head slots (32 bytes each), 2 dynamic tail sections:
    //   - owners array: 32 (length=1) + 32 (owner) = 64 bytes at offset 256
    //   - data bytes:   32 (length=0)               = 32 bytes at offset 320
    const headSize = 8 * 32; // 256
    final ownersOffset = _uint256ToBytes32(BigInt.from(headSize)); // 0x100
    final ownersData = Uint8List(64); // length=1, then owner
    _setUint256(ownersData, 0, BigInt.one); // length = 1
    _setAddress(ownersData, 32, owner); // owners[0]

    final dataOffset = _uint256ToBytes32(BigInt.from(headSize + ownersData.length)); // 0x140
    final emptyBytes = _uint256ToBytes32(BigInt.zero); // length=0

    // Build head:
    final calldata = Uint8List(4 + headSize + ownersData.length + 32);
    var pos = 0;

    calldata.setAll(pos, hexToBytes(selector)); pos += 4; // selector
    calldata.setAll(pos, ownersOffset); pos += 32;         // offset to owners
    calldata.setAll(pos, _uint256ToBytes32(BigInt.one)); pos += 32; // threshold=1
    calldata.setAll(pos, _addressToBytes32(zeroAddress)); pos += 32; // to=0x0
    calldata.setAll(pos, dataOffset); pos += 32;            // offset to data
    calldata.setAll(pos, _addressToBytes32(fallbackHandlerAddress)); pos += 32;
    calldata.setAll(pos, _addressToBytes32(zeroAddress)); pos += 32; // paymentToken
    calldata.setAll(pos, _uint256ToBytes32(BigInt.zero)); pos += 32; // payment
    calldata.setAll(pos, _addressToBytes32(zeroAddress)); pos += 32; // paymentReceiver

    // Tail:
    calldata.setAll(pos, ownersData); pos += 64; // owners array
    calldata.setAll(pos, emptyBytes);             // data length = 0

    return calldata;
  }

  /// Build createProxyWithNonce(address _singleton, bytes memory initializer, uint256 saltNonce)
  /// Selector: 0x1688f0b9
  Uint8List _buildCreateProxyWithNonce({
    required String owner,
    required BigInt saltNonce,
  }) {
    const selector = '1688f0b9';
    final initializer = _buildSetupCalldata(owner: owner);

    // Parameters: _singleton(32), initializer(dyn offset), saltNonce(32)
    // Dynamic tail: initializer bytes
    //   Head: 3 * 32 = 96 bytes
    //   initializer offset = 96
    final initializerOffset = _uint256ToBytes32(BigInt.from(3 * 32));
    final initializerLength = _uint256ToBytes32(BigInt.from(initializer.length));
    // Pad initializer to 32-byte boundary
    final padding = (32 - initializer.length % 32) % 32;
    final initializerPadded = Uint8List(initializer.length + padding);
    initializerPadded.setAll(0, initializer);

    final calldata = Uint8List(4 + 96 + 32 + initializerPadded.length);
    var pos = 0;

    calldata.setAll(pos, hexToBytes(selector)); pos += 4;
    calldata.setAll(pos, _addressToBytes32(singletonAddress)); pos += 32; // _singleton
    calldata.setAll(pos, initializerOffset); pos += 32; // offset to initializer
    calldata.setAll(pos, _uint256ToBytes32(saltNonce)); pos += 32; // saltNonce
    calldata.setAll(pos, initializerLength); pos += 32; // initializer.length
    calldata.setAll(pos, initializerPadded); // initializer data

    return calldata;
  }

  // ── Private: low-level ABI encoding ────────────────────────────────────────

  static const String zeroAddress = '0x0000000000000000000000000000000000000000';

  Uint8List _addressToBytes32(String addr) {
    final out = Uint8List(32);
    final addrBytes = hexToBytes(addr.replaceFirst('0x', '').padLeft(40, '0'));
    out.setAll(12, addrBytes);
    return out;
  }

  /// Encode an address as uint256 (right-aligned in 32 bytes) for initCode concat.
  Uint8List _addressAsUint256(String addr) {
    return _addressToBytes32(addr); // same layout: 12 zero bytes + 20 address bytes
  }

  Uint8List _uint256ToBytes32(BigInt v) {
    final out = Uint8List(32);
    final vBytes = intToBytes(v);
    if (vBytes.isNotEmpty) out.setAll(32 - vBytes.length, vBytes);
    return out;
  }

  void _setUint256(Uint8List buf, int offset, BigInt v) {
    buf.setAll(offset, _uint256ToBytes32(v));
  }

  void _setAddress(Uint8List buf, int offset, String addr) {
    buf.setAll(offset, _addressToBytes32(addr));
  }

  BigInt _bytesToInt(Uint8List b) {
    BigInt result = BigInt.zero;
    for (final byte in b) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
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

/// Gas constants for Safe operations
class SafeAccountGasConstants {
  SafeAccountGasConstants._();

  /// Overhead for Safe signature validation (1-of-1 multisig)
  static const int signatureValidation = 75000;

  /// Gas per additional signer
  static const int perSignerOverhead = 10000;

  /// Base execute overhead
  static const int executeOverhead = 45000;

  /// Deployment gas for first transaction
  static const int deploymentGas = 300000;
}
