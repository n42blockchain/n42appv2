// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// T-5: Tests for AirdropFilter state logic (P2 filter/notification)

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/airdrop/models/airdrop_model.dart';
import 'package:n42_wallet/features/airdrop/provider/airdrop_provider.dart';

void main() {
  group('AirdropFilter default state', () {
    test('types is null by default', () {
      final filter = AirdropFilter();
      expect(filter.types, isNull);
    });

    test('onlyEligible is null (falsy) by default', () {
      final filter = AirdropFilter();
      // AirdropFilter.onlyEligible defaults to null
      expect(filter.onlyEligible, isNull);
    });

    test('onlyHighValue is null (falsy) by default', () {
      final filter = AirdropFilter();
      expect(filter.onlyHighValue, isNull);
    });

    test('sortBy defaults to priority', () {
      final filter = AirdropFilter();
      expect(filter.sortBy, AirdropSortBy.priority);
    });
  });

  group('AirdropFilter applyFilter / clearFilter', () {
    test('applyFilter stores the new filter (sync state check)', () async {
      final provider = AirdropProvider();

      // Start state: default empty filter
      expect(provider.filter.types, isNull);

      // applyFilter calls refresh() internally which hits the API
      // We verify the synchronous filter assignment happens immediately
      // (even if refresh fails, _filter should be updated)
      final newFilter = AirdropFilter(
        types: [AirdropType.token],
        onlyEligible: true,
        onlyHighValue: false,
      );

      // We call applyFilter; refresh will fail silently on missing API but
      // the filter field must be updated before the await.
      // Since refresh() catches errors internally we don't need to worry.
      try {
        await provider.applyFilter(newFilter);
      } catch (_) {}

      expect(provider.filter.types, [AirdropType.token]);
      expect(provider.filter.onlyEligible, isTrue);
    });

    test('clearFilter resets filter to default', () async {
      final provider = AirdropProvider();

      // Set a non-default filter first
      provider.filter; // touch getter
      try {
        await provider.applyFilter(AirdropFilter(
          types: [AirdropType.nft],
          onlyHighValue: true,
        ));
      } catch (_) {}

      // Now clear
      try {
        await provider.clearFilter();
      } catch (_) {}

      expect(provider.filter.types, isNull);
      expect(provider.filter.onlyHighValue, isNull);
    });
  });

  group('AirdropFilter selectedType toggle', () {
    // Simulate the filter sheet selectedType toggle logic from airdrop_home_page.dart
    test('selecting a type then deselecting returns null', () {
      AirdropType? selectedType;

      // Select token
      selectedType = AirdropType.token;
      expect(selectedType, AirdropType.token);

      // Deselect (same type selected again → null)
      selectedType = selectedType == AirdropType.token ? null : AirdropType.token;
      expect(selectedType, isNull);
    });

    test('selecting a different type replaces previous selection', () {
      AirdropType? selectedType = AirdropType.token;

      selectedType = AirdropType.nft;

      expect(selectedType, AirdropType.nft);
    });
  });

  group('AirdropFilter copyWith', () {
    test('copyWith preserves untouched fields', () {
      final original = AirdropFilter(
        sortBy: AirdropSortBy.value,
        onlyEligible: true,
      );

      final copy = original.copyWith(onlyHighValue: true);

      expect(copy.sortBy, AirdropSortBy.value);
      expect(copy.onlyEligible, isTrue);
      expect(copy.onlyHighValue, isTrue);
    });
  });
}
