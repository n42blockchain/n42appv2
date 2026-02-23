// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/wallet/api/batch_transfer_api.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';

/// 批量转账状态
enum BatchTransferState {
  initial,
  parsing,
  ready,
  estimatingGas,
  gasEstimated,
  confirming,
  signing,
  broadcasting,
  awaitingConfirmation,
  success,
  error,
}

/// 批量转账 Provider
class BatchTransferProvider extends ChangeNotifier {
  final BatchTransferApi _api = BatchTransferApi();

  // 状态
  BatchTransferState _state = BatchTransferState.initial;
  BatchTransferState get state => _state;

  // 转账项目
  List<BatchTransferItem> _items = [];
  List<BatchTransferItem> get items => _items;

  // 解析错误
  List<String> _parseErrors = [];
  List<String> get parseErrors => _parseErrors;

  // Gas 估算
  BatchGasEstimate? _gasEstimate;
  BatchGasEstimate? get gasEstimate => _gasEstimate;

  // 链信息
  String _chainSymbol = '';
  String get chainSymbol => _chainSymbol;

  String _rpcUrl = '';
  int _chainId = 1;

  // Token 信息
  String? _tokenAddress;
  String _tokenSymbol = '';
  int _decimals = 18;
  String get tokenSymbol => _tokenSymbol;

  // 发送地址
  String _fromAddress = '';
  String get fromAddress => _fromAddress;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 交易结果
  String? _txHash;
  String? get txHash => _txHash;

  // 计算属性：缓存总额，避免 addItem 时 O(n²) 重复求和
  BigInt _cachedTotalAmount = BigInt.zero;
  BigInt get totalAmount => _cachedTotalAmount;
  int get recipientCount => _items.length;
  bool get isNativeToken => _tokenAddress == null || _tokenAddress!.isEmpty;
  bool get supportsMulticall => _api.supportsMulticall(_chainSymbol);

  /// 初始化
  void initialize({
    required String chainSymbol,
    required String rpcUrl,
    required int chainId,
    required String fromAddress,
    String? tokenAddress,
    required String tokenSymbol,
    required int decimals,
  }) {
    _chainSymbol = chainSymbol;
    _rpcUrl = rpcUrl;
    _chainId = chainId;
    _fromAddress = fromAddress;
    _tokenAddress = tokenAddress;
    _tokenSymbol = tokenSymbol;
    _decimals = decimals;
    _state = BatchTransferState.initial;
    _items = [];
    _parseErrors = [];
    _gasEstimate = null;
    _errorMessage = null;
    _txHash = null;
    notifyListeners();
  }

