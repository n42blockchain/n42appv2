import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_search_result_view.dart';
import 'package:n42_wallet/features/wallet/widgets/ens/ens_price_card.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

EnsSearchResultView _view({
  String searchQuery = 'builder',
  bool isSearching = false,
  bool isLoadingPrice = false,
  EnsAvailabilityResult? result,
  EnsPrice? price,
  int selectedYears = 1,
  ValueChanged<int>? onYearsChanged,
  ValueChanged<String>? onSuggestionTap,
  VoidCallback? onRetry,
  VoidCallback? onRegisterTap,
}) => EnsSearchResultView(
  searchQuery: searchQuery,
  isSearching: isSearching,
  isLoadingPrice: isLoadingPrice,
  availabilityResult: result,
  priceInfo: price,
  selectedYears: selectedYears,
  onYearsChanged: onYearsChanged ?? (_) {},
  onSuggestionTap: onSuggestionTap ?? (_) {},
  onRetry: onRetry ?? () {},
  onRegisterTap: onRegisterTap,
);

void main() {
  testWidgets('short query shows suggestions and returns selected name', (
    tester,
  ) async {
    String? suggestion;
    await tester.pumpWidget(
      wrapForTest(
        _view(searchQuery: 'ab', onSuggestionTap: (name) => suggestion = name),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(EnsSearchResultView)));

    expect(find.text(l10n.g_key_ens_search_prompt), findsOneWidget);
    expect(find.text(l10n.g_key_ens_suggestions), findsOneWidget);
    await tester.tap(find.text('web3.eth'));
    expect(suggestion, 'web3');
    expect(tester.takeException(), isNull);
  });

  testWidgets('searching state shows progress and status copy', (tester) async {
    await tester.pumpWidget(
      wrapForTest(_view(isSearching: true, searchQuery: 'builder')),
    );
    await tester.pump();
    final l10n = S.of(tester.element(find.byType(EnsSearchResultView)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(l10n.g_key_ens_checking), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('available result selects term and exposes register action', (
    tester,
  ) async {
    final changedYears = <int>[];
    var registered = false;
    final price = EnsPrice(
      basePrice: 0.01,
      annualPrice: 0.005,
      totalPrice: 0.015,
      years: 1,
      nameLength: 7,
      updatedAt: DateTime(2026, 1, 1),
      usdPrice: 25,
    );
    await tester.pumpWidget(
      wrapForTest(
        _view(
          result: EnsAvailabilityResult.available('builder'),
          price: price,
          onYearsChanged: changedYears.add,
          onRegisterTap: () => registered = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(EnsSearchResultView)));

    expect(find.text('builder.eth'), findsOneWidget);
    expect(find.text(l10n.g_key_ens_available), findsOneWidget);
    expect(find.byType(EnsPriceCard), findsOneWidget);
    expect(find.text('≈ \$25.00'), findsOneWidget);
    await tester.tap(find.text('5 ${l10n.g_key_ens_years}'));
    expect(changedYears, [5]);
    await tester.ensureVisible(find.text(l10n.g_key_ens_register_now));
    await tester.tap(find.text(l10n.g_key_ens_register_now));
    expect(registered, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('price loading shows progress and disabled registration', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        _view(
          result: EnsAvailabilityResult.available('builder'),
          isLoadingPrice: true,
        ),
      ),
    );
    await tester.pump();
    final l10n = S.of(tester.element(find.byType(EnsSearchResultView)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final register = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, l10n.g_key_ens_register_now),
    );
    expect(register.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unavailable details shorten owner and format expiration', (
    tester,
  ) async {
    const owner = '0x1234567890123456789012345678901234567890';
    await tester.pumpWidget(
      wrapForTest(
        _view(
          result: EnsAvailabilityResult.unavailable(
            'builder',
            ownerAddress: owner,
            expiresAt: DateTime(2030, 4, 9),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(EnsSearchResultView)));

    expect(find.text(l10n.g_key_ens_unavailable), findsOneWidget);
    expect(find.text('0x1234...7890'), findsOneWidget);
    expect(find.text('2030-04-09'), findsOneWidget);
    expect(find.text(l10n.g_key_ens_try_another), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unavailable result without owner or expiry omits details', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(_view(result: EnsAvailabilityResult.unavailable('builder'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Owner'), findsNothing);
    expect(find.text('Expires'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
