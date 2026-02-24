// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-7: Tests for MiningWithdrawalsDaily data model
//
// Pure Dart model — no platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/models/mining_withdrawals_daily.dart';

void main() {
  group('MiningWithdrawalsDaily', () {
    group('fromJson — complete payload', () {
      test('count field is parsed', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 10,
          'day': '2025-11-10',
          'total_amount': '50001064322000000000',
        });
        expect(model.count, 10);
      });

      test('day field is parsed', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 5,
          'day': '2025-11-10',
          'total_amount': '100000000',
        });
        expect(model.day, '2025-11-10');
      });

      test('total_amount field is parsed', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 1,
          'day': '2025-11-10',
          'total_amount': '50001064322000000000',
        });
        expect(model.totalAmount, '50001064322000000000');
      });

      test('total_amount is stored as string (no numeric conversion)', () {
        const raw = '999999999999999999';
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 1,
          'day': '2025-01-01',
          'total_amount': raw,
        });
        expect(model.totalAmount, raw);
        expect(model.totalAmount, isA<String>());
      });
    });

    group('fromJson — missing / null fields', () {
      test('missing count is null', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'day': '2025-11-10',
          'total_amount': '100',
        });
        expect(model.count, isNull);
      });

      test('missing day is null', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 3,
          'total_amount': '100',
        });
        expect(model.day, isNull);
      });

      test('missing total_amount is null', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 3,
          'day': '2025-11-10',
        });
        expect(model.totalAmount, isNull);
      });

      test('empty map produces all-null model', () {
        final model = MiningWithdrawalsDaily.fromJson({});
        expect(model.count, isNull);
        expect(model.day, isNull);
        expect(model.totalAmount, isNull);
      });
    });

    group('toJson', () {
      test('round-trip: fromJson then toJson is consistent', () {
        final original = {
          'count': 7,
          'day': '2025-12-01',
          'total_amount': '12345678900000000000',
        };
        final model = MiningWithdrawalsDaily.fromJson(original);
        final json = model.toJson();

        expect(json['count'], 7);
        expect(json['day'], '2025-12-01');
        expect(json['total_amount'], '12345678900000000000');
      });

      test('toJson uses key "total_amount" not "totalAmount"', () {
        final model = MiningWithdrawalsDaily.fromJson({
          'count': 1,
          'day': '2025-01-01',
          'total_amount': '42',
        });
        final json = model.toJson();

        expect(json.containsKey('total_amount'), isTrue);
        expect(json.containsKey('totalAmount'), isFalse);
      });

      test('null fields survive round-trip as null', () {
        final model = MiningWithdrawalsDaily.fromJson({});
        final json = model.toJson();

        expect(json['count'], isNull);
        expect(json['day'], isNull);
        expect(json['total_amount'], isNull);
      });
    });

    group('constructor', () {
      test('positional constructor sets all fields', () {
        final model = MiningWithdrawalsDaily(5, '2025-11-15', '100000');
        expect(model.count, 5);
        expect(model.day, '2025-11-15');
        expect(model.totalAmount, '100000');
      });
    });
  });
}
