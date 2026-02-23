// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42appv2/src/bridge/api/lifi_api.dart';
import 'package:n42appv2/src/bridge/models/bridge_models.dart';
import 'package:n42appv2/src/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 状态变化回调：tx 已更新到终态 (completed / failed)
typedef BridgeStatusChangeCallback = void Function(
  BridgeTransaction tx,
  BridgeTransactionStatus newStatus,
);

/// 跨链桥状态
enum BridgeState {
  idle,
  loadingChains,
  loadingTokens,
  loadingQuotes,
  loadingTransaction,
  approving,
  executing,
  completed,
  error,
}

/// 跨链桥 Provider
///
/// 管理跨链桥的状态和业务逻辑
class BridgeProvider extends ChangeNotifier {
  static const String _kPersistKey = 'bridge_transactions_v1';

  final LiFiApi _lifiApi = LiFiApi();

  /// 状态变化通知回调：仅在 completed / failed 时触发。
  /// 由 UI 层设置，dispose 时应置 null 防止野回调。
  BridgeStatusChangeCallback? onStatusChanged;

  BridgeState _state = BridgeState.idle;
  BridgeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 支持的链列表
  List<BridgeChain> _chains = [];
  List<BridgeChain> get chains => _chains;

  // 代币列表（按链 ID 分组）
  final Map<int, List<BridgeToken>> _tokensByChain = {};
  List<BridgeToken> getTokensForChain(int chainId) => _tokensByChain[chainId] ?? [];

  // 选择的源链和目标链
  BridgeChain? _fromChain;
  BridgeChain? get fromChain => _fromChain;

  BridgeChain? _toChain;
  BridgeChain? get toChain => _toChain;

  // 选择的代币
  BridgeToken? _fromToken;
  BridgeToken? get fromToken => _fromToken;

  BridgeToken? _toToken;
  BridgeToken? get toToken => _toToken;

  // 输入金额
  String _fromAmount = '';
  String get fromAmount => _fromAmount;

  // 报价结果
  BridgeQuoteResponse? _quoteResponse;
  BridgeQuoteResponse? get quoteResponse => _quoteResponse;

  // 选择的路由
  BridgeRoute? _selectedRoute;
  BridgeRoute? get selectedRoute => _selectedRoute;

  // 交易历史
  final List<BridgeTransaction> _transactions = [];
  List<BridgeTransaction> get transactions => _transactions;

  // 待处理交易哈希集合，用于 O(1) 轮询过滤，替代每次 O(n) 全量扫描
  final Set<String> _pendingTxHashes = {};

  // 滑点设置
  double _slippage = 0.5;
  double get slippage => _slippage;

