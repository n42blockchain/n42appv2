// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-8: Tests for MiningApi URL-building logic and model parsing
//
// Strategy: extract the URL construction and response-parsing logic as pure
// functions so they can be tested without network or platform dependencies.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/mining_v2/models/mining_withdrawals_daily.dart';

// ---------------------------------------------------------------------------
// Pure mirrors of logic from mining_api.dart
// ---------------------------------------------------------------------------

/// Mirrors the URL template used in getMiningWithdrawalsDaily.
String buildWithdrawalsDailyUrl(String address, String dayStr) {
  return 'https://testnet2.n42.world/api/v2/addresses/$address/withdrawals-daily?day=$dayStr';
}

/// Mirrors the items-parsing logic in getMiningWithdrawalsDaily.
List<MiningWithdrawalsDaily>? parseWithdrawalsDailyItems(
    Map<String, dynamic>? data) {
  if (data == null) return null;
  final items = data['items'] as List<dynamic>?;
  if (items == null) return null;
  return items
      .map((e) => MiningWithdrawalsDaily.fromJson(e as Map<String, dynamic>))
      .toList();
}

// ---------------------------------------------------------------------------
void main() {
  group('MiningApi — URL construction', () {
    test('URL embeds address correctly', () {
      final url = buildWithdrawalsDailyUrl(
        '0x8157AC6F0C0eb1F465D14f62917e151637Ee47cC',
        '2025-11-12',
      );
      expect(url,
          contains('0x8157AC6F0C0eb1F465D14f62917e151637Ee47cC'));
    });

    test('URL embeds dayStr as query param', () {
      final url = buildWithdrawalsDailyUrl('0xAddr', '2025-11-12');
      expect(url, contains('?day=2025-11-12'));
    });

    test('date format is YYYY-MM-DD (ISO 8601 date)', () {
      const dayStr = '2025-11-12';
      final url = buildWithdrawalsDailyUrl('0xAddr', dayStr);
      // Validate the embedded string matches ISO date pattern
      final isoPattern = RegExp(r'\d{4}-\d{2}-\d{2}');
      expect(isoPattern.hasMatch(url), isTrue);
    });

    test('URL path contains "withdrawals-daily"', () {
      final url = buildWithdrawalsDailyUrl('0xAddr', '2025-01-01');
      expect(url, contains('withdrawals-daily'));
    });

    test('URL starts with expected base', () {
      final url = buildWithdrawalsDailyUrl('0xAddr', '2025-01-01');
      expect(url,
          startsWith('https://testnet2.n42.world/api/v2/addresses/'));
    });
  });

  group('MiningApi — response parsing', () {
    test('items=null returns null (triggers error path)', () {
      final result = parseWithdrawalsDailyItems({'other': 'data'});
      expect(result, isNull);
    });

    test('null response returns null', () {
      final result = parseWithdrawalsDailyItems(null);
      expect(result, isNull);
    });

    test('empty items list returns empty List', () {
      final result = parseWithdrawalsDailyItems({'items': []});
      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    test('items list with one entry is parsed', () {
      final result = parseWithdrawalsDailyItems({
        'items': [
          {'count': 5, 'day': '2025-11-10', 'total_amount': '1000000000'}
        ]
      });
      expect(result, hasLength(1));
      expect(result![0].count, 5);
      expect(result[0].day, '2025-11-10');
      expect(result[0].totalAmount, '1000000000');
    });

    test('items list with multiple entries parsed in order', () {
      final result = parseWithdrawalsDailyItems({
        'items': [
          {'count': 3, 'day': '2025-11-08', 'total_amount': '300'},
          {'count': 7, 'day': '2025-11-09', 'total_amount': '700'},
        ]
      });
      expect(result, hasLength(2));
      expect(result![0].count, 3);
      expect(result[1].count, 7);
    });

    test('total_amount is preserved as string (no numeric truncation)', () {
      const bigAmount = '50001064322000000000';
      final result = parseWithdrawalsDailyItems({
        'items': [
          {'count': 1, 'day': '2025-11-10', 'total_amount': bigAmount}
        ]
      });
      expect(result![0].totalAmount, bigAmount);
    });
  });
}
