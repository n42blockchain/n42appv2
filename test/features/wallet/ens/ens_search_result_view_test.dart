// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_search_result_view.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
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
