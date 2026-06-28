// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:convert';

import 'package:n42_wallet/core/security/tx_risk_models.dart';

/// Human-readable signature and transaction decoder.
///
/// Translates raw contract calls and EIP-712 typed data into
/// plain-language descriptions that non-technical users can understand.
///
/// Examples:
/// - `approve(0x7a250..., 2^256-1)` → "Allow Uniswap Router to spend unlimited USDC"
/// - `setApprovalForAll(0x1E0049..., true)` → "Grant operator access to ALL your NFTs in this collection"
/// - EIP-2612 Permit → "Off-chain approval: Allow 0x1234 to spend 1000 USDC until 2026-05-01"
class SignatureDecoder {
  SignatureDecoder._();

  // ==================== EIP-712 Typed Data Decoding ====================

  /// Decode EIP-712 typed data into human-readable format.
  ///
  /// Handles common typed data patterns:
  /// - EIP-2612 Permit (token approval without on-chain tx)
  /// - Permit2 (Uniswap's batch permit)
  /// - Seaport orders (OpenSea)
  /// - Safe transaction hashes
  static SignatureDecodedResult decodeTypedData(Map<String, dynamic> typedData) {
    final primaryType = typedData['primaryType'] as String? ?? '';
    final message = typedData['message'] as Map<String, dynamic>? ?? {};
    final domain = typedData['domain'] as Map<String, dynamic>? ?? {};

    // EIP-2612 Permit
    if (primaryType == 'Permit') {
      return _decodePermit(message, domain);
    }

    // Permit2 (PermitSingle / PermitBatch)
    if (primaryType == 'PermitSingle' || primaryType == 'PermitBatch') {
      return _decodePermit2(message, domain, primaryType);
    }

    // Seaport Order
    if (primaryType == 'OrderComponents') {
      return _decodeSeaportOrder(message, domain);
    }

    // Safe Transaction
    if (primaryType == 'SafeTx') {
      return _decodeSafeTx(message, domain);
    }

    // Generic fallback
    return SignatureDecodedResult(
      title: 'Sign Typed Data',
      description: 'You are signing structured data of type "$primaryType"',
      riskLevel: TxRiskLevel.caution,
      fields: _flattenMessage(message),
      warnings: ['Review all fields carefully before signing'],
    );
  }

  /// Decode a personal_sign message into human-readable format.
  static SignatureDecodedResult decodePersonalSign(String message) {
    // Try to decode as UTF-8
    String decoded;
    if (message.startsWith('0x')) {
      try {
        final bytes = _hexToBytes(message.substring(2));
        decoded = utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        decoded = message;
      }
    } else {
      decoded = message;
    }

    // Check for common patterns
    if (decoded.contains('Terms of Service') || decoded.contains('I accept')) {
      return SignatureDecodedResult(
        title: 'Accept Terms',
        description: decoded.length > 200 ? '${decoded.substring(0, 200)}...' : decoded,
        riskLevel: TxRiskLevel.safe,
        fields: [],
        warnings: [],
      );
    }

    if (decoded.contains('Sign in') || decoded.contains('Login') || decoded.contains('Nonce:')) {
      return SignatureDecodedResult(
        title: 'Sign In to DApp',
        description: 'This signature verifies your identity. It does NOT approve any transaction.',
        riskLevel: TxRiskLevel.safe,
        fields: [
          if (decoded.length <= 500) DecodedField('Message', decoded),
        ],
        warnings: [],
      );
    }

    // Generic
    return SignatureDecodedResult(
      title: 'Sign Message',
      description: decoded.length > 200 ? '${decoded.substring(0, 200)}...' : decoded,
      riskLevel: TxRiskLevel.safe,
      fields: [],
      warnings: decoded.length > 500
          ? ['Message is very long — review carefully']
          : [],
    );
  }

