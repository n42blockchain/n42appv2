// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'dart:convert';

/// Transaction risk analysis result.
class TxRiskAnalysis {
  /// Overall risk level (highest severity among all flags).
  final TxRiskLevel level;

  /// Human-readable function name (e.g. "ERC-20 Approve", "Token Swap").
  final String functionName;

  /// Decoded field labels and values (e.g. Spender → 0x1234…5678).
  final List<TxRiskField> fields;

  /// Warning messages explaining each risk (may be empty for safe txs).
  final List<String> warnings;

  const TxRiskAnalysis({
    required this.level,
    required this.functionName,
    this.fields = const [],
    this.warnings = const [],
  });

  bool get hasWarnings => warnings.isNotEmpty;
}

/// A single decoded parameter to display.
class TxRiskField {
  final String label;
  final String value;
  final bool isHighlighted; // e.g. red for unlimited amount

  const TxRiskField(this.label, this.value, {this.isHighlighted = false});
}

/// Risk severity levels.
enum TxRiskLevel {
  /// Normal operation, no elevated risk detected.
  safe,

  /// Potentially risky — user should review carefully.
  caution,

  /// High-risk action: unlimited approval, ownership change, etc.
  danger,
}

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

  // Decimal representation of MaxUint256
  static final BigInt _maxUint256 = BigInt.parse(
    '115792089237316195423570985008687907853269984665640564039457584007913129639935',
  );

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
    final hasData = calldata != null &&
        calldata.isNotEmpty &&
        calldata != '0x' &&
        calldata != '0X';

    if (!hasData) {
      // Native ETH/token transfer
      final fields = <TxRiskField>[];
      if (toAddress != null && toAddress.isNotEmpty) {
        fields.add(TxRiskField('To', _formatAddress(toAddress)));
      }
      if (ethValue != null && ethValue != '0x' && ethValue != '0x0') {
        fields.add(TxRiskField('Value', _formatHexWei(ethValue)));
      }
      return TxRiskAnalysis(
        level: TxRiskLevel.safe,
        functionName: 'Native Transfer',
        fields: fields,
      );
    }

    final clean = calldata.startsWith('0x') || calldata.startsWith('0X')
        ? calldata.substring(2)
        : calldata;

    if (clean.length < 8) {
      return const TxRiskAnalysis(
        level: TxRiskLevel.caution,
        functionName: 'Unknown Call',
        warnings: ['Calldata too short — cannot decode.'],
      );
    }

    final selector = '0x${clean.substring(0, 8).toLowerCase()}';
    final params = clean.substring(8); // ABI-encoded params without selector

    return _dispatch(selector, params, ethValue, toAddress);
  }

  /// Analyze EIP-712 typed data (from eth_signTypedData / personal_sign with JSON).
  ///
  /// Returns `null` if [jsonStr] is not valid EIP-712 data.
  static TxRiskAnalysis? analyzeTypedData(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return null;

    // Try to parse as JSON
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return null;
      data = decoded;
    } catch (_) {
      return null;
    }

    final primaryType = data['primaryType'] as String?;
    final message = data['message'] as Map<String, dynamic>?;

    if (primaryType == null) return null;

    // EIP-2612 Permit — gasless approval
    if (primaryType == 'Permit' && message != null) {
      final spender = message['spender'] as String? ?? '';
      final value = message['value'];
      final deadline = message['deadline'];
      final isUnlimited = _isUnlimitedPermitValue(value);

      final fields = <TxRiskField>[];
      if (spender.isNotEmpty) {
        fields.add(TxRiskField('Spender', _formatAddress(spender)));
      }
      fields.add(TxRiskField(
        'Amount',
        isUnlimited ? 'Unlimited ∞' : value?.toString() ?? '?',
        isHighlighted: isUnlimited,
      ));
      if (deadline != null) {
        fields.add(TxRiskField(
          'Deadline',
          _formatDeadline(deadline),
        ));
      }

      final warnings = <String>[
        'Gasless approval via EIP-2612 — spender gains transfer rights without a second transaction.',
        if (isUnlimited)
          'Amount is UNLIMITED — spender can drain all tokens from this contract.',
      ];

      return TxRiskAnalysis(
        level: TxRiskLevel.danger,
        functionName: 'Gasless Approve (Permit)',
        fields: fields,
        warnings: warnings,
      );
    }

    // Other well-known types — no special risk surfaced
    return TxRiskAnalysis(
      level: TxRiskLevel.safe,
      functionName: 'Signed Message ($primaryType)',
    );
  }

  // ─── Internal dispatch ───────────────────────────────────────────────────────

  static TxRiskAnalysis _dispatch(
    String selector,
    String params,
    String? ethValue,
    String? toAddress,
  ) {
    switch (selector) {
      // ── ERC-20 ────────────────────────────────────────────────────────────
      case _selTransfer:
        return _decodeErc20Transfer(params);

      case _selApprove:
      case _selIncAllowance:
        return _decodeApprove(params, selector);

      case _selTransferFrom:
        return _decodeTransferFrom(params);

      case _selPermit:
        return _decodePermit(params);

      // ── ERC-721 / ERC-1155 ────────────────────────────────────────────────
      case _selApprovalForAll:
        return _decodeSetApprovalForAll(params);

      case _selSafeTransferFrom3:
      case _selSafeTransferFrom4:
        return _decodeNftTransfer(params);

      case _selSafeBatchTransfer:
        return const TxRiskAnalysis(
          level: TxRiskLevel.safe,
          functionName: 'NFT Batch Transfer',
        );

      // ── Ownable ───────────────────────────────────────────────────────────
      case _selTransferOwnership:
        return _decodeTransferOwnership(params);

      case _selRenounceOwnership:
        return const TxRiskAnalysis(
          level: TxRiskLevel.danger,
          functionName: 'Renounce Ownership',
          warnings: [
            'Ownership will be permanently renounced. This cannot be undone.',
          ],
        );

      // ── Multicall / batch ─────────────────────────────────────────────────
      case _selMulticall1:
      case _selMulticall2:
        return const TxRiskAnalysis(
          level: TxRiskLevel.caution,
          functionName: 'Batch Transaction (Multicall)',
          warnings: [
            'Multiple operations are bundled. Review each action carefully.',
          ],
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

  // ─── Decoders ────────────────────────────────────────────────────────────────

  static TxRiskAnalysis _decodeErc20Transfer(String params) {
    final fields = <TxRiskField>[];
    if (params.length >= 128) {
      final to = _decodeAddress(params.substring(0, 64));
      final amount = params.substring(64, 128);
      fields.add(TxRiskField('To', _formatAddress(to)));
      fields.add(TxRiskField('Amount', _formatAmount(amount)));
    }
    return TxRiskAnalysis(
      level: TxRiskLevel.safe,
      functionName: 'ERC-20 Transfer',
      fields: fields,
    );
  }

  static TxRiskAnalysis _decodeApprove(String params, String selector) {
    final fields = <TxRiskField>[];
    final warnings = <String>[];
    var level = TxRiskLevel.caution;

    if (params.length >= 128) {
      final spender = _decodeAddress(params.substring(0, 64));
      final amountHex = params.substring(64, 128);
      final isUnlimited = _isMaxUint256(amountHex);

      if (isUnlimited) {
        level = TxRiskLevel.danger;
        warnings.add(
          'Unlimited approval — spender can transfer ALL tokens in this '
          'contract from your wallet at any time.',
        );
      }

      fields.add(TxRiskField('Spender', _formatAddress(spender)));
      fields.add(TxRiskField(
        'Amount',
        isUnlimited ? 'Unlimited ∞' : _formatAmount(amountHex),
        isHighlighted: isUnlimited,
      ));
    }

    return TxRiskAnalysis(
      level: level,
      functionName: selector == _selIncAllowance
          ? 'Increase Allowance'
          : 'ERC-20 Approve',
      fields: fields,
      warnings: warnings,
    );
  }

  static TxRiskAnalysis _decodeTransferFrom(String params) {
    final fields = <TxRiskField>[];
    if (params.length >= 192) {
      final from = _decodeAddress(params.substring(0, 64));
      final to = _decodeAddress(params.substring(64, 128));
      final amount = params.substring(128, 192);
      fields.add(TxRiskField('From', _formatAddress(from)));
      fields.add(TxRiskField('To', _formatAddress(to)));
      fields.add(TxRiskField('Amount', _formatAmount(amount)));
    }
    return TxRiskAnalysis(
      level: TxRiskLevel.caution,
      functionName: 'ERC-20 TransferFrom',
      fields: fields,
      warnings: [
        'Tokens will be transferred FROM another address on their behalf.',
      ],
    );
  }

  static TxRiskAnalysis _decodePermit(String params) {
    final fields = <TxRiskField>[];
    final warnings = <String>[];
    var level = TxRiskLevel.danger;

    if (params.length >= 320) {
      // owner(32) + spender(32) + value(32) + deadline(32) + v(32) + r(32) + s(32)
      // Note: first param is owner (often same as tx.from)
      final spender = _decodeAddress(params.substring(64, 128));
      final amountHex = params.substring(128, 192);
      final isUnlimited = _isMaxUint256(amountHex);

      fields.add(TxRiskField('Spender', _formatAddress(spender)));
      fields.add(TxRiskField(
        'Amount',
        isUnlimited ? 'Unlimited ∞' : _formatAmount(amountHex),
        isHighlighted: isUnlimited,
      ));

      warnings.add(
        'Gasless approval (EIP-2612): spender gains transfer rights '
        'without any further transaction from you.',
      );
      if (isUnlimited) {
        warnings.add(
          'Amount is UNLIMITED — spender can drain all tokens.',
        );
      }
    }

    return TxRiskAnalysis(
      level: level,
      functionName: 'Gasless Approve (Permit)',
      fields: fields,
      warnings: warnings,
    );
  }

  static TxRiskAnalysis _decodeSetApprovalForAll(String params) {
    final fields = <TxRiskField>[];
    if (params.length >= 64) {
      final operator = _decodeAddress(params.substring(0, 64));
      fields.add(TxRiskField('Operator', _formatAddress(operator)));
      // bool approved: second param (0x...01 = true)
      if (params.length >= 128) {
        final approved = params.substring(64, 128).endsWith('1');
        fields.add(TxRiskField('Action', approved ? 'Grant Access' : 'Revoke Access'));
      }
    }

    return TxRiskAnalysis(
      level: TxRiskLevel.danger,
      functionName: 'NFT Approve All (setApprovalForAll)',
      fields: fields,
      warnings: [
        'Grants the operator full access to your entire NFT collection in '
        'this contract. Revoke after use.',
      ],
    );
  }

  static TxRiskAnalysis _decodeTransferOwnership(String params) {
    final fields = <TxRiskField>[];
    if (params.length >= 64) {
      final newOwner = _decodeAddress(params.substring(0, 64));
      fields.add(TxRiskField('New Owner', _formatAddress(newOwner)));
    }
    return TxRiskAnalysis(
      level: TxRiskLevel.danger,
      functionName: 'Transfer Ownership',
      fields: fields,
      warnings: [
        'Contract ownership will be permanently transferred to a new address.',
      ],
    );
  }

  static TxRiskAnalysis _decodeNftTransfer(String params) {
    final fields = <TxRiskField>[];
    if (params.length >= 192) {
      final from = _decodeAddress(params.substring(0, 64));
      final to = _decodeAddress(params.substring(64, 128));
      fields.add(TxRiskField('From', _formatAddress(from)));
      fields.add(TxRiskField('To', _formatAddress(to)));
    }
    return TxRiskAnalysis(
      level: TxRiskLevel.safe,
      functionName: 'NFT Transfer',
      fields: fields,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Decode a 32-byte ABI-padded address (64 hex chars) to "0x..." checksum form.
  static String _decodeAddress(String padded) {
    // Last 40 hex chars = 20 byte address
    if (padded.length < 40) return '0x${padded.padLeft(40, '0')}';
    return '0x${padded.substring(padded.length - 40)}';
  }

  static bool _isMaxUint256(String hex64) {
    try {
      final clean = hex64.replaceAll(RegExp(r'^0+'), '').toLowerCase();
      if (clean.isEmpty) return false;
      final bi = BigInt.parse(clean, radix: 16);
      return bi == _maxUint256;
    } catch (_) {
      return false;
    }
  }

  static bool _isUnlimitedPermitValue(dynamic value) {
    if (value == null) return false;
    try {
      final bi = BigInt.parse(value.toString());
      return bi >= _maxUint256;
    } catch (_) {
      return false;
    }
  }

  /// Format a hex uint256 (64 chars) as a readable decimal or abbreviated hex.
  static String _formatAmount(String hex64) {
    if (_isMaxUint256(hex64)) return 'Unlimited ∞';
    try {
      final clean = hex64.replaceAll(RegExp(r'^0+'), '');
      if (clean.isEmpty) return '0';
      final bi = BigInt.parse(clean, radix: 16);
      if (bi == BigInt.zero) return '0';
      // Show abbreviated decimal for readability
      final decimal = bi.toString();
      if (decimal.length > 20) {
        // Very large — likely raw token units; show abbreviated
        return '${decimal.substring(0, 6)}…${decimal.substring(decimal.length - 4)}';
      }
      return decimal;
    } catch (_) {
      return '0x${hex64.substring(0, 8)}…';
    }
  }

  /// Format hex wei value (e.g. "0x38d7ea4c68000") to human-readable.
  static String _formatHexWei(String hexValue) {
    try {
      final clean = hexValue.startsWith('0x') ? hexValue.substring(2) : hexValue;
      if (clean.isEmpty || clean == '0') return '0 ETH';
      final wei = BigInt.parse(clean, radix: 16);
      if (wei == BigInt.zero) return '0 ETH';
      // 1 ETH = 10^18 wei — show up to 6 decimal places
      final divisor = BigInt.from(10).pow(18);
      final whole = wei ~/ divisor;
      final remainder = wei.remainder(divisor);
      if (remainder == BigInt.zero) return '$whole ETH';
      // Pad remainder to 18 digits, then take first 6 for display
      final fracStr = remainder.toString().padLeft(18, '0').substring(0, 6);
      // Remove trailing zeros
      final trimmed = fracStr.replaceAll(RegExp(r'0+$'), '');
      return '$whole.${trimmed.isEmpty ? '0' : trimmed} ETH';
    } catch (_) {
      return hexValue;
    }
  }

  /// Truncate an address to 0x1234…5678 format.
  static String _formatAddress(String addr) {
    if (addr.length <= 12) return addr;
    return '${addr.substring(0, 8)}…${addr.substring(addr.length - 6)}';
  }

  /// Format a Unix timestamp deadline into human-readable expiry.
  static String _formatDeadline(dynamic deadline) {
    try {
      final ts = int.parse(deadline.toString());
      final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return deadline.toString();
    }
  }
}
