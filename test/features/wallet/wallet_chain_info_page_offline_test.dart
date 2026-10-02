import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_chain_info.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected transaction-history request');
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

CoinModel _coin() => CoinModel()
  ..coin = {
    'coinType': 'ETH',
    'blockchainType': 'Ethereum',
    'name': 'Ethereum',
    'miniName': 'ETH',
    'unit': 'ETH',
    'decimals': 18,
    'isContract': false,
    'contract': '',
    'chainId': 1,
    'chainId_test': 5,
    'service': 'https://rpc.synthetic.invalid',
  }
  ..address = '0x0000000000000000000000000000000000000001'
  ..balance = BigInt.from(2_000_000_000_000_000_000);

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

  testWidgets('empty transaction history renders and supports refresh', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        WalletChainInfo(_coin()),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => _OfflineWalletProvider()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ETH (Ethereum)'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView).first, const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('ETH (Ethereum)'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
