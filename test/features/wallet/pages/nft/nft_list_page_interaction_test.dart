import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/nft/nft_list_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw const SocketException('blocked by deterministic NFT test');
  }
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

CoinModel _coin({String? address, String coinType = 'ETH'}) {
  final coin = CoinModel();
  coin.address = address;
  coin.coin = {'coinType': coinType};
  return coin;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previousHttpOverrides = HttpOverrides.current;

  setUp(() {
    HttpOverrides.global = _FailFastHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
  });

  Future<void> pumpPage(WidgetTester tester, CoinModel coin) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrapForTest(NftListPage(coin)));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'missing wallet address renders the empty gallery without a request',
    (tester) async {
      await pumpPage(tester, _coin(address: '   '));

      expect(find.text(S.current.g_key_nft_no_items), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('unsupported chain resolves to the empty gallery', (
    tester,
  ) async {
    await pumpPage(
      tester,
      _coin(address: 'wallet-address', coinType: 'UNKNOWN'),
    );

    expect(find.text(S.current.g_key_nft_no_items), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('network failure settles into empty gallery instead of hanging', (
    tester,
  ) async {
    await pumpPage(
      tester,
      _coin(address: '0x0000000000000000000000000000000000000001'),
    );

    expect(find.text(S.current.g_key_nft_no_items), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
