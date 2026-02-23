// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';
import 'dart:typed_data';

import 'package:n42appv2/core/security/tx_simulation_result.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';

/// Simulates an EVM transaction via `eth_call` to detect reverts before signing.
///
/// Flow:
/// 1. `eth_call` — detects reverts and returns success/reverted/unavailable
/// 2. `eth_estimateGas` — best-effort gas estimate attached to success result
///
/// Only EVM-compatible chains are supported (blockchainType == "Ethereum").
/// Other chains immediately return [TxSimulationResult.unavailable] without
/// making any network request.
class TxSimulationService {
  TxSimulationService._();

  static const Duration _callTimeout = Duration(seconds: 10);
  static const Duration _gasTimeout = Duration(seconds: 5);

  /// Simulate [to]/[data]/[value] as sent from [from] on the chain identified
  /// by [coinType].
  ///
  /// Returns:
  /// - [TxSimulationResult.success] — `eth_call` returned without revert;
  ///   [TxSimulationResult.gasEstimate] is set when `eth_estimateGas` succeeded
  /// - [TxSimulationResult.reverted] — execution would revert;
  ///   [TxSimulationResult.revertReason] is populated when decodable
  /// - [TxSimulationResult.unavailable] — network / timeout / non-revert RPC error
  static Future<TxSimulationResult> simulate({
    required String coinType,
    required String from,
    required String to,
    String data = '0x',
    BigInt? value,
    bool isTest = false,
  }) async {
    if (coinType.isEmpty || to.isEmpty) {
      return TxSimulationResult.unavailable();
    }

    final params = <String, dynamic>{
      'from': from,
      'to': to,
      'data': data.isEmpty ? '0x' : data,
    };
    if (value != null && value > BigInt.zero) {
      params['value'] = '0x${value.toRadixString(16)}';
    }

    // ── Step 1: eth_call — detects reverts ──────────────────────────────────
    final Result<dynamic, AppError> callResult;
    try {
      callResult = await EthAPI()
          .baseRPCEth(
            'eth_call',
            [params, 'latest'],
            coinType: coinType,
            isTest: isTest,
            enableRetry: false,
          )
          .timeout(_callTimeout);
    } catch (_) {
      // TimeoutException or unexpected local error
      return TxSimulationResult.unavailable();
    }

    if (callResult.isFailure) {
      final error = callResult.errorOrNull!;
      // Only treat the error as a revert when the RPC explicitly signals
      // execution failure (code 3 or Geth-style -32000 with "revert" message).
      // Other codes (-32602 invalid params, -32603 internal error, etc.) mean
      // the simulation itself couldn't run → show unavailable, not "will fail".
      if (error is BlockchainError && _isExecutionRevert(error)) {
        return TxSimulationResult.reverted(_extractRevertReason(error));
      }
      return TxSimulationResult.unavailable();
    }

    // ── Step 2: eth_estimateGas — best-effort, never blocks result ───────────
    final gasEstimate = await _estimateGas(params, coinType, isTest);
    return TxSimulationResult.success(gasEstimate: gasEstimate);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Returns true when the [BlockchainError] represents a genuine EVM execution
  /// revert, as opposed to an RPC infrastructure error.
  ///
  /// JSON-RPC error codes:
  ///   3       — EIP-1474 execution error (Infura, Alchemy, most public nodes)
  ///  -32000   — Geth/go-ethereum style execution error
  ///  -32602   — Invalid params  → not a revert
  ///  -32603   — Internal error  → not a revert
  static bool _isExecutionRevert(BlockchainError error) {
    final original = error.originalError;
    if (original is Map) {
      final code = original['code'];
      if (code == 3) return true; // EIP-1474 execution error
      if (code == -32000) {
        // Geth-style: confirm via message content
        return error.message.toLowerCase().contains('revert');
      }
      // Any other structured code is an infrastructure error
      if (code is int) return false;
    }
    // Unstructured error: fall back to message heuristic
    final msg = error.message.toLowerCase();
    return msg.contains('execution reverted') || msg.contains('revert reason:');
  }

  /// Best-effort `eth_estimateGas` call. Returns null on any failure.
  static Future<BigInt?> _estimateGas(
    Map<String, dynamic> params,
    String coinType,
    bool isTest,
  ) async {
    try {
      final result = await EthAPI()
          .baseRPCEth(
            'eth_estimateGas',
            [params, 'latest'],
            coinType: coinType,
            isTest: isTest,
            enableRetry: false,
          )
          .timeout(_gasTimeout);

      if (result.isSuccess) {
        final hex = result.valueOrNull?.toString() ?? '';
        if (hex.startsWith('0x') && hex.length > 2) {
          return BigInt.tryParse(hex.substring(2), radix: 16);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Extract a human-readable revert reason from an RPC blockchain error.
  ///
  /// Priority:
  /// 1. Decode ABI-encoded revert data from `error.data` hex field
  ///    (Error(string) 0x08c379a0 / Panic(uint256) 0x4e487b71)
  /// 2. Strip "execution reverted:" prefix from [error.message]
  /// 3. Return null — card will show generic "Transaction will likely fail"
  static String? _extractRevertReason(BlockchainError error) {
    // 1. Try ABI-encoded data attached to the JSON-RPC error object
    final originalError = error.originalError;
    if (originalError is Map) {
      final rawData = originalError['data'];
      // data may be a String or absent; guard type
      if (rawData is String) {
        final decoded = _decodeRevertData(rawData);
        if (decoded != null) return decoded;
      }
    }

    // 2. Parse human-readable message from EVM node
    final msg = error.message;
    const prefix = 'execution reverted:';
    if (msg.toLowerCase().contains(prefix)) {
      final idx = msg.toLowerCase().indexOf(prefix);
      final reason = msg.substring(idx + prefix.length).trim();
      return reason.isNotEmpty ? reason : null;
    }
    if (msg.toLowerCase().contains('revert')) {
      return msg;
    }

    return null;
  }

  /// Decode ABI-encoded revert data:
  ///   Error(string)  — selector 0x08c379a0
  ///   Panic(uint256) — selector 0x4e487b71
  static String? _decodeRevertData(String hexData) {
    if (hexData.length < 10) return null;
    final clean = hexData.startsWith('0x') ? hexData.substring(2) : hexData;
    if (clean.length < 8) return null;

    final selector = clean.substring(0, 8).toLowerCase();

    // Error(string) ─ ABI layout: selector(4) | offset(32) | length(32) | string
    if (selector == '08c379a0') {
      try {
        // Need at least: selector(8) + offset(64) + length(64) = 136 chars
        if (clean.length < 136) return null;
        final lengthHex = clean.substring(8 + 64, 8 + 128);
        final length = int.parse(lengthHex, radix: 16);
        // Validate bounds before slicing
        final required = 8 + 128 + length * 2;
        if (clean.length < required || length > 4096) return null;
        final stringHex = clean.substring(8 + 128, required);
        final bytes = Uint8List.fromList(
          List.generate(
            length,
            (i) => int.parse(stringHex.substring(i * 2, i * 2 + 2), radix: 16),
          ),
        );
        return utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        return null;
      }
    }

    // Panic(uint256) ─ ABI layout: selector(4) | code(32)
    if (selector == '4e487b71') {
      try {
        if (clean.length < 72) return null;
        final panicCode = int.parse(clean.substring(8, 72), radix: 16);
        return _panicCodeToMessage(panicCode);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static String _panicCodeToMessage(int code) {
    const messages = <int, String>{
      0x00: 'Generic panic',
      0x01: 'Assertion failed',
      0x11: 'Arithmetic overflow / underflow',
      0x12: 'Division or modulo by zero',
      0x21: 'Invalid enum value',
      0x22: 'Corrupt storage byte array',
      0x31: 'Pop on empty array',
      0x32: 'Array index out of bounds',
      0x41: 'Out of memory',
      0x51: 'Invalid function pointer',
    };
    return messages[code] ?? 'Panic(0x${code.toRadixString(16)})';
  }
}
