// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:n42_wallet/core/config/proxy_config.dart';

import '../core/aa_config.dart';
import '../core/aa_constants.dart';
import '../core/aa_errors.dart';
import '../models/user_operation.dart';
import '../models/user_operation_receipt.dart';

/// Client for interacting with ERC-4337 Bundler APIs
///
/// Implements the standard Bundler RPC methods:
/// - eth_sendUserOperation
/// - eth_estimateUserOperationGas
/// - eth_getUserOperationByHash
/// - eth_getUserOperationReceipt
/// - eth_supportedEntryPoints
///
/// Supports both v0.7 and v0.8 EntryPoint versions.
class BundlerClient {
  final String _bundlerUrl;
  final String _entryPoint;
  final String? _apiKey;
  final http.Client _httpClient;
  final Duration _timeout;
  final EntryPointVersion _version;

  int _requestId = 0;

  BundlerClient({
    required String bundlerUrl,
    required String entryPoint,
    String? apiKey,
    http.Client? httpClient,
    Duration? timeout,
    EntryPointVersion? version,
  })  : _bundlerUrl = bundlerUrl,
        _entryPoint = entryPoint,
        _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(milliseconds: AAConstants.bundlerRpcTimeout),
        _version = version ?? AAConfig.defaultVersion;

  /// Create a BundlerClient for a specific chain
  factory BundlerClient.forChain(
    String chainSymbol, {
    String? apiKey,
    EntryPointVersion? version,
  }) {
    final config = AAConfig.getChainConfig(chainSymbol, version: version);
    if (config == null) {
      throw AAUnsupportedChainError(chainSymbol);
    }

    final url = config.bundlerUrl;

    return BundlerClient(
      bundlerUrl: url,
      entryPoint: config.entryPoint,
      apiKey: apiKey,
      version: version ?? config.version,
    );
  }

  /// Create a BundlerClient for v0.8 EntryPoint
  factory BundlerClient.v08(String chainSymbol, {String? apiKey}) {
    return BundlerClient.forChain(
      chainSymbol,
      apiKey: apiKey,
      version: EntryPointVersion.v08,
    );
  }

  /// Create a BundlerClient for v0.7 EntryPoint (legacy)
  factory BundlerClient.v07(String chainSymbol, {String? apiKey}) {
    return BundlerClient.forChain(
      chainSymbol,
      apiKey: apiKey,
      version: EntryPointVersion.v07,
    );
  }

  /// Get the entry point address
  String get entryPoint => _entryPoint;

  /// Get the EntryPoint version
  EntryPointVersion get version => _version;

  /// Check if this client supports EIP-7702
  bool get supportsEIP7702 => _version == EntryPointVersion.v08;

  /// Send a UserOperation to the bundler
  ///
  /// Returns the UserOperation hash if successful.
  Future<String> sendUserOperation(UserOperation userOp) async {
    final result = await _rpcCall(
      'eth_sendUserOperation',
      [userOp.toJson(version: _version), _entryPoint],
    );

    if (result is String) {
      return result;
    }

    throw BundlerRpcError(
      'Invalid response from sendUserOperation',
      method: 'eth_sendUserOperation',
      details: result.toString(),
    );
  }

  /// Estimate gas for a UserOperation
  ///
  /// Returns gas estimates for verification, call, and pre-verification.
  Future<GasEstimateResult> estimateUserOperationGas(UserOperation userOp) async {
    final result = await _rpcCall(
      'eth_estimateUserOperationGas',
      [userOp.toJson(version: _version), _entryPoint],
    );

    if (result is Map<String, dynamic>) {
      return GasEstimateResult.fromJson(result);
    }

    throw GasEstimationError(
      'Invalid response from estimateUserOperationGas',
      details: result.toString(),
    );
  }

  /// Get a UserOperation by its hash
  Future<UserOperation?> getUserOperationByHash(String userOpHash) async {
    return _safeRpcQuery('eth_getUserOperationByHash', [userOpHash], (result) {
      if (result is Map<String, dynamic>) {
        final userOp = result['userOperation'];
        if (userOp is Map<String, dynamic>) {
          return UserOperation.fromJson(userOp);
        }
      }
      return null;
    });
  }

  /// Get the receipt for a UserOperation
  Future<UserOperationReceipt?> getUserOperationReceipt(String userOpHash) async {
    return _safeRpcQuery('eth_getUserOperationReceipt', [userOpHash], (result) {
      if (result is Map<String, dynamic>) {
        return UserOperationReceipt.fromJson(result);
      }
      return null;
    });
  }

