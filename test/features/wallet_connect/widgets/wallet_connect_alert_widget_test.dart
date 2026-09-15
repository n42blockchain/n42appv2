import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/address_label_service.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/tx_risk_banner_widget.dart';
import 'package:n42_wallet/features/wallet_connect/widgets/wallet_connect_alert_widget.dart';
import 'package:n42_wallet/features/widgets/tx_simulation_card.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:reown_walletkit/reown_walletkit.dart' as wc;

import '../../../helpers/widget_test_helpers.dart';

class _SigningActions extends WalletConnectProvider {
  int transactions = 0;
  int messages = 0;
  final cancellations = <WalletConnectState>[];

  @override
  Future<void> transactionSignTap() async => transactions++;
  @override
  Future<void> messageSignTap() async => messages++;
  @override
  Future<void> cancelTap(WalletConnectState state) async =>
      cancellations.add(state);
}

void main() {
  late _SigningActions actions;
  const metadata = wc.PairingMetadata(
    name: 'Fixture DApp',
    description: '',
    url: 'https://dapp.example.test',
    icons: [],
  );
  const address = '0x1111111111111111111111111111111111111111';

  Future<void> openSheet(
    WidgetTester tester,
    Map<String, dynamic> data, {
    ThemeMode theme = ThemeMode.light,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    actions = _SigningActions();
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => SizedBox(
                height: 720,
                child: WalletConnectAlertWidget(metadata, data),
              ),
            ),
            child: const Text('Open request'),
          ),
        ),
        overrides: [wcpBridgeProvider.overrideWith((ref) => actions)],
        themeMode: theme,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open request'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Map<String, dynamic> request(bool transaction) => {
    'signType': transaction ? 'transaction' : 'message',
    'network': 'Fixture Network', 'from': address, 'to': address,
    'data': transaction ? '0x' : 'Sign in to the fixture app',
    'gas': '21000', 'value': '0x0',
    // Missing simulation chain explicitly exercises the unavailable state.
    // No RPC or contract metadata endpoint is invoked by this fixture.
  };

  testWidgets(
    'plain message shows the message and address without transaction warnings',
    (tester) async {
      await openSheet(tester, request(false));
      expect(find.text('Fixture DApp'), findsOneWidget);
      expect(find.text('Fixture Network'), findsOneWidget);
      expect(find.text(address), findsOneWidget);
      expect(find.text('Sign in to the fixture app'), findsOneWidget);
      expect(find.text('Gas'), findsNothing);
      expect(find.byType(TxRiskBannerWidget), findsNothing);
      expect(find.byType(TxSimulationCard), findsNothing);
      expect(actions.transactions, 0);
      expect(actions.messages, 0);
    },
  );

  testWidgets(
    'transaction shows gas, recipient, risk and unavailable simulation',
    (tester) async {
      await openSheet(tester, request(true));
      expect(find.text('Gas'), findsOneWidget);
      expect(find.text('21000'), findsOneWidget);
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsAtLeast(1));
      expect(find.byType(TxRiskBannerWidget), findsOneWidget);
      expect(find.byType(TxSimulationCard), findsOneWidget);
      expect(find.text(S.current.g_key_sim_unavailable), findsOneWidget);
      expect(actions.transactions, 0);
    },
  );

  for (final transaction in [false, true]) {
    for (final confirm in [false, true]) {
      testWidgets(
        '${transaction ? 'transaction' : 'message'} ${confirm ? 'confirmation' : 'rejection'} invokes only its corresponding action',
        (tester) async {
          await openSheet(tester, request(transaction));
          await tester.tap(
            find.text(confirm ? S.current.g_key_78 : S.current.g_connect_key3),
          );
          await tester.pumpAndSettle();
          expect(actions.transactions, confirm && transaction ? 1 : 0);
          expect(actions.messages, confirm && !transaction ? 1 : 0);
          expect(
            actions.cancellations,
            confirm
                ? isEmpty
                : [
                    transaction
                        ? WalletConnectState.transaction
                        : WalletConnectState.messageSign,
                  ],
          );
          expect(find.byType(WalletConnectAlertWidget), findsNothing);
          expect(find.text('Open request'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'permit message warns about unlimited approval before user confirmation',
    (tester) async {
      await openSheet(tester, {
        ...request(false),
        'data': jsonEncode({
          'primaryType': 'Permit',
          'message': {
            'spender': address,
            'value': ((BigInt.one << 256) - BigInt.one).toString(),
            'deadline': 2000000000,
          },
        }),
      });
      expect(find.byType(TxRiskBannerWidget), findsOneWidget);
      expect(find.text(S.current.g_tx_risk_danger), findsOneWidget);
      expect(find.text('Gasless Approve (Permit)'), findsOneWidget);
      expect(find.text('Unlimited ∞'), findsOneWidget);
      expect(actions.messages, 0);
    },
  );

  testWidgets('known recipient exposes its address label in dark mode', (
    tester,
  ) async {
    await AddressLabelService.init();
    await openSheet(tester, {
      ...request(true),
      'to': '0x28c6c06298d514db089934071355e5743bf21d60',
    }, theme: ThemeMode.dark);
    expect(find.text('Binance Hot Wallet 1'), findsOneWidget);
    expect(find.text('EXCHANGE'), findsOneWidget);
    expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    expect(actions.transactions, 0);
  });
}
