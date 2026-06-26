// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
//
// 资金路径金额转换的精度回归：替换 `BigInt.from((v * 1e18).round())`
// 浮点链路后，所有 double 可表达的数位必须无损进入链上最小单位。

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/decimal_amount.dart';

void main() {
  group('decimalStringToBigInt', () {
    test('integer and plain decimal', () {
      expect(decimalStringToBigInt('1', 18), BigInt.parse('1000000000000000000'));
      expect(decimalStringToBigInt('0.5', 18), BigInt.parse('500000000000000000'));
      expect(decimalStringToBigInt('123.456', 6), BigInt.from(123456000));
    });

    test('full 18-decimal precision survives (old code lost this)', () {
      // 旧实现 BigInt.from((v*1e18).round()) 在 v>9 时已超出 double
      // 53 位尾数可精确表示的范围。字符串路径必须无损。
      expect(
        decimalStringToBigInt('123456789.123456789012345678', 18),
        BigInt.parse('123456789123456789012345678'),
      );
    });

    test('scientific notation (double.toString of small values)', () {
      // double 0.0000001.toString() == '1e-7'
      expect(decimalStringToBigInt('1e-7', 18), BigInt.parse('100000000000'));
      expect(decimalStringToBigInt('2.5E+3', 6), BigInt.from(2500000000));
      expect(decimalStringToBigInt('1.5e2', 0), BigInt.from(150));
    });

    test('excess fractional digits truncate toward zero (never overpay)', () {
      expect(decimalStringToBigInt('0.1234567', 6), BigInt.from(123456));
      expect(decimalStringToBigInt('1e-7', 6), BigInt.zero);
    });

    test('signs and zero', () {
      expect(decimalStringToBigInt('-0.5', 6), BigInt.from(-500000));
      expect(decimalStringToBigInt('+2', 6), BigInt.from(2000000));
      expect(decimalStringToBigInt('0', 18), BigInt.zero);
      expect(decimalStringToBigInt('0.0', 18), BigInt.zero);
    });

    test('USDC-style decimals=6', () {
      expect(decimalStringToBigInt('0.123456', 6), BigInt.from(123456));
      expect(decimalStringToBigInt('1000000', 6), BigInt.parse('1000000000000'));
    });

    test('rejects malformed input', () {
      expect(() => decimalStringToBigInt('', 18), throwsFormatException);
      expect(() => decimalStringToBigInt('abc', 18), throwsFormatException);
      expect(() => decimalStringToBigInt('1.2.3', 18), throwsFormatException);
      expect(() => decimalStringToBigInt('1', -1), throwsFormatException);
    });
  });

  group('doubleAmountToBigInt', () {
    test('matches the double shortest representation exactly', () {
      expect(doubleAmountToBigInt(0.1, 18), BigInt.parse('100000000000000000'));
      expect(doubleAmountToBigInt(1.5, 6), BigInt.from(1500000));
      // 0.0000001 stringifies as 1e-7
      expect(doubleAmountToBigInt(0.0000001, 18), BigInt.parse('100000000000'));
    });

    test('large value precision: old float path drifted, string path exact',
        () {
      // 12345.678901234567 是 double 可精确往返的值；
      // 旧实现 (v*1e18).round() 在这个量级误差可达数百 wei。
      expect(
        doubleAmountToBigInt(12345.678901234567, 18),
        BigInt.parse('12345678901234567000000'),
      );
    });

    test('rejects NaN and infinity', () {
      expect(() => doubleAmountToBigInt(double.nan, 18), throwsFormatException);
      expect(
        () => doubleAmountToBigInt(double.infinity, 18),
        throwsFormatException,
      );
    });
  });
}