  /// Shared helper for nullable RPC queries with error suppression
  Future<T?> _safeRpcQuery<T>(
    String method,
    List<dynamic> params,
    T? Function(dynamic result) parse,
  ) async {
    try {
      final result = await _rpcCall(method, params);
      if (result == null) return null;
      return parse(result);
    } catch (e) {
      assert(() {
        debugPrint('$method error: $e');
        return true;
      }());
      return null;
    }
  }

  /// Get supported entry points
  Future<List<String>> getSupportedEntryPoints() async {
    final result = await _rpcCall('eth_supportedEntryPoints', []);

    if (result is List) {
      return result.map((e) => e.toString()).toList();
    }

    return [_entryPoint];
  }

  /// Get the chain ID from the bundler
  Future<BigInt> getChainId() async {
    final result = await _rpcCall('eth_chainId', []);

    if (result is String) {
      return BigInt.parse(result.replaceFirst('0x', ''), radix: 16);
    }

    throw BundlerRpcError('Invalid chain ID response');
  }

  /// Wait for a UserOperation to be included in a block
  ///
  /// Polls for the receipt until it's available or timeout is reached.
  Future<UserOperationReceipt> waitForReceipt(
    String userOpHash, {
    Duration? timeout,
    Duration? pollingInterval,
  }) async {
    final waitTimeout = timeout ?? const Duration(milliseconds: AAConstants.confirmationTimeout);
    final interval = pollingInterval ?? const Duration(milliseconds: AAConstants.receiptPollingInterval);

    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < waitTimeout) {
      final receipt = await getUserOperationReceipt(userOpHash);

      if (receipt != null) {
        return receipt;
      }

      await Future.delayed(interval);
    }

    throw ReceiptTimeoutError(userOpHash);
  }

  /// Make an RPC call to the bundler
  Future<dynamic> _rpcCall(String method, List<dynamic> params) async {
    final requestId = ++_requestId;

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'id': requestId,
      'method': method,
      'params': params,
    });

    try {
      final response = await _httpClient
          .post(
            Uri.parse(_bundlerUrl),
            headers: ProxyConfig.mergeAuthHeaders(_bundlerUrl, {
              'Content-Type': 'application/json',
              if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
            }),
            body: body,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw BundlerRpcError(
          'HTTP error ${response.statusCode}',
          method: method,
          details: response.body,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json.containsKey('error')) {
        throw json.toAAError();
      }

      return json['result'];
    } on TimeoutException {
      throw BundlerRpcError(
        'Request timeout',
        method: method,
      );
    } catch (e) {
      if (e is AAError) rethrow;
      throw BundlerRpcError(
        e.toString(),
        method: method,
      );
    }
  }

  /// Close the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Result of gas estimation
class GasEstimateResult {
  /// Verification gas limit
  final BigInt verificationGasLimit;

  /// Call gas limit
  final BigInt callGasLimit;

  /// Pre-verification gas
  final BigInt preVerificationGas;

  /// Paymaster verification gas (if paymaster is used)
  final BigInt? paymasterVerificationGasLimit;

  /// Paymaster post-op gas (if paymaster is used)
  final BigInt? paymasterPostOpGasLimit;

  const GasEstimateResult({
    required this.verificationGasLimit,
    required this.callGasLimit,
    required this.preVerificationGas,
    this.paymasterVerificationGasLimit,
    this.paymasterPostOpGasLimit,
  });

  factory GasEstimateResult.fromJson(Map<String, dynamic> json) {
    return GasEstimateResult(
      verificationGasLimit: _parseBigInt(json['verificationGasLimit']),
      callGasLimit: _parseBigInt(json['callGasLimit']),
      preVerificationGas: _parseBigInt(json['preVerificationGas']),
      paymasterVerificationGasLimit: json['paymasterVerificationGasLimit'] != null
          ? _parseBigInt(json['paymasterVerificationGasLimit'])
          : null,
      paymasterPostOpGasLimit: json['paymasterPostOpGasLimit'] != null
          ? _parseBigInt(json['paymasterPostOpGasLimit'])
          : null,
    );
  }

  static BigInt _parseBigInt(dynamic value) {
    if (value == null) return BigInt.zero;
    if (value is BigInt) return value;
    if (value is int) return BigInt.from(value);
    final str = value.toString();
    if (str.startsWith('0x')) {
      return BigInt.parse(str.substring(2), radix: 16);
    }
    return BigInt.parse(str);
  }

