// Copyright 2021-2026 N42 Inc. All rights reserved.
//
// Tests for the daily-withdrawals model used by the mining v2 beacon
// provider. The shape is a thin JSON wrapper, but it sits on the boundary
// between the beacon REST API and the in-app chart, so contract drift here
// silently corrupts the withdrawal history graph.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/models/mining_withdrawals_daily.dart';

void main() {
  group('MiningWithdrawalsDaily', () {
    group('constructor', () {
      test('stores the three slots positionally', () {
        final m = MiningWithdrawalsDaily(10, '2025-11-10', '50001064322000000000');
        expect(m.count, 10);
        expect(m.day, '2025-11-10');
        expect(m.totalAmount, '50001064322000000000');
      });

      test('accepts nulls (server fields are optional)', () {
        final m = MiningWithdrawalsDaily(null, null, null);
        expect(m.count, isNull);
        expect(m.day, isNull);
        expect(m.totalAmount, isNull);
      });
    });

    group('fromJson', () {
      test('parses the canonical shape from the beacon API', () {
        final m = MiningWithdrawalsDaily.fromJson({
          'count': 10,
          'day': '2025-11-10',
          'total_amount': '50001064322000000000',
        });
        expect(m.count, 10);
        expect(m.day, '2025-11-10');
        expect(m.totalAmount, '50001064322000000000');
      });

      test('handles missing fields by leaving them null', () {
        final m = MiningWithdrawalsDaily.fromJson(<String, dynamic>{});
        expect(m.count, isNull);
        expect(m.day, isNull);
        expect(m.totalAmount, isNull);
      });

      test('handles partial payload', () {
        final m = MiningWithdrawalsDaily.fromJson({
          'day': '2025-11-10',
        });
        expect(m.count, isNull);
        expect(m.day, '2025-11-10');
        expect(m.totalAmount, isNull);
      });

      test('preserves wei-precision string for total_amount (no truncation)', () {
        // The amount is wei (1e18 units of N); MUST NOT be coerced to int
        // or double, which would lose precision on amounts above ~9e15.
        final huge = '999999999999999999999999';
        final m = MiningWithdrawalsDaily.fromJson({
          'total_amount': huge,
        });
        expect(m.totalAmount, huge);
      });
    });

    group('toJson', () {
      test('emits the canonical beacon-API shape (snake_case)', () {
        final m = MiningWithdrawalsDaily(10, '2025-11-10', '50001064322000000000');
        expect(m.toJson(), {
          'count': 10,
          'day': '2025-11-10',
          'total_amount': '50001064322000000000',
        });
      });

      test('emits null for missing slots', () {
        final m = MiningWithdrawalsDaily(null, null, null);
        expect(m.toJson(), {
          'count': null,
          'day': null,
          'total_amount': null,
        });
      });
    });

    test('round-trip preserves the payload exactly', () {
      const payload = {
        'count': 42,
        'day': '2026-05-13',
        'total_amount': '12345678901234567890',
      };
      final m = MiningWithdrawalsDaily.fromJson(payload);
      expect(m.toJson(), payload);
    });
  });
}
