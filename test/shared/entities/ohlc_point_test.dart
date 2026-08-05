import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/shared/domain/entities/ohlc_point.dart';

void main() {
  group('OhlcPoint', () {
    test('isBullish：收盘价不低于开盘价为阳线', () {
      const bullish = OhlcPoint(open: 10, high: 12, low: 9, close: 11);
      const flat = OhlcPoint(open: 10, high: 12, low: 9, close: 10);
      const bearish = OhlcPoint(open: 11, high: 12, low: 9, close: 10);
      expect(bullish.isBullish, isTrue);
      expect(flat.isBullish, isTrue);
      expect(bearish.isBullish, isFalse);
    });

    test('isValid：满足 OHLC 约束', () {
      const valid = OhlcPoint(open: 10, high: 12, low: 9, close: 11);
      expect(valid.isValid, isTrue);
    });

    test('isValid：high 低于 open/close 时无效', () {
      const badHigh = OhlcPoint(open: 10, high: 9.5, low: 9, close: 11);
      expect(badHigh.isValid, isFalse);
    });

    test('isValid：low 高于 open/close 时无效', () {
      const badLow = OhlcPoint(open: 10, high: 12, low: 10.5, close: 11);
      expect(badLow.isValid, isFalse);
    });

    test('isValid：非有限值无效', () {
      const nan = OhlcPoint(open: double.nan, high: 12, low: 9, close: 11);
      const inf = OhlcPoint(open: 10, high: double.infinity, low: 9, close: 11);
      expect(nan.isValid, isFalse);
      expect(inf.isValid, isFalse);
    });

    test('值相等与 hashCode 一致', () {
      const a = OhlcPoint(open: 1, high: 2, low: 0.5, close: 1.5);
      const b = OhlcPoint(open: 1, high: 2, low: 0.5, close: 1.5);
      const c = OhlcPoint(open: 1, high: 2, low: 0.5, close: 1.6);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
