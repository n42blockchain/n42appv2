// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

/// 批量转账状态
enum BatchTransferStatus {
  pending,
  processing,
  success,
  failed,
}

/// 单笔转账项
class BatchTransferItem {
  final String id;
  final String toAddress;
  final BigInt amount;
  final String? memo;
  BatchTransferStatus status;
  String? txHash;
  String? error;

  BatchTransferItem({
    required this.id,
    required this.toAddress,
    required this.amount,
    this.memo,
    this.status = BatchTransferStatus.pending,
    this.txHash,
    this.error,
  });

  /// 从 CSV 行解析
  factory BatchTransferItem.fromCsvRow(String row, int index, int decimals) {
    final parts = row.split(',').map((e) => e.trim()).toList();
    if (parts.length < 2) {
      throw FormatException('Invalid CSV format at line ${index + 1}');
    }

    final address = parts[0];
    final amountStr = parts[1];
    final memo = parts.length > 2 ? parts[2] : null;

    // 验证地址格式
    if (!_isValidEthAddress(address)) {
      throw FormatException('Invalid address at line ${index + 1}: $address');
    }

    // 解析金额
    final amount = _parseAmount(amountStr, decimals);
    if (amount <= BigInt.zero) {
      throw FormatException('Invalid amount at line ${index + 1}: $amountStr');
    }

    return BatchTransferItem(
      id: 'item_$index',
      toAddress: address,
      amount: amount,
      memo: memo,
    );
  }

  static final RegExp _ethAddressRegExp = RegExp(r'^0x[a-fA-F0-9]{40}$');

  static bool _isValidEthAddress(String address) {
    return _ethAddressRegExp.hasMatch(address);
  }

  static BigInt _parseAmount(String amountStr, int decimals) {
    try {
      // 移除可能的空格和逗号
      amountStr = amountStr.replaceAll(' ', '').replaceAll(',', '');

      // 处理小数点
      if (amountStr.contains('.')) {
        final parts = amountStr.split('.');
        final intPart = parts[0];
        var decPart = parts[1];

        // 填充或截断小数部分
        if (decPart.length > decimals) {
          decPart = decPart.substring(0, decimals);
        } else {
          decPart = decPart.padRight(decimals, '0');
        }

        return BigInt.parse('$intPart$decPart');
      } else {
        // 整数，需要乘以 10^decimals
        return BigInt.parse(amountStr) * BigInt.from(10).pow(decimals);
      }
    } catch (e) {
      return BigInt.zero;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'toAddress': toAddress,
    'amount': amount.toString(),
    'memo': memo,
    'status': status.name,
    'txHash': txHash,
    'error': error,
  };
}

/// 批量转账请求
class BatchTransferRequest {
  final String chainSymbol;
  final String fromAddress;
  final String? tokenAddress; // null 表示原生代币
  final String tokenSymbol;
  final int decimals;
  final List<BatchTransferItem> items;
  final bool useMulticall;

  BatchTransferRequest({
    required this.chainSymbol,
    required this.fromAddress,
    this.tokenAddress,
    required this.tokenSymbol,
    required this.decimals,
    required this.items,
    this.useMulticall = true,
  });

  /// 计算总金额
  BigInt get totalAmount {
    return items.fold(BigInt.zero, (sum, item) => sum + item.amount);
  }

  /// 获取接收者数量
  int get recipientCount => items.length;

  /// 检查是否为原生代币
  bool get isNativeToken => tokenAddress == null || tokenAddress!.isEmpty;
}

/// 批量转账结果
class BatchTransferResult {
  final bool success;
  final String? txHash;
  final List<BatchTransferItem> items;
  final String? error;
  final BigInt? totalGasUsed;

  BatchTransferResult({
    required this.success,
    this.txHash,
    required this.items,
    this.error,
    this.totalGasUsed,
  });

  factory BatchTransferResult.success(String txHash, List<BatchTransferItem> items, BigInt gasUsed) {
    return BatchTransferResult(
      success: true,
      txHash: txHash,
      items: items,
      totalGasUsed: gasUsed,
    );
  }

  factory BatchTransferResult.failure(String error, List<BatchTransferItem> items) {
    return BatchTransferResult(
      success: false,
      error: error,
      items: items,
    );
  }
}

/// Gas 估算结果
class BatchGasEstimate {
  final BigInt gasLimit;
  final BigInt gasPrice;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final BigInt totalFee;
  final bool isEip1559;

  BatchGasEstimate({
    required this.gasLimit,
    required this.gasPrice,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    required this.totalFee,
    required this.isEip1559,
  });
}

/// CSV 解析结果
class CsvParseResult {
  final bool success;
  final List<BatchTransferItem> items;
  final List<String> errors;
  final int totalLines;
  final int validLines;

  CsvParseResult({
    required this.success,
    required this.items,
    required this.errors,
    required this.totalLines,
    required this.validLines,
  });

  factory CsvParseResult.success(List<BatchTransferItem> items, int totalLines) {
    return CsvParseResult(
      success: true,
      items: items,
      errors: [],
      totalLines: totalLines,
      validLines: items.length,
    );
  }

  factory CsvParseResult.partial(List<BatchTransferItem> items, List<String> errors, int totalLines) {
    return CsvParseResult(
      success: items.isNotEmpty,
      items: items,
      errors: errors,
      totalLines: totalLines,
      validLines: items.length,
    );
  }

  factory CsvParseResult.failure(List<String> errors, int totalLines) {
    return CsvParseResult(
      success: false,
      items: [],
      errors: errors,
      totalLines: totalLines,
      validLines: 0,
    );
  }
}