  /// 解析 CSV 内容
  Future<void> parseCsv(String csvContent) async {
    _state = BatchTransferState.parsing;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = _api.parseCsv(csvContent, _decimals);

      _items = result.items;
      _cachedTotalAmount = result.items.fold(BigInt.zero, (s, i) => s + i.amount);
      _parseErrors = result.errors;

      if (result.success) {
        _state = BatchTransferState.ready;
      } else {
        _state = BatchTransferState.error;
        _errorMessage = 'Failed to parse CSV: ${result.errors.join(', ')}';
      }
    } catch (e) {
      _state = BatchTransferState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 手动添加转账项
  void addItem(String toAddress, BigInt amount, {String? memo}) {
    final item = BatchTransferItem(
      id: 'item_${_items.length}',
      toAddress: toAddress,
      amount: amount,
      memo: memo,
    );
    _items.add(item);
    _cachedTotalAmount += amount; // 增量更新，O(1)

    if (_state == BatchTransferState.initial) {
      _state = BatchTransferState.ready;
    }

    // 清除之前的 gas 估算
    _gasEstimate = null;

    notifyListeners();
  }

  /// 移除转账项
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _cachedTotalAmount -= _items[index].amount; // 先减再移除
      _items.removeAt(index);

      if (_items.isEmpty) {
        _state = BatchTransferState.initial;
      }

      // 清除之前的 gas 估算
      _gasEstimate = null;

      notifyListeners();
    }
  }

  /// 清除所有项目
  void clearItems() {
    _items = [];
    _cachedTotalAmount = BigInt.zero;
    _parseErrors = [];
    _state = BatchTransferState.initial;
    _gasEstimate = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// 更新转账项金额
  void updateItemAmount(int index, BigInt newAmount) {
    if (index >= 0 && index < _items.length) {
      _cachedTotalAmount = _cachedTotalAmount - _items[index].amount + newAmount; // 增量调整
      _items[index] = BatchTransferItem(
        id: _items[index].id,
        toAddress: _items[index].toAddress,
        amount: newAmount,
        memo: _items[index].memo,
      );

      // 清除之前的 gas 估算
      _gasEstimate = null;

      notifyListeners();
    }
  }

  /// 估算 Gas
  Future<void> estimateGas() async {
    if (_items.isEmpty) {
      _errorMessage = 'No transfer items';
      return;
    }

    _state = BatchTransferState.estimatingGas;
    _errorMessage = null;
    notifyListeners();

    try {
      _gasEstimate = await _api.getGasEstimate(
        rpcUrl: _rpcUrl,
        chainSymbol: _chainSymbol,
        fromAddress: _fromAddress,
        tokenAddress: _tokenAddress,
        items: _items,
      );

      _state = BatchTransferState.gasEstimated;
    } catch (e) {
      _state = BatchTransferState.error;
      _errorMessage = 'Failed to estimate gas: $e';
    }

    notifyListeners();
  }

  /// 构建交易
  Future<Map<String, dynamic>?> buildTransaction() async {
    if (_gasEstimate == null) {
      await estimateGas();
      if (_gasEstimate == null) return null;
    }

    _state = BatchTransferState.confirming;
    notifyListeners();

    try {
      final nonce = await _api.getNonce(_rpcUrl, _fromAddress);

      final result = await _api.buildBatchTransaction(
        chainSymbol: _chainSymbol,
        fromAddress: _fromAddress,
        tokenAddress: _tokenAddress,
        items: _items,
        gasLimit: _gasEstimate!.gasLimit,
        nonce: nonce,
        chainId: _chainId,
        gasPrice: _gasEstimate!.isEip1559 ? null : _gasEstimate!.gasPrice,
        maxFeePerGas: _gasEstimate!.maxFeePerGas,
        maxPriorityFeePerGas: _gasEstimate!.maxPriorityFeePerGas,
      );

      if (result.error) {
        _errorMessage = result.data?.toString() ?? 'Failed to build transaction';
        _state = BatchTransferState.error;
        notifyListeners();
        return null;
      }

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      _errorMessage = e.toString();
      _state = BatchTransferState.error;
      notifyListeners();
      return null;
    }
  }

  /// 广播交易
  Future<bool> broadcastTransaction(String signedTx) async {
    _state = BatchTransferState.broadcasting;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.broadcastTransaction(_rpcUrl, signedTx);

      if (result.error) {
        _errorMessage = result.data?.toString() ?? 'Transaction failed';
        _state = BatchTransferState.error;
        notifyListeners();
        return false;
      }

      _txHash = result.data.toString();

      // 等待链上确认
      _state = BatchTransferState.awaitingConfirmation;
      notifyListeners();

      final receipt = await BatchTransferApi.waitForReceipt(_rpcUrl, _txHash!);

      if (receipt != null && receipt['status'] == '0x1') {
        // 交易成功上链
        _state = BatchTransferState.success;
        for (var item in _items) {
          item.status = BatchTransferStatus.success;
          item.txHash = _txHash;
        }
      } else if (receipt != null) {
        // 交易已上链但 reverted
        _errorMessage = 'Transaction reverted on-chain';
        _state = BatchTransferState.error;
        for (var item in _items) {
          item.status = BatchTransferStatus.failed;
          item.txHash = _txHash;
        }
        notifyListeners();
        return false;
      } else {
        // 超时：交易已广播但确认超时，标记为 pending
        _state = BatchTransferState.success;
        for (var item in _items) {
          item.status = BatchTransferStatus.pending;
          item.txHash = _txHash;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = BatchTransferState.error;
      notifyListeners();
      return false;
    }
  }

  /// 设置签名状态
  void setSigningState() {
    _state = BatchTransferState.signing;
    notifyListeners();
  }

  /// 设置错误状态
  void setError(String message) {
    _errorMessage = message;
    _state = BatchTransferState.error;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _state = BatchTransferState.initial;
    _items = [];
    _cachedTotalAmount = BigInt.zero;
    _parseErrors = [];
    _gasEstimate = null;
    _errorMessage = null;
    _txHash = null;
    notifyListeners();
  }

  /// 格式化金额显示
  String formatAmount(BigInt amount) {
    final divisor = BigInt.from(10).pow(_decimals);
    final wholePart = amount ~/ divisor;
    final fractionalPart = amount % divisor;

    if (fractionalPart == BigInt.zero) {
      return wholePart.toString();
    }

    final fractionalStr = fractionalPart.toString().padLeft(_decimals, '0');
    // 移除尾部零
    final trimmed = fractionalStr.replaceAll(RegExp(r'0+$'), '');
    return '$wholePart.$trimmed';
  }

  /// 获取 CSV 模板
  String getCsvTemplate() {
    return '# Batch transfer template\n'
        '# Columns: address, amount, memo(optional)\n'
        'address,amount,memo\n'
        '0x1234567890123456789012345678901234567890,1.5,Payment 1\n'
        '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd,2.0,Payment 2\n'
        '0x9876543210987654321098765432109876543210,0.5,';
  }

  /// 生成转账结果报告 CSV（UTF-8 with BOM，Excel 直接打开兼容）
  ///
  /// 列：No, Address, Amount (symbol), Memo, Status, TxHash, Error, Time
  String generateReportCsv() {
    final buf = StringBuffer();
    // UTF-8 BOM — Excel 识别中文不乱码
    buf.write('\uFEFF');
    buf.writeln(
        'No,Address,Amount ($_tokenSymbol),Memo,Status,TxHash,Error,Time');
    final time = DateTime.now()
        .toIso8601String()
        .replaceFirst('T', ' ')
        .substring(0, 19);
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final amount = formatAmount(item.amount);
      final memo = _escapeCsvField(item.memo ?? '');
      final txHash = item.txHash ?? '';
      final error = _escapeCsvField(item.error ?? '');
      buf.writeln(
          '${i + 1},${item.toAddress},$amount,$memo,${item.status.name},$txHash,$error,$time');
    }
    return buf.toString();
  }

  /// RFC-4180 CSV 字段转义：含逗号、双引号、换行时加引号包裹
  static String _escapeCsvField(String field) {
    if (field.contains(',') ||
        field.contains('"') ||
        field.contains('\n') ||
        field.contains('\r')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
