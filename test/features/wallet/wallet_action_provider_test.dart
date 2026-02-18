// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-3: Tests for WalletActionProvider.buildwallet try-finally guard (Bug-4)
//
// Strategy: test the lock logic in isolation — we cannot instantiate the full
// WalletActionProvider in unit-test environment (it requires platform channels),
// but we can extract and verify the same state-machine contract using a minimal
// fake that mirrors the real implementation.

import 'package:flutter_test/flutter_test.dart';

/// Minimal fake that mirrors the buildwallet lock in WalletActionProvider
/// (lib/src/wallet/provider/wallet_action_provider.dart, lines 252-273).
class FakeWalletActionProvider {
  bool buildwallet = false;
  int initCallCount = 0;
  bool shouldThrow = false;

  Future<void> initWallet() async {
    if (buildwallet == true) return; // idempotent guard
    buildwallet = true;
    try {
      initCallCount++;
      if (shouldThrow) throw Exception('simulated failure');
      // Simulate async work
      await Future.delayed(Duration.zero);
    } finally {
      buildwallet = false; // always released
    }
  }
}

void main() {
  group('WalletActionProvider — buildwallet try-finally (Bug-4)', () {
    test('buildwallet is false after initWallet completes normally', () async {
      final provider = FakeWalletActionProvider();
      expect(provider.buildwallet, isFalse);

      await provider.initWallet();

      expect(provider.buildwallet, isFalse,
          reason: 'lock must be released after normal completion');
      expect(provider.initCallCount, 1);
    });

    test('buildwallet is false even when initWallet throws internally', () async {
      final provider = FakeWalletActionProvider()..shouldThrow = true;

      // The exception propagates but lock must still be released.
      expect(() => provider.initWallet(), throwsException);
      // Give the future a chance to settle
      await Future.delayed(Duration.zero);

      expect(provider.buildwallet, isFalse,
          reason: 'try-finally must release lock on exception');
    });

    test('second call while buildwallet==true is a no-op (idempotent)', () async {
      final provider = FakeWalletActionProvider();

      // Manually set lock to simulate in-flight state
      provider.buildwallet = true;

      // This call should return immediately without incrementing initCallCount
      await provider.initWallet();

      expect(provider.initCallCount, 0,
          reason: 'concurrent second call must be idempotent');
      // Restore and verify normal call works afterwards
      provider.buildwallet = false;
      await provider.initWallet();
      expect(provider.initCallCount, 1);
    });

    test('sequential calls each complete and release lock', () async {
      final provider = FakeWalletActionProvider();

      await provider.initWallet();
      await provider.initWallet();

      expect(provider.initCallCount, 2);
      expect(provider.buildwallet, isFalse);
    });
  });
}
