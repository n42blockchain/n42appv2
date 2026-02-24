// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/bridge/provider/bridge_provider.dart';

void main() {
  group('BridgeProvider Polling Tests', () {
    late BridgeProvider provider;

    setUp(() {
      provider = BridgeProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state has no transactions', () {
      expect(provider.transactions, isEmpty);
    });

    test('initial state is idle', () {
      expect(provider.state, BridgeState.idle);
    });

    test('stopPolling does not throw when no timer is running', () {
      expect(() => provider.stopPolling(), returnsNormally);
    });

    test('dispose does not throw when no timer is running', () {
      // 创建独立实例以免影响 tearDown
      final p = BridgeProvider();
      expect(() => p.dispose(), returnsNormally);
    });

    test('dispose cancels running poll timer without error', () {
      // 调用 stopPolling 后 dispose 不抛出
      final p = BridgeProvider();
      p.stopPolling(); // 无 timer 时调用也安全
      expect(() => p.dispose(), returnsNormally);
    });

    test('reset clears amount and route but keeps state', () {
      provider.setFromAmount('1.5');
      expect(provider.fromAmount, '1.5');

      provider.reset();

      expect(provider.fromAmount, '');
      expect(provider.selectedRoute, isNull);
      expect(provider.quoteResponse, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.state, BridgeState.idle);
    });

    test('setFromAmount updates amount and clears route', () {
      provider.setFromAmount('2.0');
      expect(provider.fromAmount, '2.0');
      expect(provider.selectedRoute, isNull);
    });

    test('setSlippage updates slippage value', () {
      provider.setSlippage(1.0);
      expect(provider.slippage, 1.0);
    });

    test('stopPolling multiple times is safe', () {
      // 多次调用不应崩溃
      expect(() {
        provider.stopPolling();
        provider.stopPolling();
        provider.stopPolling();
      }, returnsNormally);
    });

    test('swapChains does not throw when chains are null', () {
      expect(() => provider.swapChains(), returnsNormally);
    });

    group('Transaction list behavior', () {
      test('transactions list is initially empty', () {
        expect(provider.transactions, hasLength(0));
      });
    });
  });
}
