// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/bridge/api/lifi_api.dart';
import 'package:n42_wallet/features/bridge/models/bridge_models.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part '_bridge_execution.dart';
part '_bridge_persistence.dart';

/// 状态变化回调：tx 已更新到终态 (completed / failed)
typedef BridgeStatusChangeCallback =
    void Function(BridgeTransaction tx, BridgeTransactionStatus newStatus);

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
class BridgeProvider extends ChangeNotifier
    with BridgePersistenceMixin, BridgeExecutionMixin {
  static final _amountRegex = RegExp(r'^\d+\.?\d*$');
  BridgeProvider({BridgeApiClient? lifiApi}) : _lifiApi = lifiApi ?? LiFiApi();

  @override
  final BridgeApiClient _lifiApi;
  bool _isDisposed = false;
  int _quoteGeneration = 0;

  void _invalidateQuote() {
    ++_quoteGeneration;
    _quoteResponse = null;
    __selectedRoute = null;
    if (_state == BridgeState.loadingQuotes) _state = BridgeState.idle;
  }

  /// 状态变化通知回调：仅在 completed / failed 时触发。
  /// 由 UI 层设置，dispose 时应置 null 防止野回调。
  @override
  BridgeStatusChangeCallback? onStatusChanged;

  BridgeState _state = BridgeState.idle;
  @override
  BridgeState get state => _state;

  String? __errorMessage;
  @override
  String? get _errorMessage => __errorMessage;

  /// Public error message for UI consumption.
  String? get errorMessage => __errorMessage;

  // 支持的链列表
  List<BridgeChain> _chains = [];
  List<BridgeChain> get chains => _chains;

  // 代币列表（按链 ID 分组）
  final Map<int, List<BridgeToken>> _tokensByChain = {};
  List<BridgeToken> getTokensForChain(int chainId) =>
      _tokensByChain[chainId] ?? [];

  // 选择的源链和目标链
  BridgeChain? __fromChain;
  @override
  BridgeChain? get _fromChain => __fromChain;

  BridgeChain? __toChain;
  @override
  BridgeChain? get _toChain => __toChain;
  BridgeChain? get fromChain => __fromChain;
  BridgeChain? get toChain => __toChain;

  // 选择的代币
  BridgeToken? __fromToken;
  @override
  BridgeToken? get _fromToken => __fromToken;

  BridgeToken? __toToken;
  @override
  BridgeToken? get _toToken => __toToken;
  BridgeToken? get fromToken => __fromToken;
  BridgeToken? get toToken => __toToken;

  // 输入金额
  String __fromAmount = '';
  @override
  String get _fromAmount => __fromAmount;
  String get fromAmount => __fromAmount;

  // 报价结果
  BridgeQuoteResponse? _quoteResponse;
  BridgeQuoteResponse? get quoteResponse => _quoteResponse;

  // 选择的路由
  BridgeRoute? __selectedRoute;
  @override
  BridgeRoute? get _selectedRoute => __selectedRoute;
  BridgeRoute? get selectedRoute => __selectedRoute;

  // 交易历史
  @override
  final List<BridgeTransaction> _transactions = [];
  List<BridgeTransaction> get transactions => _transactions;

  // 待处理交易哈希集合，用于 O(1) 轮询过滤，替代每次 O(n) 全量扫描
  @override
  final Set<String> _pendingTxHashes = {};

  // 滑点设置
  double __slippage = 0.5;
  @override
  double get _slippage => __slippage;
  double get slippage => __slippage;
  @override
  bool get _isDisposedFlag => _isDisposed;

  /// 初始化：先恢复持久化历史，再加载链列表
  Future<void> initialize() async {
    await _loadPersisted();
    if (_isDisposed) return;
    await loadChains();
  }

  /// 加载支持的链列表
  Future<void> loadChains() async {
    _setState(BridgeState.loadingChains);
    _clearError();

    final result = await _lifiApi.getChains();
    if (_isDisposed) return;

    if (result.error) {
      _setError(result.data?.toString() ?? 'Failed to load chains');
      return;
    }

    _chains = result.data as List<BridgeChain>;
    if (_chains.isEmpty) {
      _setError('No supported chains available');
      return;
    }

    // 默认选择 Ethereum 和 Arbitrum
    __fromChain = _chains.firstWhere(
      (c) => c.chainId == BridgeChainIds.ethereum,
      orElse: () => _chains.first,
    );
    __toChain = _chains.firstWhere(
      (c) => c.chainId == BridgeChainIds.arbitrum,
      orElse: () => _chains.length > 1 ? _chains[1] : _chains.first,
    );

    _setState(BridgeState.idle);

    // 并行加载两个链的代币，减少初始化延迟
    final futures = <Future>[];
    if (__fromChain != null) {
      futures.add(loadTokensForChain(__fromChain!.chainId));
    }
    if (__toChain != null && __toChain!.chainId != __fromChain?.chainId) {
      futures.add(loadTokensForChain(__toChain!.chainId));
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
    if (_isDisposed) return;

    if (!result.error) {
      final tokens = result.data as List<BridgeToken>;
      _tokensByChain[chainId] = tokens
          .where((t) => t.chainId == chainId)
          .toList();

      // 默认选择原生代币
      if (__fromChain?.chainId == chainId &&
          __fromToken == null &&
          _tokensByChain[chainId]!.isNotEmpty) {
        __fromToken = _tokensByChain[chainId]?.firstWhere(
          (t) => t.isNative,
          orElse: () => _tokensByChain[chainId]!.first,
        );
      }
      if (__toChain?.chainId == chainId &&
          __toToken == null &&
          _tokensByChain[chainId]!.isNotEmpty) {
        __toToken = _tokensByChain[chainId]?.firstWhere(
          (t) => t.isNative,
          orElse: () => _tokensByChain[chainId]!.first,
        );
      }
    }

    _setState(BridgeState.idle);
  }

  /// 设置源链
  Future<void> setFromChain(BridgeChain chain) async {
    if (__fromChain?.chainId == chain.chainId) return;

    __fromChain = chain;
    __fromToken = null;
    _invalidateQuote();

    await loadTokensForChain(chain.chainId);
    if (_isDisposed || __fromChain?.chainId != chain.chainId) return;

    // 选择原生代币作为默认
    final tokens = getTokensForChain(chain.chainId);
    if (tokens.isNotEmpty) {
      __fromToken = tokens.firstWhere(
        (t) => t.isNative,
        orElse: () => tokens.first,
      );
    }

    _notifySafely();
  }

  /// 设置目标链
  Future<void> setToChain(BridgeChain chain) async {
    if (__toChain?.chainId == chain.chainId) return;

    __toChain = chain;
    __toToken = null;
    _invalidateQuote();

    await loadTokensForChain(chain.chainId);
    if (_isDisposed || __toChain?.chainId != chain.chainId) return;

    // 选择原生代币作为默认
    final tokens = getTokensForChain(chain.chainId);
    if (tokens.isNotEmpty) {
      __toToken = tokens.firstWhere(
        (t) => t.isNative,
        orElse: () => tokens.first,
      );
    }

    _notifySafely();
  }

  /// 交换源链和目标链
  Future<void> swapChains() async {
    final tempChain = __fromChain;
    final tempToken = __fromToken;

    __fromChain = __toChain;
    __fromToken = __toToken;
    __toChain = tempChain;
    __toToken = tempToken;

    _invalidateQuote();

    _notifySafely();
  }

  /// 设置源代币
  void setFromToken(BridgeToken token) {
    __fromToken = token;
    _invalidateQuote();
    _notifySafely();
  }

  /// 设置目标代币
  void setToToken(BridgeToken token) {
    __toToken = token;
    _invalidateQuote();
    _notifySafely();
  }

  /// 设置转账金额
  void setFromAmount(String amount) {
    __fromAmount = amount;
    _invalidateQuote();
    _notifySafely();
  }

  /// 设置滑点
  void setSlippage(double slippage) {
    __slippage = slippage;
    _invalidateQuote();
    _notifySafely();
  }

  /// 获取报价
  Future<void> getQuote({
    required String fromAddress,
    required String toAddress,
  }) async {
    if (__fromChain == null ||
        __toChain == null ||
        __fromToken == null ||
        __toToken == null ||
        __fromAmount.isEmpty) {
      _setError('Please fill in all fields');
      return;
    }

    final generation = ++_quoteGeneration;
    _quoteResponse = null;
    __selectedRoute = null;
    _setState(BridgeState.loadingQuotes);
    _clearError();

    // 将金额转换为最小单位
    final amountInWei = _parseAmount(__fromAmount, __fromToken!.decimals);
    if ((BigInt.tryParse(amountInWei) ?? BigInt.zero) <= BigInt.zero) {
      _setError('Invalid amount');
      return;
    }

    final request = BridgeQuoteRequest(
      fromChainId: __fromChain!.chainId,
      toChainId: __toChain!.chainId,
      fromTokenAddress: __fromToken!.address.isEmpty
          ? '0x0000000000000000000000000000000000000000'
          : __fromToken!.address,
      toTokenAddress: __toToken!.address.isEmpty
          ? '0x0000000000000000000000000000000000000000'
          : __toToken!.address,
      fromAmount: amountInWei,
      fromAddress: fromAddress,
      toAddress: toAddress,
      slippage: __slippage,
    );

    // 使用 advanced/routes 获取多个路由选项
    try {
      final result = await _lifiApi.getRoutes(request);
      if (_isDisposed || generation != _quoteGeneration) return;
      if (result.error) {
        _setError(result.data?.toString() ?? 'Failed to get quote');
        return;
      }
      _quoteResponse = result.data as BridgeQuoteResponse;
      if (!_quoteResponse!.hasRoutes) {
        _setError('No routes available for this transfer');
        return;
      }
      __selectedRoute = _quoteResponse!.recommendedRoute;
      _setState(BridgeState.idle);
    } catch (_) {
      if (!_isDisposed && generation == _quoteGeneration) {
        _setError('Failed to get quote');
      }
    }
  }

  /// 选择路由
  void selectRoute(BridgeRoute route) {
    __selectedRoute = route;
    _notifySafely();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    _pollTimer = null;
    onStatusChanged = null;
    super.dispose();
  }

  /// 清除状态，准备新的转账
  void reset() {
    __fromAmount = '';
    _invalidateQuote();
    _clearError();
    _setState(BridgeState.idle);
  }

  /// 将可读金额转换为最小单位
  @override
  String _parseAmount(String amount, int decimals) {
    if (amount.isEmpty) return '0';
    try {
      // Validate input contains only digits and at most one decimal point
      if (!_amountRegex.hasMatch(amount)) {
        _setError('Invalid amount format');
        return '0';
      }
      final parts = amount.split('.');
      final wholePart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      // 补齐或截断小数位
      final paddedDecimal = decimalPart
          .padRight(decimals, '0')
          .substring(0, decimals);
      final combined = wholePart + paddedDecimal;

      // 移除前导零
      return BigInt.parse(combined).toString();
    } catch (e) {
      return '0';
    }
  }

  @override
  void _setState(BridgeState state) {
    if (_isDisposed) return;
    _state = state;
    _notifySafely();
  }

  @override
  void _setError(String message) {
    if (_isDisposed) return;
    __errorMessage = message;
    _state = BridgeState.error;
    _notifySafely();
  }

  @override
  void _clearError() {
    __errorMessage = null;
  }

  @override
  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }
}
