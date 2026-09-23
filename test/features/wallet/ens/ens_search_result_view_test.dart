// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/services/ens_models.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_search_result_view.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets(
    'initial state suggestions start a search with the selected name',
    (tester) async {
      String? selected;
      await _pumpView(
        tester,
        searchQuery: '',
        availabilityResult: null,
        onSuggestionTap: (name) => selected = name,
      );

      expect(find.text(S.current.g_key_ens_search_prompt), findsOneWidget);
      expect(find.text('n42user.eth'), findsOneWidget);
      await tester.tap(find.text('n42user.eth'));

      expect(selected, 'n42user');
    },
  );

  testWidgets('search state communicates that availability is being checked', (
    tester,
  ) async {
    await _pumpView(
      tester,
      searchQuery: 'alice',
      isSearching: true,
      availabilityResult: null,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(S.current.g_key_ens_checking), findsOneWidget);
  });

  testWidgets('available name lets user select a term and start registration', (
    tester,
  ) async {
    int? selectedYears;
    var registerTapped = false;
    await _pumpView(
      tester,
      searchQuery: 'alice',
      availabilityResult: EnsAvailabilityResult.available('alice'),
      priceInfo: EnsPrice(
        basePrice: 0.01,
        annualPrice: 0.01,
        totalPrice: 0.02,
        years: 2,
        nameLength: 5,
        updatedAt: DateTime(2026, 9, 23),
      ),
      onYearsChanged: (years) => selectedYears = years,
      onRegisterTap: () => registerTapped = true,
    );

    expect(find.text('alice.eth'), findsOneWidget);
    expect(find.text(S.current.g_key_ens_available), findsOneWidget);
    expect(find.text('0.0200 ETH'), findsNWidgets(2));
    await tester.tap(find.text('5 ${S.current.g_key_ens_years}'));
    await tester.tap(find.text(S.current.g_key_ens_register_now));

    expect(selectedYears, 5);
    expect(registerTapped, isTrue);
  });

  testWidgets('unavailable name displays shortened owner and expiry date', (
    tester,
  ) async {
    await _pumpView(
      tester,
      searchQuery: 'taken',
      availabilityResult: EnsAvailabilityResult.unavailable(
        'taken',
        ownerAddress: '0x1234567890abcdef',
        expiresAt: DateTime(2030, 5, 6),
      ),
    );

    expect(find.text(S.current.g_key_ens_unavailable), findsOneWidget);
    expect(find.text('0x1234...cdef'), findsOneWidget);
    expect(find.text('2030-05-06'), findsOneWidget);
    expect(find.text(S.current.g_key_ens_try_another), findsOneWidget);
  });

  testWidgets('ENS errors do not expose transport implementation details', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        EnsSearchResultView(
          searchQuery: 'abc',
          isSearching: false,
          isLoadingPrice: false,
          availabilityResult: const EnsAvailabilityResult(
            name: 'abc',
            isAvailable: false,
            error: 'Dio Error: connection failed',
          ),
          priceInfo: null,
          selectedYears: 1,
          onYearsChanged: (_) {},
          onSuggestionTap: (_) {},
          onRetry: () {},
          onRegisterTap: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request error'), findsOneWidget);
    expect(find.textContaining('Dio Error'), findsNothing);
  });
}

Future<void> _pumpView(
  WidgetTester tester, {
  required String searchQuery,
  required EnsAvailabilityResult? availabilityResult,
  bool isSearching = false,
  bool isLoadingPrice = false,
  EnsPrice? priceInfo,
  ValueChanged<int>? onYearsChanged,
  ValueChanged<String>? onSuggestionTap,
  VoidCallback? onRetry,
  VoidCallback? onRegisterTap,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    wrapForTest(
      Scaffold(
        body: EnsSearchResultView(
          searchQuery: searchQuery,
          isSearching: isSearching,
          isLoadingPrice: isLoadingPrice,
          availabilityResult: availabilityResult,
          priceInfo: priceInfo,
          selectedYears: 2,
          onYearsChanged: onYearsChanged ?? (_) {},
          onSuggestionTap: onSuggestionTap ?? (_) {},
          onRetry: onRetry ?? () {},
          onRegisterTap: onRegisterTap,
        ),
      ),
    ),
  );
  if (isSearching || isLoadingPrice) {
    await tester.pump();
  } else {
    await tester.pumpAndSettle();
  }
}
