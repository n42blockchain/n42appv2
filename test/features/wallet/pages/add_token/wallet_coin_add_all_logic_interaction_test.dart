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

class _WalletStore extends WalletActionProvider {
  _WalletStore(this.map);

  final Map<String, dynamic> map;
  @override
  Map<String, dynamic> get walletMap => map;
}

class _TokenListApi extends TokenViewApi {
  _TokenListApi(this.items);

  final List<dynamic> items;

  @override
  Future<MessageModel> getChainListAll({
    String chains = '',
    String coins = '',
  }) async => MessageModel()..data = items;
}

Map<String, dynamic> _ethChain() => {
  'isTest': false,
  'baseInfo': {
    'blockchainType': 'Ethereum',
    'coinType': 'ETH',
    'name': 'Ethereum',
    'miniName': 'ETH',
    'unit': 'ETH',
    'decimals': 18,
    'service': 'https://rpc.synthetic.invalid',
    'canEdit': true,
  },
  'mainnets': <String, dynamic>{},
  'testnets': [
    {'testnetContract': <String, dynamic>{}},
  ],
};

Map<String, dynamic> _tokenListEntry() => {
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
  'coins': [
    {
      'coin_name': 'USDC',
      'fullname': 'USD Coin',
      'contract': '0xsynthetic-usdc',
      'decimals': 6,
      'icon': 'https://synthetic.invalid/usdc.png',
      'unit': 'USDC',
    },
  ],
};

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  const trustdartChannel = MethodChannel('trustdart');
  late List<String> toasts;
  late List<Map<dynamic, dynamic>> validations;
  late _WalletStore store;

  setUp(() {
    toasts = [];
    validations = [];
    store = _WalletStore({'ETH': _ethChain()});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          if (call.method == 'showToast') {
            toasts.add((call.arguments as Map)['msg'].toString());
          }
          return true;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdartChannel, (call) async {
          expect(call.method, 'validateAddress');
          validations.add(Map<dynamic, dynamic>.from(call.arguments as Map));
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(trustdartChannel, null);
  });

  Future<void> openImportForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletCoinAddAll('', tokenViewApi: _TokenListApi([])),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_token_m_key_5));
    await tester.pumpAndSettle();
  }

  testWidgets('empty contract address short-circuits native validation', (
    tester,
  ) async {
    await openImportForm(tester);

    await tester.tap(find.text(S.current.g_token_m_key_9));
    await tester.pumpAndSettle();

    expect(validations, isEmpty);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(toasts, isEmpty);
  });

  testWidgets(
    'contract validation uses the selected chain before form checks',
    (tester) async {
      await openImportForm(tester);
      await tester.enterText(
        find.byType(TextField).at(0),
        '0xsynthetic-address',
      );

      await tester.tap(find.text(S.current.g_token_m_key_9));
      await tester.pumpAndSettle();

      expect(validations, isNotEmpty);
      expect(validations, everyElement(containsPair('coin', 'ETH')));
      expect(
        validations,
        everyElement(containsPair('address', '0xsynthetic-address')),
      );
      expect(toasts, isEmpty);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets('empty symbol validation is rendered after import is rejected', (
    tester,
  ) async {
    await openImportForm(tester);
    await tester.enterText(find.byType(TextField).at(0), '0xsynthetic-address');

    await tester.tap(find.text(S.current.g_token_m_key_9));
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_key_41), findsOneWidget);
  });

  testWidgets(
    'invalid decimals validation is rendered after import is rejected',
    (tester) async {
      await openImportForm(tester);
      await tester.enterText(
        find.byType(TextField).at(0),
        '0xsynthetic-address',
      );
      await tester.enterText(find.byType(TextField).at(1), 'USD');
      await tester.enterText(find.byType(TextField).at(2), 'not-a-number');

      await tester.tap(find.text(S.current.g_token_m_key_9));
      await tester.pumpAndSettle();

      expect(find.text(S.current.g_token_m_key_2), findsOneWidget);
    },
  );

  testWidgets('search matches token symbol and full name case-insensitively', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapForTest(
        WalletCoinAddAll('', tokenViewApi: _TokenListApi([_tokenListEntry()])),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();

    final search = find.byType(TextField).first;
    await tester.enterText(search, 'usd');
    await tester.tap(find.text(S.current.search).last);
    await tester.pumpAndSettle();
    expect(find.text('USD Coin'), findsOneWidget);

    await tester.enterText(search, 'USDC');
    await tester.tap(find.text(S.current.search).last);
    await tester.pumpAndSettle();
    expect(find.text('USD Coin'), findsOneWidget);

    await tester.enterText(search, 'missing');
    await tester.tap(find.text(S.current.search).last);
    await tester.pumpAndSettle();
    expect(find.text('USD Coin'), findsNothing);
  });
}
