// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'bridge_provider.dart';

/// 跨链桥交易执行逻辑
mixin BridgeExecutionMixin on ChangeNotifier {
  BridgeApiClient get _lifiApi;
  BridgeChain? get _fromChain;
  BridgeChain? get _toChain;
  BridgeToken? get _fromToken;
  BridgeToken? get _toToken;
  String get _fromAmount;
  double get _slippage;
  BridgeRoute? get _selectedRoute;
  List<BridgeTransaction> get _transactions;
  Set<String> get _pendingTxHashes;
  BridgeStatusChangeCallback? get onStatusChanged;
  bool get _isDisposedFlag;
  void _notifySafely();

  void _setState(BridgeState state);
  void _setError(String message);
  void _clearError();
  String? get _errorMessage;
  String _parseAmount(String amount, int decimals);
  void _startStatusPolling();
  Future<void> _savePersisted();

  /// 构造错误 MessageModel 并设置内部错误状态
  MessageModel _errorResult(String message) {
    _setError(message);
    return MessageModel.error()..data = _errorMessage;
  }

  /// 执行跨链转账
  ///
  /// 返回交易哈希或错误信息
  Future<MessageModel> executeBridge({
    required String fromAddress,
    required String toAddress,
    required Future<String?> Function(Map<String, dynamic> txData) signAndSend,
  }) async {
    if (_selectedRoute == null) {
      return MessageModel.error()..data = 'No route selected';
    }
    if (_selectedRoute!.steps.isEmpty) {
      return MessageModel.error()..data = 'Route has no steps';
    }
    if (_fromChain == null || _toChain == null ||
        _fromToken == null || _toToken == null) {
      return MessageModel.error()..data = 'Incomplete bridge configuration';
    }

    _setState(BridgeState.executing);
    _clearError();

    try {
      final step = _selectedRoute!.steps.first;
      final stepJson = {
        'type': step.type,
        'tool': step.tool,
        'action': {
          'fromChainId': _fromChain!.chainId,
          'toChainId': _toChain!.chainId,
          'fromToken': _fromToken!.toJson(),
          'toToken': _toToken!.toJson(),
          'fromAmount': _parseAmount(_fromAmount, _fromToken!.decimals),
          'fromAddress': fromAddress,
          'toAddress': toAddress,
          'slippage': _slippage,
        },
      };

      final txResult = await _lifiApi.getStepTransaction(step: stepJson);
      if (txResult.error) {
        return _errorResult(
          txResult.data?.toString() ?? 'Failed to get transaction',
        );
      }

      final txResponse = txResult.data as BridgeTransactionResponse;
      if (!txResponse.isSuccess || txResponse.txData == null) {
        return _errorResult(txResponse.error ?? 'Invalid transaction data');
      }

      // ERC-20 授权检查：原生代币无需授权
      if (!_fromToken!.isNative) {
        final approved = await _handleTokenApproval(
          fromAddress,
          txResponse,
          signAndSend,
        );
        if (!approved) {
          return MessageModel.error()
            ..data = _errorMessage ?? 'Approval failed';
        }
        _setState(BridgeState.executing);
      }

      final txHash = await signAndSend(txResponse.txData!);
      if (txHash == null) {
        return _errorResult('Transaction cancelled or failed');
      }

      final transaction = BridgeTransaction(
        txHash: txHash,
        fromChainId: _fromChain!.chainId,
        toChainId: _toChain!.chainId,
        fromToken: _fromToken!,
        toToken: _toToken!,
        fromAmount: _fromAmount,
        toAmount: _selectedRoute!.toAmount,
        fromAddress: fromAddress,
        toAddress: toAddress,
        status: BridgeTransactionStatus.pending,
        createdAt: DateTime.now(),
        bridgeTool: step.tool,
      );

      _transactions.insert(0, transaction);
      _pendingTxHashes.add(transaction.txHash);
      _setState(BridgeState.completed);
      unawaited(_savePersisted());
      _startStatusPolling();

      return MessageModel()
        ..error = false
        ..data = txHash;
    } catch (e) {
      return _errorResult(e.toString());
    }
  }

  /// ERC-20 授权流程
  Future<bool> _handleTokenApproval(
    String fromAddress,
    BridgeTransactionResponse txResponse,
    Future<String?> Function(Map<String, dynamic> txData) signAndSend,
  ) async {
    _setState(BridgeState.approving);

    final fromAmountBig =
        BigInt.tryParse(_parseAmount(_fromAmount, _fromToken!.decimals)) ??
        BigInt.zero;
    // LiFi 合约地址即为 spender（来自 transactionRequest.to）
    final spenderAddress = txResponse.txData!['to']?.toString() ?? '';

    if (spenderAddress.isEmpty) {
      _setError('Missing approval spender');
      return false;
    }
    if (fromAmountBig <= BigInt.zero) {
      _setError('Invalid approval amount');
      return false;
    }

    final approvalResult = await _lifiApi.getTokenApproval(
      chainId: _fromChain!.chainId,
      tokenAddress: _fromToken!.address,
      walletAddress: fromAddress,
      spenderAddress: spenderAddress,
    );

    if (approvalResult.error || approvalResult.data == null) {
      _setError(
        approvalResult.data?.toString() ?? 'Failed to get approval status',
      );
      return false;
    }

    final allowance = _parseAllowance(
      approvalResult.data as Map<String, dynamic>,
    );

    if (allowance >= fromAmountBig) return true;

    // 授权额度不足，先发送 approve 交易
    final approveTxResult = await _lifiApi.getApprovalTransaction(
      chainId: _fromChain!.chainId,
      tokenAddress: _fromToken!.address,
      spenderAddress: spenderAddress,
      amount: fromAmountBig.toString(),
    );

    if (approveTxResult.error || approveTxResult.data == null) {
      _setError(
        approveTxResult.data?.toString() ??
            'Failed to get approval transaction',
      );
      return false;
    }

    final approveTxData = approveTxResult.data as Map<String, dynamic>;
    final approveTxHash = await signAndSend(approveTxData);

    if (approveTxHash == null) {
      _setError('Approval transaction cancelled');
      return false;
    }

    // 等待授权到账（轮询 allowance，最多 60s）
    final approved = await _waitForApproval(
      fromAddress,
      spenderAddress,
      fromAmountBig,
    );
    if (!approved) {
      _setError('Approval not confirmed in time');
      return false;
    }
    return true;
  }

  /// 轮询等待 ERC-20 授权到账
  Future<bool> _waitForApproval(
    String fromAddress,
    String spenderAddress,
    BigInt requiredAmount,
  ) async {
    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 3));
      final updated = await _lifiApi.getTokenApproval(
        chainId: _fromChain!.chainId,
        tokenAddress: _fromToken!.address,
        walletAddress: fromAddress,
        spenderAddress: spenderAddress,
      );
      if (!updated.error && updated.data != null) {
        final newAllowance = _parseAllowance(
          updated.data as Map<String, dynamic>,
        );
        if (newAllowance >= requiredAmount) return true;
      }
    }
    return false;
  }

  /// 解析 allowance 值（支持 0x 前缀和十进制字符串）
  BigInt _parseAllowance(Map<String, dynamic> data) {
    final raw = data['allowance']?.toString() ?? '0';
    if (raw.startsWith('0x')) {
      return BigInt.tryParse(raw.substring(2), radix: 16) ?? BigInt.zero;
    }
    return BigInt.tryParse(raw) ?? BigInt.zero;
  }

  /// 判断交易状态是否为终态（完成或失败）
  bool _isTerminalStatus(BridgeTransactionStatus status) =>
      status == BridgeTransactionStatus.completed ||
      status == BridgeTransactionStatus.failed;

  /// 检查单笔交易状态，更新记录并在终态时触发回调+持久化
  Future<void> checkTransactionStatus(BridgeTransaction transaction) async {
    if (_isDisposedFlag) return;
    final result = await _lifiApi.getStatus(
      txHash: transaction.txHash,
      fromChainId: transaction.fromChainId,
      toChainId: transaction.toChainId,
      bridge: transaction.bridgeTool ?? '',
    );
    if (_isDisposedFlag) return;
    if (result.error) return;

    final statusResp = result.data as BridgeStatusResponse;
    final index = _transactions.indexWhere(
      (t) => t.txHash == transaction.txHash,
    );
    if (index < 0) return;

    final oldStatus = _transactions[index].status;
    final newStatus = statusResp.status;

    final updated = BridgeTransaction(
      txHash: transaction.txHash,
      fromChainId: transaction.fromChainId,
      toChainId: transaction.toChainId,
      fromToken: transaction.fromToken,
      toToken: transaction.toToken,
      fromAmount: transaction.fromAmount,
      toAmount: transaction.toAmount,
      fromAddress: transaction.fromAddress,
      toAddress: transaction.toAddress,
      status: newStatus,
      createdAt: transaction.createdAt,
      bridgeTool: transaction.bridgeTool,
      destinationTxHash: statusResp.destinationTxHash,
    );
    _transactions[index] = updated;

    if (_isTerminalStatus(newStatus)) {
      _pendingTxHashes.remove(transaction.txHash);
      unawaited(_savePersisted());
      if (newStatus != oldStatus) {
        onStatusChanged?.call(updated, newStatus);
      }
    }

    _notifySafely();
  }

  /// 主动刷新所有 pending/inProgress 交易状态（供下拉刷新使用）
  Future<void> refreshPendingTransactions() async {
    final pending = _transactions
        .where((t) => _pendingTxHashes.contains(t.txHash))
        .toList();
    for (final tx in pending) {
      await checkTransactionStatus(tx);
    }
  }

  BridgeState get state;
}
