// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';

import 'package:n42_wallet/core/security/tx_risk_decoders.dart';
import 'package:n42_wallet/core/security/tx_risk_formatters.dart';
import 'package:n42_wallet/core/security/tx_risk_models.dart';

export 'package:n42_wallet/core/security/tx_risk_models.dart';

/// Analyzes EVM transaction calldata and EIP-712 typed data to detect
/// contract interaction risks, decode parameters, and compute a risk level.
///
/// All methods are synchronous and stateless — call them freely from
/// widget build methods without async overhead.
class TxRiskAnalyzer {
  TxRiskAnalyzer._();

  // ─── Known EVM function selectors ──────────────────────────────────────────

  // ERC-20
  static const String _selTransfer = '0xa9059cbb'; // transfer(address,uint256)
  static const String _selApprove = '0x095ea7b3'; // approve(address,uint256)
  static const String _selTransferFrom = '0x23b872dd'; // transferFrom(address,address,uint256)
  static const String _selIncAllowance = '0xb0431182'; // increaseAllowance(address,uint256)
  static const String _selPermit = '0xd505accf'; // permit(address,address,uint256,uint256,uint8,bytes32,bytes32)

  // ERC-721 / ERC-1155
  static const String _selApprovalForAll = '0xa22cb465'; // setApprovalForAll(address,bool)
  static const String _selSafeTransferFrom3 = '0x42842e0e'; // safeTransferFrom(address,address,uint256)
  static const String _selSafeTransferFrom4 = '0xb88d4fde'; // safeTransferFrom(address,address,uint256,bytes)
  static const String _selSafeBatchTransfer = '0x2eb2c2d6'; // safeBatchTransferFrom

  // Ownable
  static const String _selTransferOwnership = '0xf2fde38b'; // transferOwnership(address)
  static const String _selRenounceOwnership = '0x715018a6'; // renounceOwnership()

  // Multicall / batch
  static const String _selMulticall1 = '0xac9650d8'; // multicall(bytes[])
  static const String _selMulticall2 = '0x5ae401dc'; // multicall(uint256,bytes[]) — Uniswap V3

  // Uniswap V2 swaps
  static const String _selSwapExactETHForTokens = '0x7ff36ab5';
  static const String _selSwapExactTokensForTokens = '0x38ed1739';
  static const String _selSwapExactTokensForETH = '0x18cbafe5';
  static const String _selSwapETHForExactTokens = '0xfb3bdb41';
  static const String _selSwapTokensForExactETH = '0x4a25d94a';
  static const String _selSwapTokensForExactTokens = '0x8803dbee';

  // Uniswap V3 swaps
  static const String _selExactInputSingle = '0x414bf389';
  static const String _selExactOutputSingle = '0xdb3e2198';
  static const String _selExactInput = '0xe449022e';
  static const String _selExactOutput = '0xf28c0498';

  // Misc
  static const String _selMint = '0x40c10f19'; // mint(address,uint256)

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Analyze EVM transaction calldata.
  ///
  /// [calldata] — hex string (may include "0x" prefix; may be "0x" for native transfers).
  /// [ethValue] — optional hex string of ETH value sent (e.g. "0x38d7ea4c68000").
  /// [toAddress] — recipient/contract address.
  static TxRiskAnalysis analyze({
    required String? calldata,
    String? ethValue,
    String? toAddress,
  }) {
    final data = calldata?.toLowerCase() ?? '';
    final hasData = data.isNotEmpty && data != '0x';

    if (!hasData) {
      final fields = <TxRiskField>[];
      if (toAddress != null && toAddress.isNotEmpty) {
        fields.add(TxRiskField('To', txRiskFormatAddress(toAddress)));
      }
      if (ethValue != null && ethValue != '0x' && ethValue != '0x0') {
        fields.add(TxRiskField('Value', txRiskFormatHexWei(ethValue)));
      }
      return TxRiskAnalysis(
        level: TxRiskLevel.safe,
        functionName: 'Native Transfer',
        fields: fields,
      );
    }

    final clean = data.startsWith('0x') ? data.substring(2) : data;

    if (clean.length < 8) {
      return const TxRiskAnalysis(
        level: TxRiskLevel.caution,
        functionName: 'Unknown Call',
        warnings: ['Calldata too short — cannot decode.'],
      );
    }

    final selector = '0x${clean.substring(0, 8)}';
    final params = clean.substring(8); // ABI-encoded params without selector

    return _dispatch(selector, params);
  }

