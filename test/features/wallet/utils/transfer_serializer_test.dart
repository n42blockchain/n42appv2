// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// 转账串行化回归：同一账户的并发发送必须严格串行（nonce 竞态防双花），
// 不同账户互不阻塞。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/transfer_serializer.dart';

void main() {
  test('same key runs strictly sequentially in submission order', () async {
    final log = <String>[];

    Future<void> task(String name, Duration work) =>
        TransferSerializer.run('ETH:0xabc', () async {
          log.add('$name-start');
          await Future<void>.delayed(work);
          log.add('$name-end');
        });

    await Future.wait([
      task('t1', const Duration(milliseconds: 30)),
      task('t2', const Duration(milliseconds: 10)),
      task('t3', const Duration(milliseconds: 1)),
    ]);

    expect(log, [
      't1-start', 't1-end',
      't2-start', 't2-end',
      't3-start', 't3-end',
    ]);
    expect(TransferSerializer.isIdle, isTrue);
  });

  test('different keys run concurrently', () async {
    final running = <String>{};
    var maxConcurrent = 0;

    Future<void> task(String key) => TransferSerializer.run(key, () async {
          running.add(key);
          maxConcurrent =
              maxConcurrent > running.length ? maxConcurrent : running.length;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          running.remove(key);
        });

    await Future.wait([task('ETH:0xaaa'), task('ETH:0xbbb'), task('BTC:bc1q')]);

    expect(maxConcurrent, 3, reason: '不同账户的转账不应互相阻塞');
    expect(TransferSerializer.isIdle, isTrue);
  });

  test('a throwing action releases the lock for the next caller', () async {
    Object? caught;
    try {
      await TransferSerializer.run('ETH:0xabc', () async {
        throw StateError('boom');
      });
    } catch (e) {
      caught = e;
    }
    expect(caught, isA<StateError>());

    // 锁必须已释放，后续转账不被卡死。
    final result = await TransferSerializer.run('ETH:0xabc', () async => 42);
    expect(result, 42);
    expect(TransferSerializer.isIdle, isTrue);
  });

  test('returns the action result', () async {
    final r = await TransferSerializer.run('k', () async => 'tx-hash');
    expect(r, 'tx-hash');
  });
}
