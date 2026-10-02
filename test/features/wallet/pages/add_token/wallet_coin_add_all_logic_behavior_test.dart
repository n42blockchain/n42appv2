import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _Store extends WalletActionProvider {
  _Store(this.map);

  final Map<String, dynamic> map;

  @override
  Map<String, dynamic> get walletMap => map;
}

class _Api extends TokenViewApi {
  _Api(this.entries);

  final List<dynamic> entries;

  @override
  Future<MessageModel> getChainListAll({
    String chains = '',
    String coins = '',
  }) async => MessageModel()..data = entries;
}

Map<String, dynamic> _walletChain({required bool isEvm}) => {
  'isTest': false,
  'showList': true,
  'baseInfo': {
    'blockchainType': isEvm ? 'Ethereum' : 'Other',
    'coinType': 'ETH',
    'name': 'Ethereum',
    'miniName': 'ETH',
    'unit': 'ETH',
    'decimals': 18,
    'service': 'https://rpc.synthetic.invalid',
    'path': {'legacy': "m/44'/60'/0'/0/0"},
  },
  'mainnets': <String, dynamic>{},
  'testnets': [
    {'testnetContract': <String, dynamic>{}},
  ],
};

Map<String, dynamic> _chainEntry({List<dynamic> tokens = const []}) => {
  'coin_name': 'ETH',
  'class_name': 'Ethereum',
  'fullname': 'Ethereum',
  'unit': 'ETH',
  'chain_name': 'Ethereum',
  'contract': '',
  'derivation': jsonEncode([
    {'path': "m/44'/60'/0'/0/0"},
  ]),
  'main_net_url': 'https://rpc.synthetic.invalid',
  'test_net_url': '',
  'rules': 'ERC-20',
  'coins': tokens,
};

Map<String, dynamic> _tokenEntry() => {
  'coin_name': 'USDC',
  'fullname': 'USD Coin',
  'contract': '0xsynthetic-usdc',
  'decimals': 6,
  'icon': '',
  'unit': 'USDC',
};

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  const addressChannel = MethodChannel('trustdart');
  late _Store store;
  late List<String> toasts;
  late List<Map<dynamic, dynamic>> validations;

  setUp(() {
    store = _Store({'ETH': _walletChain(isEvm: true)});
    toasts = [];
    validations = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(toastChannel, (call) async {
        if (call.method == 'showToast') {
          toasts.add((call.arguments as Map)['msg'].toString());
        }
        return true;
      })
      ..setMockMethodCallHandler(addressChannel, (call) async {
        expect(call.method, 'validateAddress');
        validations.add(Map<dynamic, dynamic>.from(call.arguments as Map));
        return true;
      });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(toastChannel, null)
      ..setMockMethodCallHandler(addressChannel, null);
  });

  Future<void> openPage(WidgetTester tester, List<dynamic> entries) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletCoinAddAll('', tokenViewApi: _Api(entries)),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openImportForm(WidgetTester tester) async {
    await tester.tap(find.text(S.current.g_token_m_key_5));
    await tester.pumpAndSettle();
  }

  testWidgets('known contract lookup fills token fields without an RPC call', (
    tester,
  ) async {
    await openPage(tester, [
      _chainEntry(tokens: [_tokenEntry()]),
    ]);
    await openImportForm(tester);
    await tester.enterText(find.byType(TextField).at(0), '0xsynthetic-usdc');
    await tester.pump(const Duration(milliseconds: 801));
    await tester.pumpAndSettle();

    expect(validations, hasLength(1));
    expect(validations.single['coin'], 'ETH');
    expect(validations.single['address'], '0xsynthetic-usdc');
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      'USDC',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
      '6',
    );
    expect(
      find.text(S.current.g_ui_token_found('USD Coin · 6 decimals')),
      findsOneWidget,
    );
    expect(toasts, isEmpty);
  });

  testWidgets(
    'import reports invalid chain configuration without address RPC',
    (tester) async {
      store = _Store({});
      await openPage(tester, []);
      await openImportForm(tester);
      await tester.enterText(
        find.byType(TextField).at(0),
        '0xsynthetic-address',
      );
      await tester.tap(find.text(S.current.g_token_m_key_9).last);
      await tester.pumpAndSettle();

      expect(validations, isEmpty);
      expect(find.text('Invalid chain configuration'), findsOneWidget);
      expect(toasts, isEmpty);
    },
  );

  testWidgets(
    'contract lookup rejects an invalid address before token search',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(addressChannel, (call) async {
            validations.add(Map<dynamic, dynamic>.from(call.arguments as Map));
            return false;
          });
      await openPage(tester, [
        _chainEntry(tokens: [_tokenEntry()]),
      ]);
      await openImportForm(tester);
      await tester.enterText(find.byType(TextField).at(0), 'bad-address');
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(validations, hasLength(1));
      expect(
        find.text(S.current.g_ui_token_found('USD Coin · 6 decimals')),
        findsNothing,
      );
      expect(toasts, isEmpty);
    },
  );

  testWidgets('unknown contract on a non-EVM chain does not attempt RPC', (
    tester,
  ) async {
    store = _Store({'ETH': _walletChain(isEvm: false)});
    await openPage(tester, [_chainEntry()]);
    await openImportForm(tester);
    await tester.enterText(find.byType(TextField).at(0), 'valid-but-unknown');
    await tester.pump(const Duration(milliseconds: 801));
    await tester.pumpAndSettle();

    expect(validations, hasLength(1));
    expect(
      find.text(S.current.g_ui_token_found('valid-but-unknown')),
      findsNothing,
    );
    expect(find.text(S.current.g_ui_token_manual), findsOneWidget);
    expect(toasts, isEmpty);
  });
}
