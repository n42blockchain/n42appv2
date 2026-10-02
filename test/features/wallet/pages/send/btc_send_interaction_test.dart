import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_btc.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_base_send.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;
}

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in BTC send test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  const trustdart = MethodChannel('trustdart');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');
  final trustdartCalls = <String>[];

  setUp(() {
    trustdartCalls.clear();
    HttpOverrides.global = _FailFastHttpOverrides();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(trustdart, (call) async {
        trustdartCalls.add(call.method);
        switch (call.method) {
          case 'validateAddress':
            final address = (call.arguments as Map)['address'] as String;
            return address.startsWith('bc1qrecipient');
          case 'getTransactionMaxValue':
            // Fee-size estimation only; the mocked native channel never signs
            // or broadcasts a transaction.
            return '140';
          default:
            throw StateError('Unexpected Trustdart call: ${call.method}');
        }
      })
      ..setMockMethodCallHandler(toast, (_) async => true);
  });

  tearDown(() {
    HttpOverrides.global = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(trustdart, null)
      ..setMockMethodCallHandler(toast, null);
  });

  const recipient = 'bc1qrecipient00000000000000000000000000000000';

  CoinModel makeCoin({BigInt? balance}) => CoinModel()
    ..coin = {
      'coinType': 'BTC',
      'blockchainType': 'Bitcoin',
      'unit': 'BTC',
      'miniName': 'BTC',
      'decimals': 8,
      'isContract': false,
      'contract': '',
      'path': {'legacy': "m/44'/0'/0'/0/0"},
    }
    ..address = 'bc1qsender000000000000000000000000000000000'
    ..addrType = 'legacy'
    // This synthetic placeholder is only passed to the mocked fee-size
    // estimator; the test never invokes a signing or broadcast method.
    ..privateKey = 'synthetic-non-secret-test-value'
    ..balance = balance ?? BigInt.from(100000000);

  Future<dynamic> mount(
    WidgetTester tester, {
    BigInt? balance,
    bool clearApiError = true,
  }) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainSendBtc(makeCoin(balance: balance)),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
    final dynamic state = tester.state(find.byType(WalletChainSendBtc));
    // Use local synthetic UTXOs for every fee calculation; getUTXO will then
    // honor its completed-page marker and never reach the HTTP layer.
    state
      ..unspents = [
        {
          'txid': 'synthetic-txid',
          'output_no': 0,
          'value': '1.0',
          'hex': '0014synthetic-script',
        },
      ]
      ..utxoLastPage = true;
    // Fee endpoint fails fast offline and leaves an informational error;
    // clear it for local UTXO/Max cases unless a test exercises that gate.
    if (clearApiError) state.errorMessage = '';
    expect(tester.takeException(), isNull);
    return state;
  }

  testWidgets('BTC amount form validates values and uses local UTXO fees', (
    tester,
  ) async {
    final state = await mount(tester);

    for (final value in ['', '0', '-1', '1e2', 'not-a-number', '0.000009']) {
      state.amountCheck(value: value);
      expect(state.amountErrorMessage, isNotEmpty, reason: value);
    }

    state.amountCheck(value: '0.5');
    await tester.pumpAndSettle();
    expect(state.amountErrorMessage, isEmpty);
    expect(state.price, 50000000);
    expect(state.inputUTXO, [
      {
        'txid': 'synthetic-txid',
        'vout': 0,
        'value': '100000000',
        'script': '0014synthetic-script',
      },
    ]);
    expect(trustdartCalls, contains('getTransactionMaxValue'));
    expect(
      tester.widgetList<Text>(find.byType(Text)).map((text) => text.data),
      contains('0.500007 BTC'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('BTC Max subtracts the estimated fee from the local balance', (
    tester,
  ) async {
    final state = await mount(tester);

    final maxButton = find.ancestor(
      of: find.text('Max'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(find.text('Max'));
    await tester.pumpAndSettle();
    await tester.tap(maxButton.first);
    await tester.pumpAndSettle();

    expect(trustdartCalls, contains('getTransactionMaxValue'));
    expect(state.price, 99999300);
    expect(state.valueTextEditingController.text, '0.999993');
    expect(state.inputUTXO.single['txid'], 'synthetic-txid');
    expect(tester.takeException(), isNull);
  });

  testWidgets('BTC amount field validates after its debounce interval', (
    tester,
  ) async {
    final state = await mount(tester);
    final amountField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller == state.valueTextEditingController,
    );

    await tester.enterText(amountField, '0.5');
    await tester.pump(const Duration(milliseconds: 299));
    expect(state.price, 0);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(state.price, 50000000);
    expect(state.amountErrorMessage, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BTC send button rejects an invalid recipient before review', (
    tester,
  ) async {
    final state = await mount(tester);
    state
      ..valueTextEditingController.text = '0.5'
      ..toTextEditingController.text = 'invalid-address';

    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    expect(state.toErrorMessage, isNotEmpty);
    expect(find.byType(WalletBaseSend), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
    expect(trustdartCalls, isNot(contains('signTransaction')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('BTC send button keeps review gated by fee state', (
    tester,
  ) async {
    final state = await mount(tester, clearApiError: false);
    state
      ..valueTextEditingController.text = '0.5'
      ..toTextEditingController.text = recipient;

    expect(find.text('Failed to get data'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to get data'), findsOneWidget);
    expect(find.byType(WalletBaseSend), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
    expect(trustdartCalls, isNot(contains('signTransaction')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('BTC recipient validation distinguishes valid and self address', (
    tester,
  ) async {
    final state = await mount(tester);

    await state.toAddressCheck(recipient);
    expect(state.toErrorMessage, isEmpty);
    await state.toAddressCheck('bc1qsender000000000000000000000000000000000');
    expect(state.toErrorMessage, isNotEmpty);
    await state.toAddressCheck('invalid-address');
    expect(state.toErrorMessage, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
