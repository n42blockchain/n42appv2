// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';
import 'dart:typed_data';

import 'package:n42appv2/core/security/tx_simulation_result.dart';
import 'package:n42appv2/core/utils/result.dart';
import 'package:n42appv2/src/wallet/api/chain_api/eth_api.dart';

/// Simulates an EVM transaction via `eth_call` to detect reverts before signing.
///
/// Only EVM-compatible chains are supported. Other chains immediately return
/// [TxSimulationResult.unavailable] without making any network request.
class TxSimulationService {
  TxSimulationService._();

  static const Duration _timeout = Duration(seconds: 10);

  /// Simulate [to]/[data]/[value] as sent from [from] on the chain identified
  /// by [coinType].
  ///
  /// Returns:
  /// - [TxSimulationResult.success] — `eth_call` returned without revert
  /// - [TxSimulationResult.reverted] — `eth_call` reverted; [TxSimulationResult.revertReason] may be populated
  /// - [TxSimulationResult.unavailable] — network error / timeout / non-EVM chain
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
      // eth_call expects value as a hex string prefixed with 0x
      params['value'] = '0x${value.toRadixString(16)}';
    }

    try {
      final result = await EthAPI()
          .baseRPCEth(
            'eth_call',
            [params, 'latest'],
            coinType: coinType,
            isTest: isTest,
            enableRetry: false,
          )
          .timeout(_timeout);

      return result.when(
        success: (_) => TxSimulationResult.success(),
        failure: (error) {
          // BlockchainError from baseRPCEth means the RPC returned an error
          // object, which for eth_call means the tx reverted.
          if (error is BlockchainError) {
            final reason = _extractRevertReason(error);
            return TxSimulationResult.reverted(reason);
          }
          // NetworkError / other → degraded gracefully
          return TxSimulationResult.unavailable();
        },
      );
    } catch (_) {
      // Timeout or unexpected exception
      return TxSimulationResult.unavailable();
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Extract a human-readable revert reason from an RPC blockchain error.
  ///
  /// Priority:
  /// 1. Decode ABI-encoded revert data from `error.data` hex field
  ///    (Error(string) selector 0x08c379a0 / Panic(uint256) selector 0x4e487b71)
  /// 2. Strip "execution reverted:" prefix from [error.message]
  /// 3. Fall back to the raw message
  static String? _extractRevertReason(BlockchainError error) {
    // 1. Try to decode the `data` field attached to the JSON-RPC error object
    final originalError = error.originalError;
    if (originalError is Map) {
      final hexData = originalError['data']?.toString() ?? '';
      final decoded = _decodeRevertData(hexData);
      if (decoded != null) return decoded;
    }

    // 2. Parse human-readable message produced by most EVM nodes
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

  /// Decode ABI-encoded revert data.
  ///
  /// Handles:
  /// - `Error(string)`  — selector `0x08c379a0`
  /// - `Panic(uint256)` — selector `0x4e487b71`
  static String? _decodeRevertData(String hexData) {
    if (hexData.length < 10) return null; // need at least selector (4 bytes = 8 hex + 0x)
    final clean = hexData.startsWith('0x') ? hexData.substring(2) : hexData;
    if (clean.length < 8) return null;

    final selector = clean.substring(0, 8).toLowerCase();

    // Error(string) — most common
    if (selector == '08c379a0' && clean.length >= 136) {
      try {
        // ABI layout after selector:
        //   offset (32 bytes) | length (32 bytes) | string bytes
        final lengthHex = clean.substring(8 + 64, 8 + 128);
        final length = int.parse(lengthHex, radix: 16);
        final stringHex = clean.substring(8 + 128, 8 + 128 + length * 2);
        final bytes = Uint8List.fromList(
          List.generate(stringHex.length ~/ 2,
              (i) => int.parse(stringHex.substring(i * 2, i * 2 + 2), radix: 16)),
        );
        return utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        return null;
      }
    }

    // Panic(uint256)
    if (selector == '4e487b71' && clean.length >= 72) {
      try {
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
      0x11: 'Arithmetic overflow/underflow',
      0x12: 'Division by zero',
      0x21: 'Invalid enum conversion',
      0x22: 'Invalid storage byte array',
      0x31: 'Pop on empty array',
      0x32: 'Array index out of bounds',
      0x41: 'Out of memory',
      0x51: 'Invalid function pointer',
    };
    return messages[code] ?? 'Panic(0x${code.toRadixString(16)})';
  }
}
