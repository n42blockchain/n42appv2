import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_home_page.dart';
import 'package:n42_wallet/features/wallet/services/ens_registration_service.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    EnsRegistrationServiceProvider.reset();
  });

  tearDown(EnsRegistrationServiceProvider.reset);

  testWidgets('unsupported wallet sees empty state and blocked ENS actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(const EnsHomePage(walletAddress: 'not-an-evm-address')),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(S.current.g_key_ens_no_domains),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(S.current.g_key_ens_no_domains), findsOneWidget);
    expect(
      find.text(S.current.g_key_bridge_chain_not_supported),
      findsOneWidget,
    );

    await tester.tap(find.text(S.current.g_key_ens_renew));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text(S.current.g_key_bridge_chain_not_supported),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'owned-name load error renders retry state without network access',
    (tester) async {
      const walletAddress = '0x1111111111111111111111111111111111111111';
      await HttpOverrides.runZoned(
        () async {
          await tester.pumpWidget(
            wrapForTest(const EnsHomePage(walletAddress: walletAddress)),
          );
          await tester.pumpAndSettle();
        },
        createHttpClient: (_) =>
            throw StateError('Live network disabled in test'),
      );

      await tester.scrollUntilVisible(
        find.text(S.current.g_key_5),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text(S.current.g_swap_key_6));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_key_5), findsOneWidget);
      expect(find.text(S.current.g_swap_key_6), findsOneWidget);

      await HttpOverrides.runZoned(
        () async {
          await tester.tap(find.text(S.current.g_swap_key_6));
          await tester.pumpAndSettle();
        },
        createHttpClient: (_) =>
            throw StateError('Live network disabled in test'),
      );

      expect(find.text(S.current.g_key_5), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