  // 状态轮询定时器（用于跟踪 pending/inProgress 交易）
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 10);
  static const Duration _pollTimeout = Duration(minutes: 10);

  /// 初始化：先恢复持久化历史，再加载链列表
  Future<void> initialize() async {
    await _loadPersisted();
    await loadChains();
  }

  /// 加载支持的链列表
  Future<void> loadChains() async {
    _setState(BridgeState.loadingChains);
    _clearError();

    final result = await _lifiApi.getChains();

    if (result.error) {
      _setError(result.data?.toString() ?? 'Failed to load chains');
      return;
    }

    _chains = result.data as List<BridgeChain>;

    // 默认选择 Ethereum 和 Arbitrum
    _fromChain = _chains.firstWhere(
      (c) => c.chainId == BridgeChainIds.ethereum,
      orElse: () => _chains.first,
    );
    _toChain = _chains.firstWhere(
      (c) => c.chainId == BridgeChainIds.arbitrum,
      orElse: () => _chains.length > 1 ? _chains[1] : _chains.first,
    );

    _setState(BridgeState.idle);

    // 并行加载两个链的代币，减少初始化延迟
    final futures = <Future>[];
    if (_fromChain != null) {
      futures.add(loadTokensForChain(_fromChain!.chainId));
    }
    if (_toChain != null && _toChain!.chainId != _fromChain?.chainId) {
      futures.add(loadTokensForChain(_toChain!.chainId));
    }
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  /// 加载指定链的代币列表
  Future<void> loadTokensForChain(int chainId) async {
    if (_tokensByChain.containsKey(chainId)) {
      return; // 已加载
    }

    _setState(BridgeState.loadingTokens);

    final result = await _lifiApi.getTokens(chainId: chainId);

    if (!result.error) {
      final tokens = result.data as List<BridgeToken>;
      _tokensByChain[chainId] = tokens.where((t) => t.chainId == chainId).toList();

      // 默认选择原生代币
      if (_fromChain?.chainId == chainId && _fromToken == null) {
        _fromToken = _tokensByChain[chainId]?.firstWhere(
          (t) => t.isNative,
          orElse: () => _tokensByChain[chainId]!.first,
        );
      }
      if (_toChain?.chainId == chainId && _toToken == null) {
        _toToken = _tokensByChain[chainId]?.firstWhere(
          (t) => t.isNative,
          orElse: () => _tokensByChain[chainId]!.first,
        );
      }
    }

    _setState(BridgeState.idle);
  }

  /// 设置源链
  Future<void> setFromChain(BridgeChain chain) async {
    if (_fromChain?.chainId == chain.chainId) return;

    _fromChain = chain;
    _fromToken = null;
    _quoteResponse = null;
    _selectedRoute = null;

    await loadTokensForChain(chain.chainId);

    // 选择原生代币作为默认
    final tokens = getTokensForChain(chain.chainId);
    if (tokens.isNotEmpty) {
      _fromToken = tokens.firstWhere(
        (t) => t.isNative,
        orElse: () => tokens.first,
      );
    }

    notifyListeners();
  }

  /// 设置目标链
  Future<void> setToChain(BridgeChain chain) async {
    if (_toChain?.chainId == chain.chainId) return;

    _toChain = chain;
    _toToken = null;
    _quoteResponse = null;
    _selectedRoute = null;

    await loadTokensForChain(chain.chainId);

    // 选择原生代币作为默认
    final tokens = getTokensForChain(chain.chainId);
    if (tokens.isNotEmpty) {
      _toToken = tokens.firstWhere(
        (t) => t.isNative,
        orElse: () => tokens.first,
      );
    }

    notifyListeners();
  }

  /// 交换源链和目标链
  Future<void> swapChains() async {
    final tempChain = _fromChain;
    final tempToken = _fromToken;

    _fromChain = _toChain;
    _fromToken = _toToken;
    _toChain = tempChain;
    _toToken = tempToken;

    _quoteResponse = null;
    _selectedRoute = null;

    notifyListeners();
  }

  /// 设置源代币
  void setFromToken(BridgeToken token) {
    _fromToken = token;
    _quoteResponse = null;
    _selectedRoute = null;
    notifyListeners();
  }

  /// 设置目标代币
  void setToToken(BridgeToken token) {
    _toToken = token;
    _quoteResponse = null;
    _selectedRoute = null;
    notifyListeners();
  }

  /// 设置转账金额
  void setFromAmount(String amount) {
    _fromAmount = amount;
    _quoteResponse = null;
    _selectedRoute = null;
    notifyListeners();
  }

  /// 设置滑点
  void setSlippage(double slippage) {
    _slippage = slippage;
    notifyListeners();
  }

  /// 获取报价
  Future<void> getQuote({
    required String fromAddress,
    required String toAddress,
  }) async {
    if (_fromChain == null ||
        _toChain == null ||
        _fromToken == null ||
        _toToken == null ||
        _fromAmount.isEmpty) {
      _setError('Please fill in all fields');
      return;
    }

    _setState(BridgeState.loadingQuotes);
    _clearError();

    // 将金额转换为最小单位
    final amountInWei = _parseAmount(_fromAmount, _fromToken!.decimals);

    final request = BridgeQuoteRequest(
      fromChainId: _fromChain!.chainId,
      toChainId: _toChain!.chainId,
      fromTokenAddress: _fromToken!.address.isEmpty
          ? '0x0000000000000000000000000000000000000000'
          : _fromToken!.address,
      toTokenAddress: _toToken!.address.isEmpty
          ? '0x0000000000000000000000000000000000000000'
          : _toToken!.address,
      fromAmount: amountInWei,
      fromAddress: fromAddress,
      toAddress: toAddress,
      slippage: _slippage,
    );

    // 使用 advanced/routes 获取多个路由选项
    final result = await _lifiApi.getRoutes(request);

    if (result.error) {
      _setError(result.data?.toString() ?? 'Failed to get quote');
      return;
    }

    _quoteResponse = result.data as BridgeQuoteResponse;

    if (_quoteResponse!.hasRoutes) {
      _selectedRoute = _quoteResponse!.recommendedRoute;
    } else {
      _setError('No routes available for this transfer');
      return;
    }

    _setState(BridgeState.idle);
  }

  /// 选择路由
  void selectRoute(BridgeRoute route) {
    _selectedRoute = route;
    notifyListeners();
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

    _setState(BridgeState.executing);
    _clearError();

    try {
      // 获取第一步的交易数据
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
        _setError(txResult.data?.toString() ?? 'Failed to get transaction');
        return MessageModel.error()..data = _errorMessage;
      }

      final txResponse = txResult.data as BridgeTransactionResponse;

      if (!txResponse.isSuccess || txResponse.txData == null) {
        _setError(txResponse.error ?? 'Invalid transaction data');
        return MessageModel.error()..data = _errorMessage;
      }

      // ERC-20 授权检查：原生代币无需授权
      if (!_fromToken!.isNative) {
        _setState(BridgeState.approving);

        final fromAmountBig = BigInt.tryParse(
              _parseAmount(_fromAmount, _fromToken!.decimals),
            ) ??
            BigInt.zero;
        // LiFi 合约地址即为 spender（来自 transactionRequest.to）
        final spenderAddress =
            txResponse.txData!['to']?.toString() ?? '';

        if (spenderAddress.isNotEmpty && fromAmountBig > BigInt.zero) {
          final approvalResult = await _lifiApi.getTokenApproval(
            chainId: _fromChain!.chainId,
            tokenAddress: _fromToken!.address,
            walletAddress: fromAddress,
            spenderAddress: spenderAddress,
          );

          if (!approvalResult.error && approvalResult.data != null) {
            final approvalData = approvalResult.data as Map<String, dynamic>;
            final rawAllowance =
                approvalData['allowance']?.toString() ?? '0';
            final allowance = rawAllowance.startsWith('0x')
                ? BigInt.tryParse(rawAllowance.substring(2), radix: 16) ??
                    BigInt.zero
                : BigInt.tryParse(rawAllowance) ?? BigInt.zero;

            if (allowance < fromAmountBig) {
              // 授权额度不足，先发送 approve 交易
              final approveTxResult = await _lifiApi.getApprovalTransaction(
                chainId: _fromChain!.chainId,
                tokenAddress: _fromToken!.address,
                spenderAddress: spenderAddress,
                amount: fromAmountBig.toString(),
              );

              if (!approveTxResult.error && approveTxResult.data != null) {
                final approveTxData =
                    approveTxResult.data as Map<String, dynamic>;
                final approveTxHash = await signAndSend(approveTxData);

                if (approveTxHash == null) {
                  _setError('Approval transaction cancelled');
                  return MessageModel.error()..data = _errorMessage;
                }

                // 等待授权到账（轮询 allowance，最多 60s）
                for (var i = 0; i < 20; i++) {
                  await Future.delayed(const Duration(seconds: 3));
                  final updated = await _lifiApi.getTokenApproval(
                    chainId: _fromChain!.chainId,
                    tokenAddress: _fromToken!.address,
                    walletAddress: fromAddress,
                    spenderAddress: spenderAddress,
                  );
                  if (!updated.error && updated.data != null) {
                    final updatedData = updated.data as Map<String, dynamic>;
                    final newRaw =
                        updatedData['allowance']?.toString() ?? '0';
                    final newAllowance = newRaw.startsWith('0x')
                        ? BigInt.tryParse(newRaw.substring(2), radix: 16) ??
                            BigInt.zero
                        : BigInt.tryParse(newRaw) ?? BigInt.zero;
                    if (newAllowance >= fromAmountBig) break;
                  }
                }
              }
            }
          }
        }

        _setState(BridgeState.executing);
      }

      // 签名并发送交易
      final txHash = await signAndSend(txResponse.txData!);

      if (txHash == null) {
        _setError('Transaction cancelled or failed');
        return MessageModel.error()..data = _errorMessage;
      }

      // 创建交易记录
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

      // 持久化新交易记录
      unawaited(_savePersisted());

      // 启动后台轮询，每 10s 检查一次交易状态，超时 10 分钟后停止
      _startStatusPolling();

      return MessageModel()
        ..error = false
        ..data = txHash;
    } catch (e) {
      _setError(e.toString());
      return MessageModel.error()..data = _errorMessage;
    }
  }

  /// 检查单笔交易状态，更新记录并在终态时触发回调+持久化
  Future<void> checkTransactionStatus(BridgeTransaction transaction) async {
    final result = await _lifiApi.getStatus(
      txHash: transaction.txHash,
      fromChainId: transaction.fromChainId,
      toChainId: transaction.toChainId,
      bridge: transaction.bridgeTool ?? '',
    );

    if (!result.error) {
      final statusResp = result.data as BridgeStatusResponse;
      final index = _transactions.indexWhere((t) => t.txHash == transaction.txHash);

      if (index >= 0) {
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

        final isTerminal = newStatus == BridgeTransactionStatus.completed ||
            newStatus == BridgeTransactionStatus.failed;

        if (isTerminal) {
          _pendingTxHashes.remove(transaction.txHash);
          // 终态才持久化（避免频繁写盘）
          unawaited(_savePersisted());
        }

        // 状态真正发生变化且到达终态时通知 UI（如发送通知）
        if (newStatus != oldStatus && isTerminal) {
          onStatusChanged?.call(updated, newStatus);
        }

        notifyListeners();
      }
    }
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

  /// 启动交易状态轮询
  ///
  /// 每隔 [_pollInterval] 检查所有 pending/inProgress 交易。
  /// 超过 [_pollTimeout] 或所有交易达到终态后自动停止。
  void _startStatusPolling() {
    _pollTimer?.cancel();

    final startTime = DateTime.now();

    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      // 超时停止
      if (DateTime.now().difference(startTime) >= _pollTimeout) {
        timer.cancel();
        _pollTimer = null;
        return;
      }

      // 用 Set 做 O(1) 快速判断是否还有待处理交易，避免 O(n) 全量扫描
      if (_pendingTxHashes.isEmpty) {
        timer.cancel();
        _pollTimer = null;
        return;
      }

      // 只检查 Set 中标记为待处理的交易，而非遍历整个历史列表
      final pending = _transactions
          .where((t) => _pendingTxHashes.contains(t.txHash))
          .toList();

      for (final tx in pending) {
        await checkTransactionStatus(tx);
      }
    });
  }

  /// 停止交易状态轮询
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─── 持久化 ────────────────────────────────────────────────────────────────

  /// 将交易历史序列化写入 SharedPreferences
  Future<void> _savePersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(_kPersistKey, json);
    } catch (_) {
      // 持久化失败不影响主流程
    }
  }

  /// 从 SharedPreferences 恢复交易历史，并恢复 pending 轮询
  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPersistKey);
      if (raw == null) return;

      final list = jsonDecode(raw) as List<dynamic>;
      _transactions.addAll(
        list.map((e) => BridgeTransaction.fromJson(e as Map<String, dynamic>)),
      );

      // 恢复 pending/inProgress 到轮询集合
      for (final tx in _transactions) {
        if (tx.status == BridgeTransactionStatus.pending ||
            tx.status == BridgeTransactionStatus.inProgress) {
          _pendingTxHashes.add(tx.txHash);
        }
      }
      if (_pendingTxHashes.isNotEmpty) {
        _startStatusPolling();
      }
    } catch (_) {
      // 反序列化失败时忽略，保持空历史
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }

  /// 清除状态，准备新的转账
  void reset() {
    _fromAmount = '';
    _quoteResponse = null;
    _selectedRoute = null;
    _clearError();
    _setState(BridgeState.idle);
  }

  /// 将可读金额转换为最小单位
  String _parseAmount(String amount, int decimals) {
    try {
      final parts = amount.split('.');
      final wholePart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // 补齐或截断小数位
      final paddedDecimal = decimalPart.padRight(decimals, '0').substring(0, decimals);
      final combined = wholePart + paddedDecimal;

      // 移除前导零
      return BigInt.parse(combined).toString();
    } catch (e) {
      return '0';
    }
  }

  void _setState(BridgeState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = BridgeState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