  /// Decode a contract function call into human-readable format.
  ///
  /// Enhances the existing TxRiskAnalyzer with plain-language descriptions.
  static SignatureDecodedResult decodeContractCall({
    required String calldata,
    String? contractAddress,
    String? fromAddress,
    String? value,
  }) {
    if (calldata.length < 10) {
      final ethValue = value != null ? _formatWei(value) : '0';
      return SignatureDecodedResult(
        title: 'Send ETH',
        description: 'Transfer $ethValue ETH to ${_shortAddress(contractAddress ?? '')}',
        riskLevel: TxRiskLevel.safe,
        fields: [
          if (contractAddress != null) DecodedField('To', contractAddress),
          if (value != null) DecodedField('Amount', '$ethValue ETH'),
        ],
        warnings: [],
      );
    }

    final selector = calldata.substring(2, 10).toLowerCase();

    switch (selector) {
      // ── ERC-20 ──
      case '095ea7b3':
        return _decodeApprove(calldata, contractAddress);
      case 'a9059cbb':
        return _decodeTransfer(calldata, contractAddress);
      case '23b872dd':
        return _decodeTransferFrom(calldata);

      // ── ERC-721/1155 ──
      case 'a22cb465':
        return _decodeSetApprovalForAll(calldata, contractAddress);
      case '42842e0e':
        return _decodeSafeTransferFrom(calldata);

      // ── Permit ──
      case 'd505accf':
        return SignatureDecodedResult(
          title: 'On-chain Permit',
          description: 'Grants off-chain token approval via EIP-2612 permit',
          riskLevel: TxRiskLevel.danger,
          fields: [],
          warnings: [
            'This is an on-chain permit call',
            'It allows a spender to transfer your tokens without further approval',
          ],
        );

      // ── ERC-20 allowance tweaks ──
      case '39509351': // increaseAllowance(address,uint256)
        return SignatureDecodedResult(
          title: 'Increase Allowance',
          description: 'Increases a spender\'s token allowance',
          riskLevel: TxRiskLevel.caution,
          fields: [
            if (contractAddress != null) DecodedField('Token', contractAddress),
          ],
          warnings: ['Raises how many tokens a spender may move on your behalf'],
        );
      case 'a457c2d7': // decreaseAllowance(address,uint256)
        return SignatureDecodedResult(
          title: 'Decrease Allowance',
          description: 'Decreases a spender\'s token allowance',
          riskLevel: TxRiskLevel.safe,
          fields: [
            if (contractAddress != null) DecodedField('Token', contractAddress),
          ],
          warnings: [],
        );

      // ── ERC-1155 ──
      case 'f242432a': // safeTransferFrom(address,address,uint256,uint256,bytes)
      case '2eb2c2d6': // safeBatchTransferFrom(...)
        return SignatureDecodedResult(
          title: 'NFT Transfer (ERC-1155)',
          description: 'Transfers ERC-1155 token(s)',
          riskLevel: TxRiskLevel.caution,
          fields: [
            if (contractAddress != null)
              DecodedField('Contract', _shortAddress(contractAddress)),
          ],
          warnings: [],
        );

      // ── WETH wrap / unwrap ──
      case 'd0e30db0': // deposit()
        return SignatureDecodedResult(
          title: 'Wrap ETH',
          description: 'Wraps ETH into WETH',
          riskLevel: TxRiskLevel.safe,
          fields: [
            if (value != null && value != '0x0')
              DecodedField('Amount', _formatWei(value)),
          ],
          warnings: [],
        );
      case '2e1a7d4d': // withdraw(uint256)
        return SignatureDecodedResult(
          title: 'Unwrap WETH',
          description: 'Unwraps WETH back into ETH',
          riskLevel: TxRiskLevel.safe,
          fields: [],
          warnings: [],
        );

      // ── Swaps (V2 routers + V3 router) ──
      case '7ff36ab5':
      case '38ed1739':
      case '18cbafe5':
      case '8803dbee':
      case 'fb3bdb41':
      case '414bf389': // exactInputSingle
      case 'c04b8d59': // exactInput
      case 'db3e2198': // exactOutputSingle
      case 'f28c0498': // exactOutput
        return SignatureDecodedResult(
          title: 'Token Swap',
          description: 'Exchange tokens via DEX router',
          riskLevel: TxRiskLevel.safe,
          fields: [
            if (contractAddress != null) DecodedField('Router', _shortAddress(contractAddress)),
            if (value != null && value != '0x0') DecodedField('ETH Value', _formatWei(value)),
          ],
          warnings: [],
        );

      // ── Multicall ──
      case 'ac9650d8':
      case '5ae401dc':
      case '82ad56cb': // Multicall3 aggregate3
        return SignatureDecodedResult(
          title: 'Multicall (Batch)',
          description: 'Multiple operations in a single transaction',
          riskLevel: TxRiskLevel.caution,
          fields: [],
          warnings: ['Contains multiple bundled operations — review each carefully'],
        );

      // ── Permit2（Uniswap 通用授权，常见于现代 swap）──
      case '87517c45': // approve(token,spender,amount,expiration)
      case '2b67b570': // permit(...) single
      case '2a2d80d1': // permit(...) batch
        return SignatureDecodedResult(
          title: 'Permit2 Approval',
          description: 'Grants Permit2 permission to move your tokens',
          riskLevel: TxRiskLevel.danger,
          fields: [
            if (contractAddress != null)
              DecodedField('Permit2', _shortAddress(contractAddress)),
          ],
          warnings: [
            'Permit2 can transfer the approved token on your behalf',
            'Verify the spender, amount and expiration carefully',
          ],
        );

      // ── Seaport（OpenSea NFT 订单）──
      case 'fb0f3ee1': // fulfillBasicOrder
      case 'b3a34c4c': // fulfillOrder
      case 'e7acab24': // fulfillAdvancedOrder
      case '87201b41': // fulfillAvailableAdvancedOrders
        return SignatureDecodedResult(
          title: 'NFT Order (Seaport)',
          description: 'Fulfills an NFT marketplace order',
          riskLevel: TxRiskLevel.caution,
          fields: [
            if (value != null && value != '0x0')
              DecodedField('ETH Value', _formatWei(value)),
          ],
          warnings: ['Review the NFT, price and fees before confirming'],
        );

      // ── Lido 质押 ──
      case 'a1903eab': // submit(address)
        return SignatureDecodedResult(
          title: 'Stake ETH (Lido)',
          description: 'Stakes ETH for stETH via Lido',
          riskLevel: TxRiskLevel.safe,
          fields: [
            if (value != null && value != '0x0')
              DecodedField('Amount', _formatWei(value)),
          ],
          warnings: [],
        );

      default:
        return SignatureDecodedResult(
          title: 'Contract Interaction',
          description: 'Calling function 0x$selector on ${_shortAddress(contractAddress ?? '')}',
          riskLevel: TxRiskLevel.caution,
          fields: [
            DecodedField('Function', '0x$selector'),
            if (contractAddress != null) DecodedField('Contract', contractAddress),
            if (value != null && value != '0x0') DecodedField('ETH Value', _formatWei(value)),
          ],
          warnings: ['Unknown contract function — review carefully'],
        );
    }
  }

