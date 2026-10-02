import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info_xrp.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected XRP RPC request');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

class _OfflineWalletProvider extends WalletActionProvider {
  @override
  Future<bool> getBalanceWithCoinModel(CoinModel coinModel) async => true;
}

CoinModel _xrpCoin() => CoinModel()
  ..coin = {
    'coinType': 'XRP',
    'blockchainType': 'Ripple',
    'name': 'Ripple',
    'miniName': 'XRP',
    'unit': 'XRP',
    'decimals': 6,
    'isContract': false,
    'contract': '',
    'mKey': 'XRP',
    'service': 'https://rpc.synthetic.invalid',
  }
  ..address = 'rSyntheticWalletAddress'
  ..balance = BigInt.from(12_000_000)
  ..other = XrpModel(0, false, 0);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late HttpOverrides? previousHttpOverrides;

  setUp(() {
    databaseFactory = databaseFactoryFfiNoIsolate;
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _FailFastHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  testWidgets('XRP page renders balance, reserve details and empty history', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainInfoXRP(_xrpCoin()),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('XRP (Ripple)'), findsOneWidget);
    expect(find.text('12 XRP'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(EmptyView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('10 XRP (10,000,000 drops)'), findsOneWidget);
    expect(find.text('2 XRP (2,000,000 drops)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
