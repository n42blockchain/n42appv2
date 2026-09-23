import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/send/wallet_chain_send_sui.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _trustdartChannel = MethodChannel('trustdart');
const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
final _ownerAddress = '0x${List.filled(64, '1').join()}';

class _OfflineWalletProvider extends WalletActionProvider {
  _OfflineWalletProvider() {
    walletInfoLsit.add(WalletInfo(mnemonic: 'offline mnemonic fixture'));
    walletIndex = 0;
  }

  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => false;

  @override
  void calculateBalanceWidthCoinModel() {}

  @override
  void refresh() {}
}

CoinModel _suiCoin({String? address}) => CoinModel()
  ..coin = {
    'coinType': 'SUI',
    'blockchainType': 'Sui',
    'miniName': 'SUI',
    'unit': 'SUI',
    'decimals': 9,
    'isContract': false,
    'service': '',
    'contract': '',
    'contract_test': '',
    'path': {'legacy': "m/44'/784'/0'/0'/0'"},
  }
  ..addrType = 'legacy'
  ..address = address ?? _ownerAddress
  ..balance = BigInt.from(1000000000);

Future<void> _mountOffline(WidgetTester tester, CoinModel coin) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await HttpOverrides.runZoned(
    () async {
      await tester.pumpWidget(
        wrapForTest(
          WalletChainSendSui(coin),
          overrides: [
            wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
          ],
        ),
      );
      await tester.pumpAndSettle();
    },
    createHttpClient: (_) => throw StateError('Live network disabled in test'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var calls = <MethodCall>[];

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, (call) async {
          calls.add(call);
          if (call.method == 'validateAddress') return true;
          if (call.method == 'signTransaction') return 'offline-signature';
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_trustdartChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, null);
  });

  testWidgets(
    'amount over SUI balance is rejected and a valid amount clears it',
    (tester) async {
      await _mountOffline(tester, _suiCoin());
      final amountField = find.byType(TextField).at(1);

      await tester.enterText(amountField, '1.1');
      await tester.pump();
      expect(find.text(S.current.g_key_47), findsOneWidget);

      await tester.enterText(amountField, '0.5');
      await tester.pump();
      expect(find.text(S.current.g_key_47), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
    },
  );

  testWidgets('sending to the current SUI address is rejected before signing', (
    tester,
  ) async {
    final owner = _ownerAddress;
    await _mountOffline(tester, _suiCoin(address: owner));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), owner);
    await tester.enterText(fields.at(1), '0.5');
    await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_48));
    await tester.pumpAndSettle();

    expect(
      calls.where((call) => call.method == 'validateAddress'),
      hasLength(1),
    );
    expect(calls.where((call) => call.method == 'signTransaction'), isEmpty);
    expect(find.text(S.current.g_key_t_50), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets('failed dry run does not open transaction confirmation', (
    tester,
  ) async {
    await _mountOffline(tester, _suiCoin());
    final fields = find.byType(TextField);
    final recipient = '0x${List.filled(64, '2').join()}';
    await tester.enterText(fields.at(0), recipient);
    await tester.enterText(fields.at(1), '0.5');
    await tester.tap(find.widgetWithText(FilledButton, S.current.g_key_48));
    await tester.pumpAndSettle();

    expect(
      calls.where((call) => call.method == 'validateAddress'),
      hasLength(1),
    );
    expect(
      calls.where((call) => call.method == 'signTransaction'),
      hasLength(1),
    );
    expect(find.textContaining('Confirm'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });
}
