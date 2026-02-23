// Copyright 2021-2026 N42 Inc. All rights reserved.
import 'dart:convert';

import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// Data models
// ════════════════════════════════════════════════════════════════════════════

/// Session Key permission preset.
///
/// Corresponds to three user-facing templates that hide technical complexity:
/// - [transfer] — send tokens within a spending limit (low risk)
/// - [contractCall] — interact with whitelisted DApp contracts (medium risk)
/// - [full] — unrestricted delegation (high risk, requires explicit consent)
/// - [approve] — token approve only; kept for backward-compat with stored data
enum SessionKeyPermission {
  transfer,
  approve,
  contractCall,
  full,
}

/// Lifecycle status of a session key.
enum SessionKeyStatus {
  active,
  expired,
  revoked,
}

/// Immutable session key record.
///
/// Stored in SQLite via [SessionKeyRepository]. The [chainId] field scopes
/// the key to a specific EVM network.
class SessionKeyData {
  final String keyAddress;
  final String label;
  final SessionKeyPermission permission;
  final SessionKeyStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? dappName;
  final String? dappIcon;
  final List<String>? allowedContracts;
  final BigInt? spendingLimit;

  /// Token symbol for [spendingLimit], e.g. 'ETH', 'USDC'.
  final String? spendingToken;
  final BigInt? usedAmount;
  final int? transactionCount;

  /// EVM chain ID this key belongs to (1 = Ethereum mainnet, 8453 = Base…).
  final int chainId;

  const SessionKeyData({
    required this.keyAddress,
    required this.label,
    required this.permission,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.dappName,
    this.dappIcon,
    this.allowedContracts,
    this.spendingLimit,
    this.spendingToken,
    this.usedAmount,
    this.transactionCount,
    this.chainId = 1,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  String get shortAddress {
    if (keyAddress.length <= 12) return keyAddress;
    return '${keyAddress.substring(0, 6)}...${keyAddress.substring(keyAddress.length - 4)}';
  }

  bool get isActive => status == SessionKeyStatus.active;

  Duration get remainingTime {
    final now = DateTime.now();
    if (expiresAt.isBefore(now)) return Duration.zero;
    return expiresAt.difference(now);
  }

  double get usagePercentage {
    if (spendingLimit == null || spendingLimit == BigInt.zero) return 0;
    if (usedAmount == null) return 0;
    return (usedAmount! / spendingLimit!).toDouble().clamp(0.0, 1.0);
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Map<String, dynamic> toDbMap() => {
        'key_address': keyAddress,
        'label': label,
        'permission': permission.name,
        'status': status.name,
        'created_at': createdAt.millisecondsSinceEpoch,
        'expires_at': expiresAt.millisecondsSinceEpoch,
        if (dappName != null) 'dapp_name': dappName,
        if (allowedContracts != null)
          'allowed_contracts': jsonEncode(allowedContracts),
        if (spendingLimit != null) 'spending_limit': spendingLimit.toString(),
        if (spendingToken != null) 'spending_token': spendingToken,
        if (usedAmount != null) 'used_amount': usedAmount.toString(),
        if (transactionCount != null) 'transaction_count': transactionCount,
        'chain_id': chainId,
      };

  factory SessionKeyData.fromDbMap(Map<String, dynamic> map) {
    List<String>? contracts;
    final contractsRaw = map['allowed_contracts'];
    if (contractsRaw is String) {
      final decoded = jsonDecode(contractsRaw);
      if (decoded is List) {
        contracts = decoded.map((e) => e.toString()).toList();
      }
    }

    return SessionKeyData(
      keyAddress: map['key_address'] as String,
      label: map['label'] as String,
      permission: SessionKeyPermission.values.firstWhere(
        (e) => e.name == map['permission'],
        orElse: () => SessionKeyPermission.transfer,
      ),
      status: SessionKeyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SessionKeyStatus.active,
      ),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      expiresAt:
          DateTime.fromMillisecondsSinceEpoch(map['expires_at'] as int),
      dappName: map['dapp_name'] as String?,
      allowedContracts: contracts,
      spendingLimit: map['spending_limit'] != null
          ? BigInt.tryParse(map['spending_limit'] as String)
          : null,
      spendingToken: map['spending_token'] as String?,
      usedAmount: map['used_amount'] != null
          ? BigInt.tryParse(map['used_amount'] as String)
          : null,
      transactionCount: map['transaction_count'] as int?,
      chainId: map['chain_id'] as int? ?? 1,
    );
  }

  SessionKeyData copyWith({
    String? keyAddress,
    String? label,
    SessionKeyPermission? permission,
    SessionKeyStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? dappName,
    String? dappIcon,
    List<String>? allowedContracts,
    BigInt? spendingLimit,
    String? spendingToken,
    BigInt? usedAmount,
    int? transactionCount,
    int? chainId,
  }) =>
      SessionKeyData(
        keyAddress: keyAddress ?? this.keyAddress,
        label: label ?? this.label,
        permission: permission ?? this.permission,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
        dappName: dappName ?? this.dappName,
        dappIcon: dappIcon ?? this.dappIcon,
        allowedContracts: allowedContracts ?? this.allowedContracts,
        spendingLimit: spendingLimit ?? this.spendingLimit,
        spendingToken: spendingToken ?? this.spendingToken,
        usedAmount: usedAmount ?? this.usedAmount,
        transactionCount: transactionCount ?? this.transactionCount,
        chainId: chainId ?? this.chainId,
      );
}


// ════════════════════════════════════════════════════════════════════════════
// Shared UI helpers
// ════════════════════════════════════════════════════════════════════════════

Color sessionKeyPermissionColor(SessionKeyPermission permission) {
  switch (permission) {
    case SessionKeyPermission.transfer:
      return const Color(0xFF5E97F6);
    case SessionKeyPermission.approve:
      return const Color(0xFF66BB6A);
    case SessionKeyPermission.contractCall:
      return const Color(0xFF9C27B0);
    case SessionKeyPermission.full:
      return const Color(0xFFFF5722);
  }
}

IconData sessionKeyPermissionIcon(SessionKeyPermission permission) {
  switch (permission) {
    case SessionKeyPermission.transfer:
      return Icons.send;
    case SessionKeyPermission.approve:
      return Icons.check_circle_outline;
    case SessionKeyPermission.contractCall:
      return Icons.code;
    case SessionKeyPermission.full:
      return Icons.all_inclusive;
  }
}
