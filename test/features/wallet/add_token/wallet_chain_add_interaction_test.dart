import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_chain_add.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WalletChainAdd(),
                    ),
                  );
                },
                child: const Text('Open add network'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open add network'));
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextField).at(index);
  String value(WidgetTester tester, int index) =>
      tester.widget<TextField>(field(index)).controller!.text;

  Future<void> enter(WidgetTester tester, int index, String text) async {
    await tester.ensureVisible(field(index));
    await tester.enterText(field(index), text);
    await tester.pump();
  }

  Future<void> draft(
    WidgetTester tester, {
    String symbol = 'TST',
    String chainId = '987654',
    String decimals = '18',
    String rpc = 'https://rpc.example.com',
    String explorer = '',
  }) async {
    await enter(tester, 0, 'Synthetic network');
    await enter(tester, 1, symbol);
    // Fill chain ID before RPC: focus loss must not start auto-discovery.
    await enter(tester, 2, chainId);
    await enter(tester, 3, decimals);
    await enter(tester, 4, rpc);
    await enter(tester, 5, explorer);
  }

  Future<void> submit(WidgetTester tester) async {
    tester.testTextInput.hide();
    await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_159));
    await tester.pumpAndSettle();
    expect(find.byType(WalletChainAdd), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  testWidgets('blank network is rejected without leaving the form', (
    tester,
  ) async {
    await open(tester);
    await submit(tester);
    // Hint and validation share text; the visible validation adds a second copy.
    expect(find.text(S.current.g_token_m_key_1(30)), findsNWidgets(2));
    expect(value(tester, 0), isEmpty);
  });

  for (final invalidId in ['0', '-1', 'abc']) {
    testWidgets('invalid chain ID $invalidId preserves draft', (tester) async {
      await open(tester);
      await draft(tester, chainId: invalidId);
      await submit(tester);
      expect(find.text(S.current.g_token_m_key_21), findsOneWidget);
      expect(value(tester, 2), invalidId);
      expect(value(tester, 0), 'Synthetic network');
    });
  }

  testWidgets('decimals above 18 are rejected', (tester) async {
    await open(tester);
    await draft(tester, decimals: '19');
    await submit(tester);
    expect(find.text(S.current.g_token_m_key_2), findsNWidgets(2));
    expect(value(tester, 3), '19');
  });

  testWidgets('plain HTTP RPC is rejected before probing', (tester) async {
    await open(tester);
    await draft(tester, rpc: 'http://rpc.example.com');
    await submit(tester);
    expect(find.text(S.current.g_token_m_key_21), findsOneWidget);
    expect(value(tester, 4), 'http://rpc.example.com');
  });

  testWidgets('plain HTTP explorer is rejected without clearing RPC', (
    tester,
  ) async {
    await open(tester);
    await draft(tester, explorer: 'http://explorer.example.com');
    await submit(tester);
    expect(find.text(S.current.g_token_m_key_21), findsOneWidget);
    expect(value(tester, 4), 'https://rpc.example.com');
  });

  testWidgets('renaming Ethereum cannot bypass existing chain ID guard', (
    tester,
  ) async {
    await open(tester);
    await draft(tester, chainId: '1');
    await submit(tester);
    expect(find.text(S.current.g_token_m_key_chainid_conflict), findsOneWidget);
    expect(value(tester, 1), 'TST');
    // Retry stays a refusal; no duplicate route or request is created.
    await submit(tester);
    expect(find.text(S.current.g_token_m_key_chainid_conflict), findsOneWidget);
  });

  testWidgets('preset replaces invalid draft and clears chain ID error', (
    tester,
  ) async {
    await open(tester);
    await draft(tester, chainId: '0');
    await submit(tester);
    await tester.ensureVisible(find.widgetWithText(ActionChip, 'CELO'));
    await tester.tap(find.widgetWithText(ActionChip, 'CELO'));
    await tester.pumpAndSettle();
    expect(List.generate(6, (i) => value(tester, i)), [
      'CELO',
      'CELO',
      '42220',
      '18',
      'https://forno.celo.org',
      'https://celoscan.io/',
    ]);
    expect(find.text(S.current.g_token_m_key_21), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Open add network'), findsOneWidget);
  });

  testWidgets('existing symbol confirmation can be cancelled and retried', (
    tester,
  ) async {
    await open(tester);
    await draft(tester, symbol: 'ETH', chainId: '1');
    for (var attempt = 0; attempt < 2; attempt++) {
      await submit(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text(S.current.g_key_79));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(WalletChainAdd), findsOneWidget);
      expect(value(tester, 1), 'ETH');
    }
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Open add network'), findsOneWidget);
  });
}
