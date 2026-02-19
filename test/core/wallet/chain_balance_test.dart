// Tests for ChainBalance — the pure data class in aggregated_coin_model.dart.
// balanceDouble uses BigInt arithmetic (no network/platform deps).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42appv2/src/wallet/models/aggregated_coin_model.dart';

void main() {
  // ─────────────────────────────────────────────────
  // ChainBalance constructor
  // ─────────────────────────────────────────────────

  group('ChainBalance constructor', () {
    test('stores all provided fields', () {
      final cb = ChainBalance(
        chainSymbol: 'ETH',
        contract: '0xUSDT',
        decimals: 18,
        chainId: 1,
        balance: BigInt.from(1000),
        address: '0xMyAddr',
      );
      expect(cb.chainSymbol, 'ETH');
      expect(cb.contract, '0xUSDT');
      expect(cb.decimals, 18);
      expect(cb.chainId, 1);
      expect(cb.balance, BigInt.from(1000));
      expect(cb.address, '0xMyAddr');
    });
  });

  // ─────────────────────────────────────────────────
  // ChainBalance.balanceDouble
  // ─────────────────────────────────────────────────

  group('ChainBalance.balanceDouble', () {
    ChainBalance _make({required BigInt balance, required int decimals}) {
      return ChainBalance(
        chainSymbol: 'TEST',
        contract: '0x0',
        decimals: decimals,
        chainId: 1,
        balance: balance,
        address: '0x0',
      );
    }

    test('zero balance → 0.0', () {
      expect(_make(balance: BigInt.zero, decimals: 18).balanceDouble, 0.0);
    });

    test('1 ETH (18 decimals) → 1.0', () {
      final cb = _make(
        balance: BigInt.parse('1000000000000000000'),
        decimals: 18,
      );
      expect(cb.balanceDouble, closeTo(1.0, 1e-9));
    });

    test('0.5 ETH (18 decimals) → 0.5', () {
      final cb = _make(
        balance: BigInt.parse('500000000000000000'),
        decimals: 18,
      );
      expect(cb.balanceDouble, closeTo(0.5, 1e-9));
    });

    test('1 USDT (6 decimals) → 1.0', () {
      final cb = _make(balance: BigInt.from(1000000), decimals: 6);
      expect(cb.balanceDouble, closeTo(1.0, 1e-9));
    });

    test('1.5 USDT (6 decimals) → 1.5', () {
      final cb = _make(balance: BigInt.from(1500000), decimals: 6);
      expect(cb.balanceDouble, closeTo(1.5, 1e-9));
    });

    test('100 USDC (6 decimals) → 100.0', () {
      final cb = _make(balance: BigInt.from(100000000), decimals: 6);
      expect(cb.balanceDouble, closeTo(100.0, 1e-6));
    });

    test('1 satoshi (8 decimals) → 0.00000001', () {
      final cb = _make(balance: BigInt.one, decimals: 8);
      expect(cb.balanceDouble, closeTo(1e-8, 1e-15));
    });

    test('1 BTC (8 decimals): 1e8 satoshi → 1.0', () {
      final cb = _make(balance: BigInt.from(100000000), decimals: 8);
      expect(cb.balanceDouble, closeTo(1.0, 1e-9));
    });

    test('large balance with 18 decimals', () {
      // 100 ETH
      final cb = _make(
        balance: BigInt.parse('100000000000000000000'),
        decimals: 18,
      );
      expect(cb.balanceDouble, closeTo(100.0, 1e-6));
    });
  });
}
