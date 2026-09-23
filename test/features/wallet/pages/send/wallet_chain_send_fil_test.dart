import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_fil.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _trustdartChannel = MethodChannel('trustdart');
const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
const _ownerAddress = 'f1ownerfixture';

class _OfflineWalletProvider extends WalletActionProvider {
  _OfflineWalletProvider({this.failBalance = false});

  final bool failBalance;

  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async =>
      failBalance;

  @override
  void calculateBalanceWidthCoinModel() {}

  @override
  void refresh() {}
}

CoinModel _filCoin() => CoinModel()
  ..coin = {
    'coinType': 'FIL',
    'blockchainType': 'Filecoin',
    'miniName': 'FIL',
    'unit': 'FIL',
    'decimals': 18,
    'isContract': false,
    'service': '',
    'contract': '',
    'contract_test': '',
    'path': {'legacy': "m/44'/461'/0'/0/0"},
  }
  ..addrType = 'legacy'
  ..address = _ownerAddress
  ..balance = BigInt.from(5) * BigInt.from(10).pow(18);

Future<void> _mountOffline(
  WidgetTester tester,
  CoinModel coin, {
  bool failBalance = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    wrapForTest(
      WalletChainSendFil(coin),
      overrides: [
        wapBridgeProvider.overrideWith(
          (ref) => _OfflineWalletProvider(failBalance: failBalance),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

Future<T> _withNetworkDisabled<T>(Future<T> Function() run) =>
    HttpOverrides.runZoned(
      run,
      createHttpClient: (_) =>
          throw StateError('Live network disabled in test'),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final trustdartCalls = <MethodCall>[];

  setUp(() {
    trustdartCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, (call) async {
          trustdartCalls.add(call);
          if (call.method == 'validateAddress') {
            return true;
          }
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, null);
  });

  testWidgets(
    'FIL amount validation rejects invalid, zero and over-balance values',
    (tester) async {
      await _withNetworkDisabled(() async {
        await _mountOffline(tester, _filCoin());
        final amountField = find.byType(TextField).at(1);

        await tester.enterText(amountField, 'not-a-number');
        await tester.pump();
        expect(find.text(S.current.g_key_134), findsOneWidget);

        await tester.enterText(amountField, '0');
        await tester.pump();
        expect(find.text(S.current.g_key_46(0)), findsOneWidget);

        await tester.enterText(amountField, '6');
        await tester.pump();
        expect(find.text(S.current.g_key_47), findsOneWidget);

        await tester.enterText(amountField, '1.5');
        await tester.pump();
        expect(find.text(S.current.g_key_134), findsNothing);
        expect(find.text(S.current.g_key_46(0)), findsNothing);
        expect(find.text(S.current.g_key_47), findsNothing);
        expect(tester.takeException(), isNull);
      });
    },
  );

  testWidgets('FIL recipient namespace is stripped before native validation', (
    tester,
  ) async {
    await _withNetworkDisabled(() async {
      await _mountOffline(tester, _filCoin()..address = _ownerAddress);
      final recipientField = find.byType(TextField).first;
      await tester.enterText(recipientField, 'fil:f1recipientfixture');
      await tester.tap(recipientField);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();

      final validationCalls = trustdartCalls.where(
        (call) => call.method == 'validateAddress',
      );
      expect(validationCalls, hasLength(1));
      expect(validationCalls.single.arguments, {
        'coin': 'FIL',
        'address': 'f1recipientfixture',
      });
      expect(find.text(S.current.g_key_t_50), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('FIL self-transfer is rejected before network or signing', (
    tester,
  ) async {
    await _withNetworkDisabled(() async {
      await _mountOffline(tester, _filCoin());
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), _ownerAddress);
      await tester.enterText(fields.at(1), '1');
      await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_48));
      await tester.pumpAndSettle();

      expect(
        trustdartCalls.where((call) => call.method == 'validateAddress'),
        hasLength(1),
      );
      expect(find.text(S.current.g_key_t_50), findsOneWidget);
      expect(
        trustdartCalls.where((call) => call.method == 'signTransaction'),
        isEmpty,
      );
      expect(
        find.textContaining('Live network disabled in test'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('FIL missing recipient stops before native validation', (
    tester,
  ) async {
    await _withNetworkDisabled(() async {
      await _mountOffline(tester, _filCoin());
      await tester.enterText(find.byType(TextField).at(1), '1');
      await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_48));
      await tester.pumpAndSettle();

      expect(find.text(S.current.g_key_41), findsOneWidget);
      expect(trustdartCalls, isEmpty);
      expect(
        find.textContaining('Live network disabled in test'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('FIL balance refresh failure is surfaced in the send page', (
    tester,
  ) async {
    await _withNetworkDisabled(() async {
      await _mountOffline(tester, _filCoin(), failBalance: true);

      expect(find.text(S.current.g_key_t_44), findsOneWidget);
      expect(trustdartCalls, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    });
  });
}