  // ==================== Internal Decoders ====================

  static SignatureDecodedResult _decodePermit(
    Map<String, dynamic> message,
    Map<String, dynamic> domain,
  ) {
    final spender = message['spender']?.toString() ?? '';
    final value = message['value']?.toString() ?? '0';
    final deadline = message['deadline']?.toString() ?? '';
    final tokenName = domain['name']?.toString() ?? 'Token';

    final isUnlimited = value == _maxUint256Str;
    final deadlineDate = _parseDeadline(deadline);

    return SignatureDecodedResult(
      title: 'Permit: Off-chain Approval',
      description: isUnlimited
          ? 'Allow ${_shortAddress(spender)} to spend unlimited $tokenName'
          : 'Allow ${_shortAddress(spender)} to spend $value $tokenName',
      riskLevel: isUnlimited ? TxRiskLevel.danger : TxRiskLevel.caution,
      fields: [
        DecodedField('Token', tokenName),
        DecodedField('Spender', spender),
        DecodedField('Amount', isUnlimited ? 'UNLIMITED' : value, isHighlighted: isUnlimited),
        if (deadlineDate != null) DecodedField('Expires', deadlineDate),
      ],
      warnings: [
        'This is an off-chain approval — no gas fee but just as powerful as on-chain approve',
        if (isUnlimited) 'UNLIMITED approval — the spender can drain all your $tokenName',
      ],
    );
  }

