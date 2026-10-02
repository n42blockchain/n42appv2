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

class _RecordingWalletStore extends WalletActionProvider {
  _RecordingWalletStore(this.map);

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

Map<String, dynamic> _chain({
  required String blockchainType,
  required String coinType,
  required String name,
  required String path,
}) => {
  'isTest': false,
  'showList': false,
  'baseInfo': {
    'blockchainType': blockchainType,
    'coinType': coinType,
    'name': name,
    'miniName': coinType,
    'unit': coinType,
    'decimals': 18,
    'service': 'https://rpc.synthetic.invalid',
    'canEdit': true,
    'path': {'legacy': path},
  },
  'mainnets': <String, dynamic>{},
  'testnets': [
    {'testnetContract': <String, dynamic>{}},
  ],
};

Map<String, dynamic> _chainListEntry({
  required String coinType,
  required String blockchainType,
  required String name,
  required String path,
  required String tokenSymbol,
  required String tokenName,
  required String contract,
}) => {
  'coin_name': coinType,
  'class_name': blockchainType,
  'fullname': name,
  'unit': coinType,
  'chain_name': name,
  'contract': '',
  'derivation': jsonEncode([
    {'path': path},
  ]),
  'main_net_url': 'https://rpc.synthetic.invalid',
  'test_net_url': '',
  'rules': 'synthetic',
  'coins': [
    {
      'coin_name': tokenSymbol,
      'fullname': tokenName,
      'contract': contract,
      'decimals': 6,
      'icon': '',
      'unit': tokenSymbol,
    },
  ],
};

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  const trustdartChannel = MethodChannel('trustdart');
  late _RecordingWalletStore store;
  late List<dynamic> entries;
  late List<String> toasts;

  setUp(() {
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(toastChannel, (call) async {
        if (call.method == 'showToast') {
          toasts.add((call.arguments as Map)['msg'].toString());
        }
        return true;
      })
      ..setMockMethodCallHandler(trustdartChannel, (_) async => true);
    store = _RecordingWalletStore({
      'ETH': _chain(
        blockchainType: 'Ethereum',
        coinType: 'ETH',
        name: 'Ethereum',
        path: "m/44'/60'/0'/0/0",
      ),
      'SOL': _chain(
        blockchainType: 'Solana',
        coinType: 'SOL',
        name: 'Solana',
        path: "m/44'/501'/0'/0'",
      ),
    });
    entries = [
      _chainListEntry(
        coinType: 'ETH',
        blockchainType: 'Ethereum',
        name: 'Ethereum',
        path: "m/44'/60'/0'/0/0",
        tokenSymbol: 'USDC',
        tokenName: 'USD Coin',
        contract: '0xsynthetic-usdc',
      ),
      _chainListEntry(
        coinType: 'SOL',
        blockchainType: 'Solana',
        name: 'Solana',
        path: "m/44'/501'/0'/0'",
        tokenSymbol: 'USDT',
        tokenName: 'Tether USD',
        contract: 'solana-synthetic-usdt',
      ),
    ];
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(toastChannel, null)
      ..setMockMethodCallHandler(trustdartChannel, null);
  });

  Future<void> openPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletCoinAddAll('', tokenViewApi: _TokenListApi(entries)),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('network picker filters listed tokens to the selected chain', (
    tester,
  ) async {
    await openPage(tester);

    expect(find.text('USD Coin'), findsOneWidget);
    expect(find.text('Tether USD'), findsOneWidget);

    await tester.tap(find.text('All networks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum').last);
    await tester.pumpAndSettle();

    expect(find.text('USD Coin'), findsOneWidget);
    expect(find.text('Tether USD'), findsNothing);
  });

  testWidgets('token import rejects symbols longer than the supported limit', (
    tester,
  ) async {
    await openPage(tester);
    await tester.tap(find.text('All networks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_token_m_key_5));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '0xsynthetic-token');
    await tester.enterText(find.byType(TextField).at(1), 'VERYLONGTOKEN');
    await tester.enterText(find.byType(TextField).at(2), '6');
    await tester.tap(find.text(S.current.g_token_m_key_9));
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_token_m_key_1(10)), findsOneWidget);
  });

  testWidgets('token import rejects decimals above the supported range', (
    tester,
  ) async {
    await openPage(tester);
    await tester.tap(find.text('All networks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_token_m_key_5));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '0xsynthetic-token');
    await tester.enterText(find.byType(TextField).at(1), 'SYN');
    await tester.enterText(find.byType(TextField).at(2), '19');
    await tester.tap(find.text(S.current.g_token_m_key_9));
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_token_m_key_2), findsOneWidget);
    expect(toasts, isEmpty);
  });

  testWidgets('reimporting a wallet token reports that it already exists', (
    tester,
  ) async {
    store.map['ETH']['mainnets'] = {
      '0XSYNTHETIC-TOKEN': {'contract': '0xsynthetic-token'},
    };
    await openPage(tester);
    await tester.tap(find.text('All networks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ethereum').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.current.g_token_m_key_5));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '0xsynthetic-token');
    await tester.enterText(find.byType(TextField).at(1), 'SYN');
    await tester.enterText(find.byType(TextField).at(2), '6');
    await tester.tap(find.text(S.current.g_token_m_key_9));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 8));

    expect(toasts, ['Already exists']);
    expect(store.map['ETH']['mainnets'].keys, ['0XSYNTHETIC-TOKEN']);
  });
}
