// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Tests that the 11 new market i18n keys exist and are non-empty.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Market i18n keys', () {
    late S s;

    setUp(() async {
      s = await S.load(const Locale('en'));
    });

    test('g_market_high_24h is non-empty', () {
      expect(s.g_market_high_24h.isNotEmpty, true);
      expect(s.g_market_high_24h, 'High 24H');
    });

    test('g_market_low_24h is non-empty', () {
      expect(s.g_market_low_24h.isNotEmpty, true);
      expect(s.g_market_low_24h, 'Low 24H');
    });

    test('g_market_fdv is non-empty', () {
      expect(s.g_market_fdv.isNotEmpty, true);
    });

    test('g_market_rank is non-empty', () {
      expect(s.g_market_rank.isNotEmpty, true);
      expect(s.g_market_rank, 'Rank');
    });

    test('g_market_ath is non-empty', () {
      expect(s.g_market_ath.isNotEmpty, true);
      expect(s.g_market_ath, 'ATH');
    });

    test('g_market_atl is non-empty', () {
      expect(s.g_market_atl.isNotEmpty, true);
      expect(s.g_market_atl, 'ATL');
    });

    test('g_market_liquidity_score is non-empty', () {
      expect(s.g_market_liquidity_score.isNotEmpty, true);
    });

    test('g_market_7d_change is non-empty', () {
      expect(s.g_market_7d_change.isNotEmpty, true);
    });

    test('g_market_30d_change is non-empty', () {
      expect(s.g_market_30d_change.isNotEmpty, true);
    });

    test('g_market_depth is non-empty', () {
      expect(s.g_market_depth.isNotEmpty, true);
    });

    test('g_market_no_chart is non-empty', () {
      expect(s.g_market_no_chart.isNotEmpty, true);
      expect(s.g_market_no_chart, 'No chart data');
    });
  });
}