  static SignatureDecodedResult _decodePermit2(
    Map<String, dynamic> message,
    Map<String, dynamic> domain,
    String type,
  ) {
    return SignatureDecodedResult(
      title: 'Permit2: Batch Approval',
      description: 'Uniswap Permit2 — batch token approval',
      riskLevel: TxRiskLevel.caution,
      fields: _flattenMessage(message),
      warnings: [
        'Permit2 allows batch operations on your tokens',
        'Review the permitted amounts and spender carefully',
      ],
    );
  }

  static SignatureDecodedResult _decodeSeaportOrder(
    Map<String, dynamic> message,
    Map<String, dynamic> domain,
  ) {
    return SignatureDecodedResult(
      title: 'NFT Marketplace Order',
      description: 'Create a listing or offer on OpenSea/Seaport',
      riskLevel: TxRiskLevel.caution,
      fields: _flattenMessage(message).take(10).toList(),
      warnings: ['This creates a binding order on the marketplace'],
    );
  }

  static SignatureDecodedResult _decodeSafeTx(
    Map<String, dynamic> message,
    Map<String, dynamic> domain,
  ) {
    return SignatureDecodedResult(
      title: 'Safe Multisig Transaction',
      description: 'Confirm a transaction for your Safe (Gnosis) multisig wallet',
      riskLevel: TxRiskLevel.caution,
      fields: [
        DecodedField('To', message['to']?.toString() ?? ''),
        DecodedField('Value', message['value']?.toString() ?? '0'),
        DecodedField('Nonce', message['nonce']?.toString() ?? ''),
      ],
      warnings: [],
    );
  }

  static SignatureDecodedResult _decodeApprove(String calldata, String? contract) {
    if (calldata.length < 138) {
      return SignatureDecodedResult(
        title: 'Token Approve',
        description: 'Approve token spending',
        riskLevel: TxRiskLevel.caution,
        fields: [],
        warnings: ['Could not decode approval parameters'],
      );
    }

    final spender = '0x${calldata.substring(34, 74)}';
    final amountHex = calldata.substring(74, 138);
    final isUnlimited = amountHex == 'f' * 64 ||
        BigInt.tryParse(amountHex, radix: 16) == BigInt.parse(_maxUint256Str);

    return SignatureDecodedResult(
      title: isUnlimited ? 'Unlimited Token Approval' : 'Token Approval',
      description: isUnlimited
          ? 'Allow ${_shortAddress(spender)} to spend ALL your tokens from this contract'
          : 'Allow ${_shortAddress(spender)} to spend a specific amount',
      riskLevel: isUnlimited ? TxRiskLevel.danger : TxRiskLevel.caution,
      fields: [
        DecodedField('Spender', spender),
        DecodedField('Amount', isUnlimited ? 'UNLIMITED' : _formatHexAmount(amountHex),
            isHighlighted: isUnlimited),
        if (contract != null) DecodedField('Token Contract', contract),
      ],
      warnings: isUnlimited
          ? [
              'UNLIMITED approval grants the spender access to ALL your tokens',
              'Consider setting a specific amount instead',
            ]
          : [],
    );
  }

  static SignatureDecodedResult _decodeTransfer(String calldata, String? contract) {
    if (calldata.length < 138) {
      return SignatureDecodedResult(
        title: 'Token Transfer',
        description: 'Transfer tokens',
        riskLevel: TxRiskLevel.safe,
        fields: [],
        warnings: [],
      );
    }

    final to = '0x${calldata.substring(34, 74)}';
    final amountHex = calldata.substring(74, 138);

    return SignatureDecodedResult(
      title: 'Token Transfer',
      description: 'Send tokens to ${_shortAddress(to)}',
      riskLevel: TxRiskLevel.safe,
      fields: [
        DecodedField('To', to),
        DecodedField('Amount', _formatHexAmount(amountHex)),
      ],
      warnings: [],
    );
  }

  static SignatureDecodedResult _decodeTransferFrom(String calldata) {
    return SignatureDecodedResult(
      title: 'Transfer From',
      description: 'Transfer tokens on behalf of another address',
      riskLevel: TxRiskLevel.caution,
      fields: [],
      warnings: ['This moves tokens from another address using a prior approval'],
    );
  }

