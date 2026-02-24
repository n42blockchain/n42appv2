// Tests for getCoinGas() in coin_gas.dart.
// Pure function dispatches on CoinType enum — no platform deps.
// Covers: EVM chains (contract=false/true), Bitcoin-family, alt chains,
// unknown string (index==-1 → 50000), and enum values not in switch (→ 0).

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/transaction/coin_gas.dart';

void main() {
  // ─────────────────────────────────────────────────
  // EVM chains — default gas
  // ─────────────────────────────────────────────────

  group('getCoinGas — EVM chains, contract=false → 50000', () {
    for (final coin in ['ETH', 'BNB', 'MATIC', 'ETC', 'AVAX', 'OP', 'ARB', 'BASE', 'S', 'N']) {
      test('$coin → 50000', () {
        expect(getCoinGas(coin), 50000);
      });
    }
  });

  group('getCoinGas — EVM chains, contract=true → 500000', () {
    for (final coin in ['ETH', 'BNB', 'MATIC', 'ETC', 'OP', 'ARB']) {
      test('$coin contract → 500000', () {
        expect(getCoinGas(coin, contract: true), 500000);
      });
    }
  });

  // ─────────────────────────────────────────────────
  // Solana
  // ─────────────────────────────────────────────────

  group('getCoinGas — SOL', () {
    test('SOL → 1', () {
      expect(getCoinGas('SOL'), 1);
    });

    test('SOL contract=true → 1 (same value)', () {
      expect(getCoinGas('SOL', contract: true), 1);
    });
  });

  // ─────────────────────────────────────────────────
  // Tron
  // ─────────────────────────────────────────────────

  group('getCoinGas — TRX', () {
    test('TRX contract=false → 21000', () {
      expect(getCoinGas('TRX'), 21000);
    });

    test('TRX contract=true → 70000', () {
      expect(getCoinGas('TRX', contract: true), 70000);
    });
  });

  // ─────────────────────────────────────────────────
  // Bitcoin-family
  // ─────────────────────────────────────────────────

  group('getCoinGas — Bitcoin family', () {
    test('BTC → 5', () {
      expect(getCoinGas('BTC'), 5);
    });

    test('LTC → 3', () {
      expect(getCoinGas('LTC'), 3);
    });

    test('BCH → 3', () {
      expect(getCoinGas('BCH'), 3);
    });

    test('DOGE → 1000', () {
      expect(getCoinGas('DOGE'), 1000);
    });

    test('DASH → 10', () {
      expect(getCoinGas('DASH'), 10);
    });

    test('BTG → 10', () {
      expect(getCoinGas('BTG'), 10);
    });

    test('RVN → 10', () {
      expect(getCoinGas('RVN'), 10);
    });

    test('VIA → 10', () {
      expect(getCoinGas('VIA'), 10);
    });

    test('DGB → 10', () {
      expect(getCoinGas('DGB'), 10);
    });

    test('MONA → 10', () {
      expect(getCoinGas('MONA'), 10);
    });
  });

  // ─────────────────────────────────────────────────
  // Alt chains → gas = 1
  // ─────────────────────────────────────────────────

  group('getCoinGas — alt chains → 1', () {
    for (final coin in ['XTZ', 'XRP', 'ALGO', 'ATOM', 'SUI', 'TON']) {
      test('$coin → 1', () {
        expect(getCoinGas(coin), 1);
      });
    }

    test('DOT → 1', () {
      expect(getCoinGas('DOT'), 1);
    });

    test('ACA → 1', () {
      expect(getCoinGas('ACA'), 1);
    });

    test('KSM → 1', () {
      expect(getCoinGas('KSM'), 1);
    });
  });

  // ─────────────────────────────────────────────────
  // Special alt chains
  // ─────────────────────────────────────────────────

  group('getCoinGas — special alt chains', () {
    test('FIL → 10000000', () {
      expect(getCoinGas('FIL'), 10000000);
    });

    test('APT → 100', () {
      expect(getCoinGas('APT'), 100);
    });

    test('ZIL contract=false → 1', () {
      expect(getCoinGas('ZIL'), 1);
    });

    test('ZIL contract=true → 8000', () {
      expect(getCoinGas('ZIL', contract: true), 8000);
    });
  });

  // ─────────────────────────────────────────────────
  // Unknown coinType string → 50000 (index == -1)
  // ─────────────────────────────────────────────────

  group('getCoinGas — unknown coinType string', () {
    test('empty string → 50000', () {
      expect(getCoinGas(''), 50000);
    });

    test('UNKNOWN → 50000', () {
      expect(getCoinGas('UNKNOWN'), 50000);
    });

    test('lowercase eth → 50000 (coinType.toUpperCase matches ETH...)', () {
      // getCoinGas does coinType.toUpperCase() before enum lookup
      // But CoinType.ETH.name == 'ETH' so 'eth'.toUpperCase() = 'ETH' → found
      // Wait — let me check: 'ETH'.toUpperCase() = 'ETH' and CoinType.ETH.name = 'ETH'
      // So 'eth' → 'ETH' → found → 50000
      expect(getCoinGas('eth'), 50000);
    });
  });

  // ─────────────────────────────────────────────────
  // Enum values not in switch → default gas = 0
  // ─────────────────────────────────────────────────

  group('getCoinGas — enum values not in switch → 0', () {
    test('BB → 0 (in enum, not in switch)', () {
      expect(getCoinGas('BB'), 0);
    });

    test('XLM → 0 (in enum, not in switch)', () {
      expect(getCoinGas('XLM'), 0);
    });

    test('VET → 0 (in enum, not in switch)', () {
      expect(getCoinGas('VET'), 0);
    });
  });
}
