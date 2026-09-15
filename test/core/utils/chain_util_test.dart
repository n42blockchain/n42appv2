// Tests for pure utility functions in chain_util.dart:
//   - getPathWithIndex  (pure string manipulation)
//   - toEther           (wei-to-ether conversion via Decimal)
//   - toGWei            (wei-to-gwei conversion via Decimal)
//   - decimalMap        (constant lookup table)
//
// ethToWeiString uses EtherAmount (wallet package) and is not covered here.

import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:n42_wallet/features/wallet/utils/chain/wallet_chain_registry.dart';

void main() {
  // ─────────────────────────────────────────────────
  // getPathWithIndex
  // ─────────────────────────────────────────────────

  group('getPathWithIndex', () {
    test('replaces last segment index in standard ETH path', () {
      // m/44'/60'/0'/0/0 → m/44'/60'/0'/0/5
      expect(getPathWithIndex("m/44'/60'/0'/0/0", 5), "m/44'/60'/0'/0/5");
    });

    test('index 0 replaces existing index', () {
      expect(getPathWithIndex("m/44'/60'/0'/0/1", 0), "m/44'/60'/0'/0/0");
    });

    test('hardened last segment preserves apostrophe', () {
      // m/44'/0'/0'/0' → last segment is "0'" → hardened
      expect(getPathWithIndex("m/44'/0'/0'/0'", 3), "m/44'/0'/0'/3'");
    });

    test('path with fewer than 4 segments returns path unchanged', () {
      // "m/44'/60'" splits into 3 parts → unchanged
      expect(getPathWithIndex("m/44'/60'", 2), "m/44'/60'");
    });

    test('replaces with large index correctly', () {
      expect(getPathWithIndex("m/44'/60'/0'/0/0", 100), "m/44'/60'/0'/0/100");
    });

    test('BTC legacy path replaces index', () {
      expect(getPathWithIndex("m/44'/0'/0'/0/0", 7), "m/44'/0'/0'/0/7");
    });

    test('BTC segwit path replaces index', () {
      expect(getPathWithIndex("m/84'/1'/0'/0/0", 2), "m/84'/1'/0'/0/2");
    });

    test('Taproot path replaces index', () {
      expect(getPathWithIndex("m/86'/0'/0'/0/0", 1), "m/86'/0'/0'/0/1");
    });
  });

  // ─────────────────────────────────────────────────
  // decimalMap
  // ─────────────────────────────────────────────────

  group('decimalMap', () {
    test('key "0" maps to "1.0"', () {
      expect(decimalMap['0'], '1.0');
    });

    test('key "6" maps to "1000000.0" (USDT decimals)', () {
      expect(decimalMap['6'], '1000000.0');
    });

    test('key "18" maps to "1000000000000000000.0" (ETH decimals)', () {
      expect(decimalMap['18'], '1000000000000000000.0');
    });

    test('contains entries for keys 0 through 24', () {
      for (int i = 0; i <= 24; i++) {
        expect(
          decimalMap.containsKey(i.toString()),
          isTrue,
          reason: 'decimalMap should have key "$i"',
        );
      }
    });

    test('each entry equals 10^n.0 for n in 0..18', () {
      for (int i = 0; i <= 18; i++) {
        final expected = '${BigInt.from(10).pow(i)}.0';
        expect(
          decimalMap[i.toString()],
          expected,
          reason: 'decimalMap["$i"] should be $expected',
        );
      }
    });
  });

  // ─────────────────────────────────────────────────
  // toEther
  // ─────────────────────────────────────────────────

  group('toEther', () {
    test('1 ETH in wei (18 decimals) → Decimal.one', () {
      final result = toEther('1000000000000000000', 18);
      expect(result, Decimal.one);
    });

    test('0.5 ETH → Decimal 0.5', () {
      final result = toEther('500000000000000000', 18);
      expect(result, Decimal.parse('0.5'));
    });

    test('1 USDT (6 decimals) → 1', () {
      final result = toEther('1000000', 6);
      expect(result, Decimal.one);
    });

    test('1.5 USDT (6 decimals) → 1.5', () {
      final result = toEther('1500000', 6);
      expect(result, Decimal.parse('1.5'));
    });

    test('0 wei → 0', () {
      final result = toEther('0', 18);
      expect(result, Decimal.zero);
    });

    test('1 satoshi (8 decimals) → 0.00000001 BTC', () {
      final result = toEther('1', 8);
      expect(result, Decimal.parse('0.00000001'));
    });

    test('1 BTC (8 decimals): 100000000 satoshi → 1', () {
      final result = toEther('100000000', 8);
      expect(result, Decimal.one);
    });

    test('wei longer than decimals uses substring split path', () {
      // '12345' with decimal=3: integer part='12', fractional='345'
      // → Decimal.parse('12') + Decimal.parse('0.345') = 12.345
      final result = toEther('12345', 3);
      expect(result, Decimal.parse('12.345'));
    });
  });

  // ─────────────────────────────────────────────────
  // toGWei
  // ─────────────────────────────────────────────────

  group('toGWei', () {
    test('1 gwei (1e9 wei) → 1.0', () {
      expect(toGWei('1000000000'), closeTo(1.0, 1e-9));
    });

    test('5 gwei (5e9 wei) → 5.0', () {
      expect(toGWei('5000000000'), closeTo(5.0, 1e-9));
    });

    test('100 gwei (1e11 wei) → 100.0', () {
      expect(toGWei('100000000000'), closeTo(100.0, 1e-6));
    });

    test('single digit "0" → 0.0 (length=1, parsed directly)', () {
      expect(toGWei('0'), 0.0);
    });

    test('single digit "5" → 5.0 (length=1)', () {
      expect(toGWei('5'), 5.0);
    });

    test('length 2–9 uses Decimal division', () {
      // '12345' (5 chars) → 12345 / 1e9 gwei
      expect(toGWei('12345'), closeTo(12345 / 1e9, 1e-15));
    });

    test('length > 9 uses string split path', () {
      // '12345678901' (11 chars): fix=11-9=2, → '12.345678901'
      expect(toGWei('12345678901'), closeTo(12.345678901, 1e-9));
    });
  });
}
