import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/enums/load.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_page.dart';
import 'package:n42_wallet/features/wallet_connect/pages/wallet_connect_sheet.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/loading_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _Provider extends WalletConnectProvider {
  final transitions = <(WalletConnectState, dynamic)>[];
  final cancelled = <WalletConnectState>[];
  int messagesSigned = 0;
  int transactionsSigned = 0;
  int disconnects = 0;
  int cleanups = 0;

  @override
  Future<void> viewStateDeal(WalletConnectState state, {dynamic params}) async {
    transitions.add((state, params));
    walletConnectState = state;
    refresh();
  }

  @override
  Future<void> messageSignTap() async => messagesSigned++;
  @override
  Future<void> transactionSignTap() async => transactionsSigned++;
  @override
  Future<void> cancelTap(WalletConnectState state) async =>
      cancelled.add(state);
  @override
  Future<void> disconnectOnTap() async => disconnects++;
  @override
  void cleanDataLogout() => cleanups++;
}

void main() {
  const uri = 'wc:fixture@2?relay-protocol=irn&symKey=fixture';

  Future<void> mount(
    WidgetTester tester,
    _Provider provider, {
    String link = '',
    bool sheet = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              if (sheet) {
                WalletConnectSheet.show(context, link);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WalletConnectPage(link),
                  ),
                );
              }
            },
            child: const Text('Open connection'),
          ),
        ),
        overrides: [wcpBridgeProvider.overrideWith((ref) => provider)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open connection'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  }

  testWidgets('empty entry resets stale loading and exposes scan and paste', (
    tester,
  ) async {
    final provider = _Provider();
    await mount(tester, provider);
    expect(provider.transitions, [(WalletConnectState.disconnect, null)]);
    expect(find.text(S.current.g_wc_dapp_disconnected), findsOneWidget);
    expect(find.text(S.current.g_key_4), findsOneWidget);
    expect(find.byTooltip('Paste connection link'), findsOneWidget);
  });

  testWidgets(
    'deep link is paired after first frame and page-open flag clears on exit',
    (tester) async {
      final provider = _Provider();
      await mount(tester, provider, link: uri);
      expect(provider.transitions, [(WalletConnectState.loading, uri)]);
      expect(provider.pageOpen, isTrue);
      expect(find.byType(LoadingPage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(provider.pageOpen, isFalse);
      expect(find.text('Open connection'), findsOneWidget);
    },
  );

  testWidgets(
    'paste trims a valid connection link and forwards it to pairing',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') return {'text': '  $uri  '};
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final provider = _Provider()
        ..walletConnectState = WalletConnectState.disconnect;
      await mount(tester, provider);
      await tester.tap(find.byTooltip('Paste connection link'));
      await tester.pump();
      expect(provider.transitions, [(WalletConnectState.loading, uri)]);
    },
  );

  testWidgets('connection error remains visible until close cleans context', (
    tester,
  ) async {
    final provider = _Provider()
      ..walletConnectState = WalletConnectState.error
      ..errorMessage = 'Relay unavailable; retry later';
    await mount(tester, provider);
    expect(find.text('Relay unavailable; retry later'), findsOneWidget);
    expect(provider.cleanups, 0);
    await tester.tap(find.text(S.current.g_key_nft_220));
    await tester.pumpAndSettle();
    expect(provider.cleanups, 1);
    expect(find.byType(WalletConnectPage), findsNothing);
  });

  testWidgets(
    'connected state exposes disconnect without starting a new pairing',
    (tester) async {
      final provider = _Provider()
        ..walletConnectState = WalletConnectState.connect;
      await mount(tester, provider);
      expect(provider.transitions, isEmpty);
      await tester.tap(find.text(S.current.g_connect_key2));
      expect(provider.disconnects, 1);
      expect(provider.messagesSigned, 0);
      expect(provider.transactionsSigned, 0);
    },
  );

  for (final isTransaction in [true, false]) {
    final ready = isTransaction
        ? WalletConnectState.transactionOK
        : WalletConnectState.messageSignOK;
    final busy = isTransaction
        ? WalletConnectState.transaction
        : WalletConnectState.messageSign;
    for (final confirm in [true, false]) {
      testWidgets(
        '${ready.name} routes ${confirm ? 'confirmation' : 'cancellation'} to correct action',
        (tester) async {
          final provider = _Provider()
            ..walletConnectState = ready
            ..actionDataMap = {
              'network': 'Sepolia',
              'from': '0x1111',
              'to': '0x2222',
              'data': '0x1234',
            };
          await mount(tester, provider);
          expect(find.text('Sepolia'), findsOneWidget);
          expect(find.text('0x1111'), findsOneWidget);
          expect(find.text('0x1234'), findsOneWidget);
          if (isTransaction) expect(find.text('0x2222'), findsOneWidget);
          await tester.tap(
            find.text(confirm ? S.current.g_key_78 : S.current.g_connect_key3),
          );
          await tester.pump();
          expect(provider.transactionsSigned, confirm && isTransaction ? 1 : 0);
          expect(provider.messagesSigned, confirm && !isTransaction ? 1 : 0);
          expect(provider.cancelled, confirm ? isEmpty : [busy]);
        },
      );
    }
    testWidgets(
      '${busy.name} keeps request details and removes signing controls',
      (tester) async {
        final provider = _Provider()
          ..walletConnectState = busy
          ..actionDataMap = {
            'network': 'Sepolia',
            'from': '0x1111',
            'to': '0x2222',
            'data': '0x1234',
          };
        await mount(tester, provider);
        expect(find.text('Sepolia'), findsOneWidget);
        expect(find.text(S.current.g_key_78), findsNothing);
        expect(find.text(S.current.g_connect_key3), findsNothing);
        expect(provider.messagesSigned + provider.transactionsSigned, 0);
      },
    );
  }

  testWidgets('loading overlay intercepts the underlying disconnect control', (
    tester,
  ) async {
    final provider = _Provider()
      ..walletConnectState = WalletConnectState.connect
      ..load = Load.loading;
    await mount(tester, provider);
    expect(find.byType(LoadingPage), findsOneWidget);
    expect(find.text(S.current.g_connect_key2).hitTestable(), findsNothing);
    expect(provider.disconnects, 0);
    provider.load = Load.finish;
    provider.refresh();
    await tester.pump();
    await tester.tap(find.text(S.current.g_connect_key2));
    expect(provider.disconnects, 1);
  });

  testWidgets(
    'sheet loading overlay blocks signing until the operation finishes',
    (tester) async {
      final provider = _Provider()
        ..walletConnectState = WalletConnectState.messageSignOK
        ..load = Load.loading;
      await mount(tester, provider, sheet: true);
      expect(find.byType(WalletConnectSheet), findsOneWidget);
      expect(find.text(S.current.g_key_78).hitTestable(), findsNothing);
      expect(provider.messagesSigned, 0);
      provider.load = Load.finish;
      provider.refresh();
      await tester.pump();
      await tester.tap(find.text(S.current.g_key_78));
      expect(provider.messagesSigned, 1);
    },
  );
}