  /// Analyze EIP-712 typed data (from eth_signTypedData / personal_sign with JSON).
  ///
  /// Returns `null` if [jsonStr] is not valid EIP-712 data.
  static TxRiskAnalysis? analyzeTypedData(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(jsonStr);
    } catch (_) {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    final primaryType = decoded['primaryType'] as String?;
    final message = decoded['message'] as Map<String, dynamic>?;

    if (primaryType == null) return null;

    // EIP-2612 Permit — gasless approval
    if (primaryType == 'Permit' && message != null) {
      final spender = message['spender'] as String? ?? '';
      final value = message['value'];
      final deadline = message['deadline'];
      final isUnlimited = txRiskIsUnlimitedPermitValue(value);

      final fields = <TxRiskField>[];
      if (spender.isNotEmpty) {
        fields.add(TxRiskField('Spender', txRiskFormatAddress(spender)));
      }
      fields.add(TxRiskField(
        'Amount',
        isUnlimited ? 'Unlimited ∞' : value?.toString() ?? '?',
        isHighlighted: isUnlimited,
      ));
      if (deadline != null) {
        fields.add(TxRiskField('Deadline', txRiskFormatDeadline(deadline)));
      }

      return TxRiskAnalysis(
        level: TxRiskLevel.danger,
        functionName: 'Gasless Approve (Permit)',
        fields: fields,
        warnings: [
          'Gasless approval via EIP-2612 — spender gains transfer rights without a second transaction.',
          if (isUnlimited)
            'Amount is UNLIMITED — spender can drain all tokens from this contract.',
        ],
      );
    }

    // Other well-known types — no special risk surfaced
    return TxRiskAnalysis(
      level: TxRiskLevel.safe,
      functionName: 'Signed Message ($primaryType)',
    );
  }

  // ─── Internal dispatch ───────────────────────────────────────────────────────

  static TxRiskAnalysis _dispatch(String selector, String params) {
    switch (selector) {
      // ── ERC-20 ────────────────────────────────────────────────────────────
      case _selTransfer:
        return decodeErc20Transfer(params);

      case _selApprove:
      case _selIncAllowance:
        return decodeApprove(params, selector);

      case _selTransferFrom:
        return decodeTransferFrom(params);

      case _selPermit:
        return decodePermit(params);

      // ── ERC-721 / ERC-1155 ────────────────────────────────────────────────
      case _selApprovalForAll:
        return decodeSetApprovalForAll(params);

      case _selSafeTransferFrom3:
      case _selSafeTransferFrom4:
        return decodeNftTransfer(params);

      case _selSafeBatchTransfer:
        return const TxRiskAnalysis(
          level: TxRiskLevel.safe,
          functionName: 'NFT Batch Transfer',
        );

      // ── Ownable ───────────────────────────────────────────────────────────
      case _selTransferOwnership:
        return decodeTransferOwnership(params);

      case _selRenounceOwnership:
        return const TxRiskAnalysis(
          level: TxRiskLevel.danger,
          functionName: 'Renounce Ownership',
          warnings: ['Ownership will be permanently renounced. This cannot be undone.'],
        );

      // ── Multicall / batch ─────────────────────────────────────────────────
      case _selMulticall1:
      case _selMulticall2:
        return const TxRiskAnalysis(
          level: TxRiskLevel.caution,
          functionName: 'Batch Transaction (Multicall)',
          warnings: ['Multiple operations are bundled. Review each action carefully.'],
        );

      // ── Uniswap-style DEX swaps ───────────────────────────────────────────
      case _selSwapExactETHForTokens:
      case _selSwapExactTokensForTokens:
      case _selSwapExactTokensForETH:
      case _selSwapETHForExactTokens:
      case _selSwapTokensForExactETH:
      case _selSwapTokensForExactTokens:
      case _selExactInputSingle:
      case _selExactOutputSingle:
      case _selExactInput:
      case _selExactOutput:
        return const TxRiskAnalysis(
          level: TxRiskLevel.safe,
          functionName: 'Token Swap (DEX)',
        );

      // ── Mint ──────────────────────────────────────────────────────────────
      case _selMint:
        return const TxRiskAnalysis(
          level: TxRiskLevel.caution,
          functionName: 'Mint Tokens',
          warnings: ['A minting operation will be executed.'],
        );

      // ── Unknown ───────────────────────────────────────────────────────────
      default:
        return TxRiskAnalysis(
          level: TxRiskLevel.caution,
          functionName: 'Unknown Contract Call',
          fields: [TxRiskField('Selector', selector)],
          warnings: ['Unrecognized function. Review carefully before signing.'],
        );
    }
  }
}