  static SignatureDecodedResult _decodeSetApprovalForAll(String calldata, String? contract) {
    if (calldata.length < 138) {
      return SignatureDecodedResult(
        title: 'NFT Approval For All',
        description: 'Grant or revoke operator access',
        riskLevel: TxRiskLevel.danger,
        fields: [],
        warnings: [],
      );
    }

    final operator = '0x${calldata.substring(34, 74)}';
    final approvedHex = calldata.substring(74, 138);
    final isApproved = BigInt.tryParse(approvedHex, radix: 16) != BigInt.zero;

    return SignatureDecodedResult(
      title: isApproved ? 'Grant NFT Operator Access' : 'Revoke NFT Operator Access',
      description: isApproved
          ? 'Allow ${_shortAddress(operator)} to transfer ALL your NFTs in this collection'
          : 'Revoke ${_shortAddress(operator)}\'s access to your NFTs',
      riskLevel: isApproved ? TxRiskLevel.danger : TxRiskLevel.safe,
      fields: [
        DecodedField('Operator', operator),
        DecodedField('Approved', isApproved ? 'YES — All NFTs' : 'NO — Revoked',
            isHighlighted: isApproved),
        if (contract != null) DecodedField('Collection', contract),
      ],
      warnings: isApproved
          ? ['This grants access to ALL NFTs in this collection, not just one']
          : [],
    );
  }

  static SignatureDecodedResult _decodeSafeTransferFrom(String calldata) {
    return SignatureDecodedResult(
      title: 'NFT Transfer',
      description: 'Transfer an NFT',
      riskLevel: TxRiskLevel.safe,
      fields: [],
      warnings: [],
    );
  }

  // ==================== Helpers ====================

  static const String _maxUint256Str =
      '115792089237316195423570985008687907853269984665640564039457584007913129639935';

  static String _shortAddress(String addr) {
    if (addr.length < 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  static String _formatWei(String hexValue) {
    try {
      final wei = BigInt.parse(hexValue.replaceFirst('0x', ''), radix: 16);
      final eth = wei / BigInt.from(10).pow(18);
      final remainder = wei % BigInt.from(10).pow(18);
      if (remainder == BigInt.zero) return '$eth';
      final decimal = remainder.toString().padLeft(18, '0').substring(0, 6);
      return '$eth.$decimal';
    } catch (_) {
      return hexValue;
    }
  }

  static String _formatHexAmount(String hex) {
    try {
      final amount = BigInt.parse(hex, radix: 16);
      if (amount >= BigInt.parse(_maxUint256Str)) return 'UNLIMITED';
      // Show raw amount (without decimals — caller should format with token decimals)
      return amount.toString();
    } catch (_) {
      return hex;
    }
  }

  static String? _parseDeadline(String deadline) {
    try {
      final ts = int.tryParse(deadline);
      if (ts == null) return null;
      if (ts > 1e15.toInt()) return 'Never'; // far future
      final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

  static List<DecodedField> _flattenMessage(Map<String, dynamic> message, {String prefix = ''}) {
    final fields = <DecodedField>[];
    for (final entry in message.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value is Map<String, dynamic>) {
        fields.addAll(_flattenMessage(entry.value as Map<String, dynamic>, prefix: key));
      } else {
        fields.add(DecodedField(key, entry.value?.toString() ?? 'null'));
      }
    }
    return fields;
  }

  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}

/// Result of signature/transaction decoding.
class SignatureDecodedResult {
  /// Plain-language title (e.g., "Unlimited Token Approval").
  final String title;

  /// Human-readable description of what happens.
  final String description;

  /// Risk level of this action.
  final TxRiskLevel riskLevel;

  /// Decoded fields to display.
  final List<DecodedField> fields;

  /// Warning messages for the user.
  final List<String> warnings;

  const SignatureDecodedResult({
    required this.title,
    required this.description,
    required this.riskLevel,
    required this.fields,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get isDangerous => riskLevel == TxRiskLevel.danger;
}

/// A decoded field with label and value.
class DecodedField {
  final String label;
  final String value;
  final bool isHighlighted;

  const DecodedField(this.label, this.value, {this.isHighlighted = false});
}
