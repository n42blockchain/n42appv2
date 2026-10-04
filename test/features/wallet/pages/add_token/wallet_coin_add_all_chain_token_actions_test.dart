import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _usdcContract = '0x1111111111111111111111111111111111111111';
const _usdtContract = '0x2222222222222222222222222222222222222222';
const _toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform() : super({});
}

class _TokenListApi extends TokenViewApi {
  _TokenListApi(this.entries);

  final List<dynamic> entries;

  @override
  Future<MessageModel> getChainListAll({
    String chains = '',
    String coins = '',
  }) async => MessageModel()..data = entries;
}

Map<String, dynamic> _nativeCoin(String symbol, String name) => {
  'coinType': symbol,
  'mKey': symbol,
  'name': name,
  'miniName': symbol,
  'unit': symbol.toLowerCase(),
  'blockchainType': 'Ethereum',
  'decimals': 18,
  'icon': '$symbol.png',
  'isContract': false,
};

Map<String, dynamic> _walletChain(String symbol, String name) => {
  'isTest': false,
  'showList': true,
  'addrType': 'legacy',
  'pathIndex': 0,
  'baseInfo': {
    ..._nativeCoin(symbol, name),
    'canEdit': true,
    'path': {'legacy': "m/44'/60'/0'/0/0"},
  },
  'mainnets': <String, dynamic>{},
  'testnets': [
    {'testnetContract': <String, dynamic>{}},
  ],
};

Map<String, dynamic> _chainEntry({
  required String symbol,
  required String name,
  required List<Map<String, dynamic>> tokens,
}) => {
  'coin_name': symbol,
  'class_name': 'Ethereum',
  'fullname': name,
  'unit': symbol,
  'chain_name': name,
  'contract': '',
  'derivation': jsonEncode([
    {'path': "m/44'/60'/0'/0/0"},
  ]),
  'main_net_url': 'https://rpc.synthetic.invalid',
  'test_net_url': '',
  'rules': 'ERC-20',
  'coins': tokens,
};

Map<String, dynamic> _token({
  required String symbol,
  required String name,
  required String contract,
}) => {
  'coin_name': symbol,
  'fullname': name,
  'contract': contract,
  'decimals': 6,
  'icon': 'https://synthetic.invalid/$symbol.png',
  'unit': symbol,
};

List<dynamic> _catalog() => [
  _chainEntry(
    symbol: 'ETH',
    name: 'Ethereum',
    tokens: [_token(symbol: 'USDC', name: 'USD Coin', contract: _usdcContract)],
  ),
  _chainEntry(
    symbol: 'BNB',
    name: 'BNB Chain',
    tokens: [
      _token(symbol: 'USDT', name: 'Tether USD', contract: _usdtContract),
    ],
  ),
];

void main() {
  late WalletActionProvider store;
  late WalletInfo wallet;
  late List<String> toasts;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = _WalletStoragePlatform();
    app.globalProviderContainer = ProviderContainer();
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, (call) async {
          if (call.method == 'showToast') {
            toasts.add((call.arguments as Map)['msg'].toString());
          }
          return true;
        });

    final ethChain = _walletChain('ETH', 'Ethereum');
    final bnbChain = _walletChain('BNB', 'BNB Chain');
    wallet = WalletInfo(walletName: 'Synthetic wallet')
      ..coinInfo = {'ETH': ethChain, 'BNB': bnbChain};
    store = WalletActionProvider();
    store.walletInfoList.add(wallet);
    store.walletIndex = 0;
    for (final chain in [ethChain, bnbChain]) {
      final native = CoinModel.fromMap(chain['baseInfo'])
        ..showList = true
        ..addrType = 'legacy'
        ..pathIndex = 0;
      store.coinModels.add(native);
      store.coinList.add(native);
    }
  });

  tearDown(() {
    app.globalProviderContainer.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_toastChannel, null);
  });

  Future<void> openPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletCoinAddAll('', tokenViewApi: _TokenListApi(_catalog())),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> selectNetwork(WidgetTester tester, String name) async {
    await tester.tap(find.text(S.current.g_token_m_key_4));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  testWidgets('network filter narrows available token before adding it', (
    tester,
  ) async {
    await openPage(tester);
    await selectNetwork(tester, 'Ethereum');

    expect(find.text('USD Coin'), findsOneWidget);
    expect(find.text('Tether USD'), findsNothing);
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    expect(wallet.coinInfo!['ETH']['mainnets'].keys, [
      _usdcContract.toUpperCase(),
    ]);
    final addedCoin = store.coinList.singleWhere(
      (coin) => coin.coin['contract'] == _usdcContract,
    );
    expect(addedCoin.coin['coinType'], 'ETH');
    expect(addedCoin.coin['contract'], _usdcContract);
    expect(addedCoin.coin['decimals'], 6);
    expect(find.byIcon(Icons.remove), findsWidgets);
    expect(toasts, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing an existing catalog token updates its chain state', (
    tester,
  ) async {
    final storedToken = {
      'coinType': 'ETH',
      'mKey': _usdcContract.toUpperCase(),
      'name': 'USD Coin',
      'miniName': 'USDC',
      'symbol': 'USDC',
      'unit': 'usdc',
      'blockchainType': 'Ethereum',
      'decimals': 6,
      'contract': _usdcContract,
      'isContract': true,
    };
    wallet.coinInfo!['ETH']['mainnets'][_usdcContract.toUpperCase()] =
        storedToken;
    store.coinList.add(CoinModel.fromMap(storedToken));
    wallet.pinnedCoins = ['ETH', 'ETH_USDC', 'ETH_USDT'];
    await openPage(tester);
    await selectNetwork(tester, 'Ethereum');

    expect(find.text('USD Coin'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove).first);
    await tester.pump();

    expect(wallet.coinInfo!['ETH']['mainnets'], isEmpty);
    expect(
      store.coinList.any(
        (coin) => coin.coin['mKey'] == _usdcContract.toUpperCase(),
      ),
      isFalse,
    );
    expect(wallet.pinnedCoins, ['ETH', 'ETH_USDT']);
    expect(find.byIcon(Icons.add), findsWidgets);
    expect(toasts, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
