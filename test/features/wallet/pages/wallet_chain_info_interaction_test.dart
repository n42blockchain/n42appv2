import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_chain_info_board.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/widget_test_helpers.dart';

class _OfflineHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _OfflineHttpClient();
}

class _OfflineHttpClient implements HttpClient {
  @override
  set badCertificateCallback(
    bool Function(X509Certificate certificate, String host, int port)? callback,
  ) {}

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      throw const SocketException('Network disabled in wallet chain info test');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CoinModel _ethereumCoin() {
  final coin = CoinModel();
  coin.coin = {
    'coinType': 'ETH',
    'blockchainType': 'Ethereum',
    'name': 'Ethereum',
    'miniName': 'ETH',
    'unit': 'eth',
    'decimals': 18,
    'balance': '1000000000000000000',
    'isContract': false,
  };
  coin.address = '0x0000000000000000000000000000000000000001';
  coin.balance = BigInt.parse('1000000000000000000');
  coin.privateKey = 'synthetic-private-key';
  coin.supportTest = true;
  return coin;
}

CoinModel _ethereumToken() {
  final coin = CoinModel();
  coin.coin = {
    'coinType': 'ETH',
    'blockchainType': 'Ethereum',
    'name': 'Tether',
    'miniName': 'USDT',
    'unit': 'usdt',
    'decimals': 6,
    'contract': '0x00000000000000000000000000000000000000aa',
    'isContract': true,
  };
  coin.address = '0x0000000000000000000000000000000000000001';
  coin.privateKey = 'synthetic-private-key';
  return coin;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  final previousHttpOverrides = HttpOverrides.current;
  late Directory databaseDirectory;
  late WalletActionProvider walletStore;
  final toastMessages = <String>[];

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    databaseDirectory = await Directory.systemTemp.createTemp(
      'wallet_chain_info_test_',
    );
    await databaseFactory.setDatabasesPath(databaseDirectory.path);
    HttpOverrides.global = _OfflineHttpOverrides();
    walletStore = WalletActionProvider();
    walletStore.walletInfoList.add(WalletInfo(walletName: 'Test wallet'));
    walletStore.walletIndex = 0;
    walletStore.walletMiningIndex = 0;
    toastMessages.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          if (call.method == 'showToast') {
            toastMessages.add(
              ((call.arguments as Map)['msg'] as String?) ?? '',
            );
          }
          return true;
        });
  });

  tearDown(() async {
    HttpOverrides.global = previousHttpOverrides;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
    await databaseDirectory.delete(recursive: true);
  });

  Future<void> pumpChainInfo(WidgetTester tester, {CoinModel? coin}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletChainInfo(coin ?? _ethereumCoin()),
        overrides: [wapBridgeProvider.overrideWith((ref) => walletStore)],
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  testWidgets('Ethereum detail shows empty history and guards send actions', (
    tester,
  ) async {
    await pumpChainInfo(tester);

    expect(find.text('ETH (Ethereum)'), findsOneWidget);
    expect(find.byType(WalletChainInfoBoard), findsOneWidget);
    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text(S.current.g_coin_key_1), findsOneWidget);
    expect(tester.takeException(), isNull);

    final actions = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/wallet/w_actions.png',
    );
    await tester.tap(
      find.ancestor(of: actions, matching: find.byType(InkWell)),
    );
    await tester.pumpAndSettle();

    final sendInSheet = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text(S.current.g_key_48),
    );
    expect(sendInSheet, findsOneWidget);
    await tester.tap(sendInSheet);
    await tester.pumpAndSettle();
    expect(toastMessages, ['No recovery phrase is stored for this wallet.']);
    expect(find.byType(BottomSheet), findsNothing);

    await tester.tap(find.text(S.current.g_key_33));
    await tester.pumpAndSettle();
    expect(toastMessages, [
      'No recovery phrase is stored for this wallet.',
      'No recovery phrase is stored for this wallet.',
    ]);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('contract token detail identifies its parent chain', (
    tester,
  ) async {
    walletStore.coinModels.add(_ethereumCoin());
    await pumpChainInfo(tester, coin: _ethereumToken());

    expect(find.text('ETH (Ethereum)'), findsOneWidget);
    expect(find.text('USDT(Tether)'), findsOneWidget);
    expect(find.byType(WalletChainInfoBoard), findsOneWidget);
    expect(find.byType(EmptyView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