  /// Apply a buffer multiplier to gas estimates
  GasEstimateResult withBuffer(double multiplier) {
    final mult = BigInt.from((multiplier * 100).round());
    final div = BigInt.from(100);
    BigInt applyBuffer(BigInt v) => v * mult ~/ div;
    BigInt? applyOptional(BigInt? v) => v != null ? applyBuffer(v) : null;

    return GasEstimateResult(
      verificationGasLimit: applyBuffer(verificationGasLimit),
      callGasLimit: applyBuffer(callGasLimit),
      preVerificationGas: applyBuffer(preVerificationGas),
      paymasterVerificationGasLimit: applyOptional(paymasterVerificationGasLimit),
      paymasterPostOpGasLimit: applyOptional(paymasterPostOpGasLimit),
    );
  }

  /// Get total gas estimate
  BigInt get totalGas {
    return verificationGasLimit +
        callGasLimit +
        preVerificationGas +
        (paymasterVerificationGasLimit ?? BigInt.zero) +
        (paymasterPostOpGasLimit ?? BigInt.zero);
  }

  /// Apply estimates to a UserOperation
  UserOperation applyTo(UserOperation userOp) {
    return userOp.copyWith(
      accountGasLimits: PackedGasLimits.pack(verificationGasLimit, callGasLimit),
      preVerificationGas: preVerificationGas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verificationGasLimit': '0x${verificationGasLimit.toRadixString(16)}',
      'callGasLimit': '0x${callGasLimit.toRadixString(16)}',
      'preVerificationGas': '0x${preVerificationGas.toRadixString(16)}',
      if (paymasterVerificationGasLimit != null)
        'paymasterVerificationGasLimit': '0x${paymasterVerificationGasLimit!.toRadixString(16)}',
      if (paymasterPostOpGasLimit != null)
        'paymasterPostOpGasLimit': '0x${paymasterPostOpGasLimit!.toRadixString(16)}',
    };
  }

  @override
  String toString() {
    return 'GasEstimateResult(verification: $verificationGasLimit, call: $callGasLimit, preVerification: $preVerificationGas)';
  }
}

/// Builder for creating BundlerClient with configuration
class BundlerClientBuilder {
  String? _chainSymbol;
  String? _bundlerUrl;
  String? _entryPoint;
  String? _apiKey;
  Duration? _timeout;
  bool _useBackup = false;
  EntryPointVersion? _version;

  BundlerClientBuilder forChain(String chainSymbol) {
    _chainSymbol = chainSymbol;
    return this;
  }

  BundlerClientBuilder withUrl(String url) {
    _bundlerUrl = url;
    return this;
  }

  BundlerClientBuilder withEntryPoint(String entryPoint) {
    _entryPoint = entryPoint;
    return this;
  }

  BundlerClientBuilder withApiKey(String apiKey) {
    _apiKey = apiKey;
    return this;
  }

  BundlerClientBuilder withTimeout(Duration timeout) {
    _timeout = timeout;
    return this;
  }

  BundlerClientBuilder useBackupBundler(bool useBackup) {
    _useBackup = useBackup;
    return this;
  }

  BundlerClientBuilder withVersion(EntryPointVersion version) {
    _version = version;
    return this;
  }

  BundlerClient build() {
    final version = _version ?? AAConfig.defaultVersion;

    // Direct URL + entryPoint configuration
    if (_bundlerUrl != null && _entryPoint != null) {
      return BundlerClient(
        bundlerUrl: _bundlerUrl!,
        entryPoint: _entryPoint!,
        apiKey: _apiKey,
        timeout: _timeout,
        version: version,
      );
    }

    // Chain-based configuration
    final symbol = _chainSymbol;
    if (symbol == null) {
      throw AAConfigurationError('Either chain symbol or bundler URL must be provided');
    }

    final config = AAConfig.getChainConfig(symbol, version: version);
    if (config == null) {
      throw AAUnsupportedChainError(symbol);
    }

    final url = _useBackup && config.backupBundlerUrl != null
        ? config.backupBundlerUrl!
        : config.bundlerUrl;

    return BundlerClient(
      bundlerUrl: url,
      entryPoint: config.entryPoint,
      apiKey: _apiKey,
      timeout: _timeout,
      version: config.version,
    );
  }
}
