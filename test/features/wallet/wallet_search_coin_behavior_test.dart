import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_search_coin.dart';
import 'package:n42_wallet/features/widgets/empty.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../helpers/widget_test_helpers.dart';

CoinModel _coin({
  required String type,
  required String symbol,
  required String name,
  double value = 1,
  double percentage = 0,
  dynamic address,
}) => CoinModel()
  ..coin = {
    'coinType': type,
    'blockchainType': 'Ethereum',
    'miniName': symbol,
    'name': name,
    'icon': '',
    'isContract': false,
  }
  ..value = value
  ..percentage = percentage
  ..address = address;

class _MemorySearchHistory extends SPUtil {
  _MemorySearchHistory([Iterable<String> initial = const []])
    : entries = List<String>.of(initial);

  List<String> entries;

  @override
  Future<List<String>> getCoinSearchHistory() async => List<String>.of(entries);

  @override
  Future<void> saveCoinSearchHistory(List<String> history) async {
    entries = List<String>.of(history);
  }
}

void main() {
  late WalletActionProvider wallet;
  late _MemorySearchHistory history;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    history = _MemorySearchHistory();
    wallet = WalletActionProvider()
      ..coinList = [
        _coin(
          type: 'ETH',
          symbol: 'ETH',
          name: 'Ethereum',
          value: 50,
          percentage: 1.25,
        ),
        _coin(type: 'ETHA', symbol: 'ETHA', name: 'Ether Alpha', value: 20),
        _coin(type: 'WETH', symbol: 'WETH', name: 'Wrapped Ether', value: 100),
        _coin(type: 'ETC', symbol: 'ETC', name: 'Ethereum Classic', value: 10),
        _coin(
          type: 'BTC',
          symbol: 'BTC',
          name: 'Bitcoin',
          value: 200,
          percentage: -2.5,
          address: '12345678901234567890',
        ),
      ];
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletSearchCoin(1, searchHistoryStorageForTesting: history),
        overrides: [wapBridgeProvider.overrideWith((ref) => wallet)],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets(
    'shows the wallet list, searches by relevance, and clears query',
    (tester) async {
      await mount(tester);
      expect(find.text('BTC'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'eth');
      await tester.pump(const Duration(milliseconds: 301));
      await tester.pumpAndSettle();

      final visibleSymbols = <String>[];
      for (final symbol in ['ETH', 'ETHA', 'ETC', 'WETH']) {
        final finder = find.text(symbol);
        if (finder.evaluate().isNotEmpty) visibleSymbols.add(symbol);
      }
      expect(visibleSymbols, ['ETH', 'ETHA', 'ETC', 'WETH']);
      expect(find.text('BTC'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();
      expect(find.text('BTC'), findsOneWidget);
      expect(find.byType(EmptyView), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'submitted queries persist as recent searches and can be cleared',
    (tester) async {
      await mount(tester);
      final field = find.byType(TextField);
      await tester.enterText(field, '  eth  ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pumpAndSettle();

      expect(history.entries, ['eth']);
      expect(find.text('ETH'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.g_key_batch_clear_all));
      await tester.pumpAndSettle();
      expect(history.entries, isEmpty);
      expect(find.text('eth'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'history chip applies its query and close removes only that entry',
    (tester) async {
      history.entries = ['eth', 'btc'];
      await mount(tester);
      expect(find.text('eth'), findsOneWidget);
      expect(find.text('btc'), findsOneWidget);

      await tester.tap(find.text('eth'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'eth',
      );
      expect(find.byType(EmptyView), findsNothing);
      expect(find.text('ETH'), findsOneWidget);
      expect(find.text('BTC'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(history.entries, ['btc']);
      expect(find.text('eth'), findsNothing);
      expect(find.text('btc'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
