// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

part of 'bridge_provider.dart';

/// 跨链桥持久化与轮询逻辑
mixin BridgePersistenceMixin on ChangeNotifier {
  List<BridgeTransaction> get _transactions;
  Set<String> get _pendingTxHashes;

  Future<void> checkTransactionStatus(BridgeTransaction transaction);

  // ─── 轮询 ──────────────────────────────────────────────────────────────────

  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 10);
  static const Duration _pollTimeout = Duration(minutes: 10);

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

  // ─── 持久化 ──────────────────────────────────────────────────────────────────

  static const String _kPersistKey = 'bridge_transactions_v1';

  /// 将交易历史序列化写入 SharedPreferences
  // ignore: unused_element
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
}
