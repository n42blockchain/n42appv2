// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// 转账请求的 per-key 串行化。
//
// nonce 在「查询 → 构建 → 签名 → 广播」窗口内没有任何互斥：用户快速
// 双击发送、或自动重试，两笔转账会查到同一个 nonce，各自签名广播 ——
// EVM/AA 均接受，结果是同一笔钱被转两次。所有 sender 的发送入口必须
// 用同一地址维度的串行化包裹，确保同一账户同一时刻只有一笔在途构建。

import 'dart:async';
import 'dart:collection';

/// 以 key（约定为 `chain:fromAddress`）为粒度串行执行异步操作。
/// 不同 key 完全并行；同 key 严格按提交顺序执行。
class TransferSerializer {
  TransferSerializer._();

  static final Map<String, Queue<Completer<void>>> _waiters = {};
  static final Set<String> _running = {};

  /// 串行执行 [action]。同 key 的并发调用按先来后到排队。
  static Future<T> run<T>(String key, Future<T> Function() action) async {
    while (_running.contains(key)) {
      final waiter = Completer<void>();
      _waiters.putIfAbsent(key, Queue.new).add(waiter);
      await waiter.future;
    }
    _running.add(key);
    try {
      return await action();
    } finally {
      _running.remove(key);
      final queue = _waiters[key];
      if (queue != null && queue.isNotEmpty) {
        queue.removeFirst().complete();
        if (queue.isEmpty) _waiters.remove(key);
      } else {
        _waiters.remove(key);
      }
    }
  }

  /// 测试用：当前是否有 key 在执行中。
  static bool get isIdle => _running.isEmpty && _waiters.isEmpty;
}
