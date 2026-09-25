import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_add_all.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _AssetStore extends WalletActionProvider {
  @override
  Map<String, dynamic> get walletMap => {};
}

class _TokenListApi extends TokenViewApi {
  _TokenListApi(this.result);

  final MessageModel result;
  int calls = 0;

  @override
  Future<MessageModel> getChainListAll({
    String chains = '',
    String coins = '',
  }) async {
    calls++;
    return result;
  }
}

Map<String, dynamic> _chain({
  required String symbol,
  required String blockchain,
  required String fullname,
  required String childChainName,
}) => {
  'coin_name': symbol,
  'class_name': blockchain,
  'derivation': jsonEncode([
    {'path': "m/44'/60'/0'/0/0"},
  ]),
  'unit': symbol,
  'fullname': fullname,
  'chain_name': childChainName,
  'contract': '',
  'main_net_url': 'https://synthetic.invalid/rpc',
  'test_net_url': '',
  'rules': 'synthetic-token-standard',
  'coins': [
    {
      'coin_name': 'USDC',
      'contract': 'synthetic-$symbol-contract',
      'fullname': 'USD Coin',
      'decimals': 6,
      'unit': 'USDC',
    },
  ],
};

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late _AssetStore store;
  late List<String> toasts;

  setUp(() {
    store = _AssetStore();
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          if (call.method == 'showToast') {
            toasts.add((call.arguments as Map)['msg'] as String);
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<void> openPage(WidgetTester tester, _TokenListApi api) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletCoinAddAll('USDC', tokenViewApi: api),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('searches tokens across chains and filters by selected network', (
    tester,
  ) async {
    final api = _TokenListApi(
      MessageModel()
        ..data = [
          _chain(
            symbol: 'ETH',
            blockchain: 'Ethereum',
            fullname: 'Ethereum',
            childChainName: 'Ethereum',
          ),
          _chain(
            symbol: 'SOL',
            blockchain: 'Solana',
            fullname: 'Solana',
            childChainName: 'Solana',
          ),
        ],
    );
    await openPage(tester, api);

    expect(api.calls, 1);
    expect(find.text('USD Coin'), findsNWidgets(2));
    expect(store.walletMap, isEmpty);

    await tester.tap(find.text(S.current.g_token_m_key_4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solana'));
    await tester.pumpAndSettle();

    expect(find.text('Solana'), findsOneWidget);
    expect(find.text('USD Coin'), findsOneWidget);
    expect(store.walletMap, isEmpty);
  });

  testWidgets('API errors finish loading and surface the response', (
    tester,
  ) async {
    final api = _TokenListApi(
      MessageModel.error()..data = 'synthetic token-list error',
    );
    await openPage(tester, api);

    expect(api.calls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(toasts, contains('synthetic token-list error'));
    expect(store.walletMap, isEmpty);
    await tester.pump(const Duration(seconds: 8));
  });
}
