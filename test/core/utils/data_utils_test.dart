// Tests for DataUtils utility class.
// Covers pure-Dart methods; getTimeByTimeStamp is excluded because it depends on
// flustars_flutter3's DateUtil which requires Flutter binding initialisation.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';

void main() {
  final utils = DataUtils();

  // ─────────────────────────────────────────────────
  // strip0x
  // ─────────────────────────────────────────────────

  group('DataUtils.strip0x', () {
    test('strips 0x prefix', () {
      expect(utils.strip0x('0x1234abcd'), '1234abcd');
    });

    test('no prefix — returns unchanged', () {
      expect(utils.strip0x('abcdef'), 'abcdef');
    });

    test('0x prefix only — returns empty string', () {
      expect(utils.strip0x('0x'), '');
    });

    test('0X (uppercase) is NOT stripped — returns as-is', () {
      // The method only checks startsWith('0x'), not '0X'
      expect(utils.strip0x('0XABCD'), '0XABCD');
    });

    test('empty string returns empty string', () {
      expect(utils.strip0x(''), '');
    });
  });

  // ─────────────────────────────────────────────────
  // add0x
  // ─────────────────────────────────────────────────

  group('DataUtils.add0x', () {
    test('prepends 0x to hex string', () {
      expect(utils.add0x('abcd'), '0xabcd');
    });

    test('adds 0x even if already prefixed', () {
      // The method always prepends without checking — double-prefix possible
      expect(utils.add0x('0x1234'), '0x0x1234');
    });

    test('empty string becomes "0x"', () {
      expect(utils.add0x(''), '0x');
    });
  });

  // ─────────────────────────────────────────────────
  // hexToBigInt
  // ─────────────────────────────────────────────────

  group('DataUtils.hexToBigInt', () {
    test('converts hex without prefix', () {
      expect(utils.hexToBigInt('ff'), BigInt.from(255));
    });

    test('converts hex with 0x prefix', () {
      expect(utils.hexToBigInt('0x0a'), BigInt.from(10));
    });

    test('zero hex returns BigInt.zero', () {
      expect(utils.hexToBigInt('0'), BigInt.zero);
    });

    test('empty string returns BigInt.zero (strip → "0")', () {
      expect(utils.hexToBigInt('0x'), BigInt.zero);
    });

    test('large hex value', () {
      expect(utils.hexToBigInt('0x100'), BigInt.from(256));
    });

    test('uppercase hex is handled', () {
      expect(utils.hexToBigInt('FF'), BigInt.from(255));
    });
  });

  // ─────────────────────────────────────────────────
  // bigIntToHex
  // ─────────────────────────────────────────────────

  group('DataUtils.bigIntToHex', () {
    test('255 → "0xff" with 0x prefix (default)', () {
      expect(utils.bigIntToHex(BigInt.from(255)), '0xff');
    });

    test('255 → "ff" without 0x prefix', () {
      expect(utils.bigIntToHex(BigInt.from(255), need0x: false), 'ff');
    });

    test('BigInt.zero → "0x0"', () {
      expect(utils.bigIntToHex(BigInt.zero), '0x0');
    });

    test('padToEvenLength: odd-length hex gets leading zero', () {
      // BigInt.from(15) → radixString '0f' ? No: 15 → 'f' (length 1, odd)
      // With padToEvenLength=true: '0f'
      expect(
        utils.bigIntToHex(BigInt.from(15), need0x: false, padToEvenLength: true),
        '0f',
      );
    });

    test('padToEvenLength: even-length hex unchanged', () {
      // BigInt.from(255) → 'ff' (length 2, even)
      expect(
        utils.bigIntToHex(BigInt.from(255), need0x: false, padToEvenLength: true),
        'ff',
      );
    });

    test('256 → "100" (3 hex digits)', () {
      expect(utils.bigIntToHex(BigInt.from(256), need0x: false), '100');
    });
  });

  // ─────────────────────────────────────────────────
  // sameList
  // ─────────────────────────────────────────────────

  group('DataUtils.sameList', () {
    test('identical lists are equal', () {
      expect(utils.sameList([1, 2, 3], [1, 2, 3]), isTrue);
    });

    test('different length lists are not equal', () {
      expect(utils.sameList([1, 2], [1, 2, 3]), isFalse);
    });

    test('same elements in different order are not equal', () {
      expect(utils.sameList([1, 2, 3], [3, 2, 1]), isFalse);
    });

    test('empty lists are equal', () {
      expect(utils.sameList([], []), isTrue);
    });

    test('string lists compared correctly', () {
      expect(utils.sameList(['a', 'b'], ['a', 'b']), isTrue);
    });

    test('string lists with different values', () {
      expect(utils.sameList(['a', 'b'], ['a', 'c']), isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // addressFarmat (sic)
  // ─────────────────────────────────────────────────

  group('DataUtils.addressFarmat', () {
    test('empty string returns empty', () {
      expect(utils.addressFarmat(''), '');
    });

    test('formats long address: first 7 + ellipsis + last 9', () {
      // '0x1234567890abcdef123' (21 chars)
      // first 7: '0x12345'
      // last 9: 'abcdef123'
      const addr = '0x1234567890abcdef123';
      expect(utils.addressFarmat(addr), '0x12345...abcdef123');
    });

    test('produces ellipsis separator', () {
      const addr = '0xABCDEFGHIJKLMNOPQRSTUV';
      final result = utils.addressFarmat(addr);
      expect(result, contains('...'));
    });
  });

  // ─────────────────────────────────────────────────
  // formatNum
  // ─────────────────────────────────────────────────

  group('DataUtils.formatNum', () {
    test('truncates excess decimal places', () {
      expect(utils.formatNum(3.14159, 2), '3.14');
    });

    test('pads missing decimal places', () {
      expect(utils.formatNum(3.1, 3), '3.100');
    });

    test('integer-like value with decimal places', () {
      final result = utils.formatNum(5.0, 2);
      expect(result, '5.00');
    });

    test('exact decimal count returns unchanged', () {
      expect(utils.formatNum(1.55, 2), '1.55');
    });
  });

  // ─────────────────────────────────────────────────
  // shuffle
  // ─────────────────────────────────────────────────

  group('DataUtils.shuffle', () {
    test('shuffle returns list of same length', () {
      final result = utils.shuffle([1, 2, 3, 4, 5]);
      expect(result.length, 5);
    });

    test('shuffle preserves all elements', () {
      final original = [1, 2, 3, 4, 5];
      final result = utils.shuffle(original);
      expect(result..sort(), original..sort());
    });

    test('shuffle does not modify the original list', () {
      final original = [1, 2, 3];
      final copy = List.from(original);
      utils.shuffle(original);
      expect(original, copy);
    });

    test('shuffle of empty list returns empty list', () {
      expect(utils.shuffle([]), isEmpty);
    });

    test('shuffle of single element returns same list', () {
      final result = utils.shuffle([42]);
      expect(result, [42]);
    });
  });

  // ─────────────────────────────────────────────────
  // getRandomInt
  // ─────────────────────────────────────────────────

  group('DataUtils.getRandomInt', () {
    test('result is >= min', () {
      for (int i = 0; i < 20; i++) {
        expect(utils.getRandomInt(5, 10), greaterThanOrEqualTo(5));
      }
    });

    test('result is < max', () {
      for (int i = 0; i < 20; i++) {
        expect(utils.getRandomInt(5, 10), lessThan(10));
      }
    });

    test('result with min=0 is non-negative', () {
      for (int i = 0; i < 10; i++) {
        expect(utils.getRandomInt(0, 3), greaterThanOrEqualTo(0));
      }
    });
  });
}
