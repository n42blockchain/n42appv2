import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/provider/legacy_wallet_adapter.dart';
import 'package:n42_wallet/features/staking/models/staking_models.dart';
import 'package:n42_wallet/features/staking/pages/stake_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

class _Wallet extends Fake implements LegacyWalletActionProviderAdapter {
  @override
  List<CoinModel> coinModels = [];
}

class _OfflineHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('network disabled for stake page test');
  }
}

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousOverrides = HttpOverrides.current;

  setUpAll(() => globalWapAdapter = _Wallet());
  setUp(() => HttpOverrides.global = _OfflineHttpOverrides());
  tearDown(() => HttpOverrides.global = previousOverrides);

  Future<void> openUnstakeTab(
    WidgetTester tester,
    StakingProtocol protocol, {
    String? address,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(StakePage(protocol: protocol, userAddress: address)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_key_stake_unstake).first);
    await tester.pumpAndSettle();
  }

  testWidgets('liquid protocol explains unstaking and receive token', (
    tester,
  ) async {
    await openUnstakeTab(tester, StakingProtocols.ethLido);

    expect(
      find.text(S.current.g_key_stake_liquid_staking_label),
      findsNWidgets(2),
    );
    final liquidDescription = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('stETH') &&
          widget.text.toPlainText().contains(
            S.current.g_key_stake_liquid_unstake_desc,
          ),
    );
    expect(liquidDescription, findsOneWidget);
    expect(find.text(S.current.g_key_stake_go_to_swap), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('liquid protocol hides the swap entry on iOS', (tester) async {
    await tester.runOnIOS(() async {
      await openUnstakeTab(tester, StakingProtocols.ethLido);

      expect(
        find.text(S.current.g_key_stake_liquid_staking_label),
        findsNWidgets(2),
      );
      expect(find.text(S.current.g_key_stake_go_to_swap), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('non-liquid protocol without an address shows no-wallet hint', (
    tester,
  ) async {
    await openUnstakeTab(tester, StakingProtocols.solNative);

    expect(
      find.text(S.current.g_key_stake_unbonding_warning('2')),
      findsOneWidget,
    );
    expect(find.text(S.current.g_key_stake_no_wallet), findsOneWidget);
    expect(find.text(S.current.g_key_stake_select_position), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'non-liquid protocol with no active positions shows empty state',
    (tester) async {
      await openUnstakeTab(
        tester,
        StakingProtocols.atomNative,
        address: 'cosmos1testaddress',
      );

      expect(
        find.text(S.current.g_key_stake_unbonding_warning('21')),
        findsOneWidget,
      );
      expect(
        find.text(S.current.g_key_stake_no_active_positions),
        findsOneWidget,
      );
      expect(
        find.text(S.current.g_key_stake_select_position),
        findsNWidgets(2),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
