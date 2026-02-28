// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

// ---------------------------------------------------------------------------
// Shared hex-string parsing helpers
// ---------------------------------------------------------------------------

BigInt _parseBigInt(dynamic value) {
  if (value == null) return BigInt.zero;
  if (value is BigInt) return value;
  if (value is int) return BigInt.from(value);
  final str = value.toString();
  return str.startsWith('0x')
      ? BigInt.parse(str.substring(2), radix: 16)
      : BigInt.parse(str);
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  final str = value.toString();
  return str.startsWith('0x')
      ? int.parse(str.substring(2), radix: 16)
      : int.parse(str);
}

/// Receipt for a completed UserOperation
class UserOperationReceipt {
  /// The UserOperation hash
  final String userOpHash;

  /// The account that sent the UserOperation
  final String sender;

  /// The nonce used in the UserOperation
  final BigInt nonce;

  /// Whether the inner call (callData execution) succeeded
  final bool success;

  /// The paymaster used (if any)
  final String? paymaster;

  /// Actual gas used by the UserOperation
  final BigInt actualGasUsed;

  /// Actual gas cost (gasUsed * gasPrice)
  final BigInt actualGasCost;

  /// Transaction receipt from the bundle transaction
  final TransactionReceiptInfo receipt;

  /// Logs emitted during execution
  final List<UserOperationLog> logs;

  UserOperationReceipt({
    required this.userOpHash,
    required this.sender,
    required this.nonce,
    required this.success,
    this.paymaster,
    required this.actualGasUsed,
    required this.actualGasCost,
    required this.receipt,
    required this.logs,
  });

  factory UserOperationReceipt.fromJson(Map<String, dynamic> json) {
    return UserOperationReceipt(
      userOpHash: json['userOpHash'] as String,
      sender: json['sender'] as String,
      nonce: _parseBigInt(json['nonce']),
      success: json['success'] as bool? ?? true,
      paymaster: json['paymaster'] as String?,
      actualGasUsed: _parseBigInt(json['actualGasUsed']),
      actualGasCost: _parseBigInt(json['actualGasCost']),
      receipt: TransactionReceiptInfo.fromJson(
        json['receipt'] as Map<String, dynamic>,
      ),
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => UserOperationLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userOpHash': userOpHash,
      'sender': sender,
      'nonce': '0x${nonce.toRadixString(16)}',
      'success': success,
      'paymaster': paymaster,
      'actualGasUsed': '0x${actualGasUsed.toRadixString(16)}',
      'actualGasCost': '0x${actualGasCost.toRadixString(16)}',
      'receipt': receipt.toJson(),
      'logs': logs.map((l) => l.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'UserOperationReceipt(userOpHash: $userOpHash, success: $success, txHash: ${receipt.transactionHash})';
  }
}

/// Transaction receipt information from the bundler
class TransactionReceiptInfo {
  /// Block hash
  final String blockHash;

  /// Block number
  final BigInt blockNumber;

  /// Transaction hash
  final String transactionHash;

  /// Transaction index in block
  final int transactionIndex;

  /// From address (bundler)
  final String from;

  /// To address (EntryPoint)
  final String to;

  /// Cumulative gas used
  final BigInt cumulativeGasUsed;

  /// Gas used by this transaction
  final BigInt gasUsed;

  /// Contract address (if deployment)
  final String? contractAddress;

  /// Transaction status (1 = success, 0 = failure)
  final int status;

  /// Effective gas price
  final BigInt effectiveGasPrice;

  TransactionReceiptInfo({
    required this.blockHash,
    required this.blockNumber,
    required this.transactionHash,
    required this.transactionIndex,
    required this.from,
    required this.to,
    required this.cumulativeGasUsed,
    required this.gasUsed,
    this.contractAddress,
    required this.status,
    required this.effectiveGasPrice,
  });

  factory TransactionReceiptInfo.fromJson(Map<String, dynamic> json) {
    return TransactionReceiptInfo(
      blockHash: json['blockHash'] as String? ?? '',
      blockNumber: _parseBigInt(json['blockNumber']),
      transactionHash: json['transactionHash'] as String? ?? '',
      transactionIndex: _parseInt(json['transactionIndex']),
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      cumulativeGasUsed: _parseBigInt(json['cumulativeGasUsed']),
      gasUsed: _parseBigInt(json['gasUsed']),
      contractAddress: json['contractAddress'] as String?,
      status: _parseInt(json['status']),
      effectiveGasPrice: _parseBigInt(json['effectiveGasPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockHash': blockHash,
      'blockNumber': '0x${blockNumber.toRadixString(16)}',
      'transactionHash': transactionHash,
      'transactionIndex': '0x${transactionIndex.toRadixString(16)}',
      'from': from,
      'to': to,
      'cumulativeGasUsed': '0x${cumulativeGasUsed.toRadixString(16)}',
      'gasUsed': '0x${gasUsed.toRadixString(16)}',
      'contractAddress': contractAddress,
      'status': '0x${status.toRadixString(16)}',
      'effectiveGasPrice': '0x${effectiveGasPrice.toRadixString(16)}',
    };
  }

  bool get isSuccess => status == 1;
}

/// Event log from UserOperation execution
class UserOperationLog {
  /// Log index
  final int logIndex;

  /// Transaction index
  final int transactionIndex;

  /// Transaction hash
  final String transactionHash;

  /// Block hash
  final String blockHash;

  /// Block number
  final BigInt blockNumber;

  /// Contract address that emitted the log
  final String address;

  /// Log data
  final String data;

  /// Log topics
  final List<String> topics;

  UserOperationLog({
    required this.logIndex,
    required this.transactionIndex,
    required this.transactionHash,
    required this.blockHash,
    required this.blockNumber,
    required this.address,
    required this.data,
    required this.topics,
  });

  factory UserOperationLog.fromJson(Map<String, dynamic> json) {
    return UserOperationLog(
      logIndex: _parseInt(json['logIndex']),
      transactionIndex: _parseInt(json['transactionIndex']),
      transactionHash: json['transactionHash'] as String? ?? '',
      blockHash: json['blockHash'] as String? ?? '',
      blockNumber: _parseBigInt(json['blockNumber']),
      address: json['address'] as String? ?? '',
      data: json['data'] as String? ?? '0x',
      topics: (json['topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logIndex': '0x${logIndex.toRadixString(16)}',
      'transactionIndex': '0x${transactionIndex.toRadixString(16)}',
      'transactionHash': transactionHash,
      'blockHash': blockHash,
      'blockNumber': '0x${blockNumber.toRadixString(16)}',
      'address': address,
      'data': data,
      'topics': topics,
    };
  }
}

/// UserOperation status enum
enum UserOperationStatus {
  /// UserOperation is pending in the mempool
  pending,

  /// UserOperation is included in a block
  included,

  /// UserOperation execution succeeded
  success,

  /// UserOperation execution failed
  failed,

  /// UserOperation was replaced (nonce reused)
  replaced,

  /// Unknown status
  unknown,
}
