import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/api/token_view_api.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/pages/add_token/wallet_coin_token_add2.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/shared/domain/entities/message_model.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _TokenApi extends TokenViewApi {
  _TokenApi(this.result);

  final MessageModel result;
  final List<String> requestedChains = [];

  @override
  Future<MessageModel> getTokenListFullname(String fullname) async {
    requestedChains.add(fullname);
    return result;
  }
}

class _WalletStore extends WalletActionProvider {
  final added = <Map<String, dynamic>>[];
  final removed = <Map<String, dynamic>>[];

  @override
  Map<String, dynamic> get walletMap => {};
}

Map<String, dynamic> _token({
  required String contract,
  required String symbol,
  String name = 'N42',
}) => {
  'contract': contract,
  'coin_name': symbol,
  'fullname': name,
  'decimals': 6,
  'icon': 'https://synthetic.invalid/$symbol.png',
};

CoinModel _coin({bool hasExistingToken = false, String name = 'Ethereum'}) =>
    CoinModel()
      ..coin = {'coinType': 'ETH', 'name': name, 'icon': 'eth.png'}
      ..tokens = hasExistingToken ? {'EXISTING-CONTRACT': {}} : {};

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late _WalletStore store;
  late List<String> toasts;

  setUp(() {
    store = _WalletStore();
    toasts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          if (call.method == 'showToast') {
            toasts.add((call.arguments as Map)['msg'].toString());
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<void> openPage(
    WidgetTester tester,
    CoinModel coin,
    _TokenApi api, {
    void Function(Object?)? onResult,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await Navigator.of(context).push<Object?>(
                MaterialPageRoute<Object?>(
                  builder: (_) => WalletCoinTokenAdd2(
                    coin,
                    tokenViewApi: api,
                    onAddToken: (token) => store.added.add(token),
                    onRemoveToken: (token) => store.removed.add(token),
                  ),
                ),
              );
              onResult?.call(result);
            },
            child: const Text('Open token list'),
          ),
        ),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.tap(find.text('Open token list'));
    await tester.pumpAndSettle();
  }

  testWidgets('filters contract-backed results and searches symbol by name', (
    tester,
  ) async {
    final api = _TokenApi(
      MessageModel()
        ..data = [
          _token(contract: 'existing-contract', symbol: 'OLD'),
          _token(contract: 'new-contract', symbol: 'NEW'),
          _token(contract: '', symbol: 'NATIVE'),
        ],
    );
    await openPage(tester, _coin(hasExistingToken: true), api);

    expect(api.requestedChains, ['Ethereum']);
    expect(find.text('N42'), findsNWidgets(2));
    expect(find.text('NATIVE'), findsNothing);
    expect(
      tester.getTopLeft(find.text('OLD  ')).dy,
      lessThan(tester.getTopLeft(find.text('NEW  ')).dy),
    );

    await tester.enterText(find.byType(TextField), 'nEw');
    await tester.tap(find.text(S.current.search));
    await tester.pumpAndSettle();

    expect(find.text('N42'), findsOneWidget);
    expect(find.text('OLD  '), findsNothing);
    expect(store.added, isEmpty);
    expect(store.removed, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'adding a token sends normalized wallet data and returns changed',
    (tester) async {
      final api = _TokenApi(
        MessageModel()
          ..data = [_token(contract: 'new-contract', symbol: 'NEW')],
      );
      Object? result;
      await openPage(tester, _coin(), api, onResult: (value) => result = value);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(store.added, hasLength(1));
      expect(store.added.single, containsPair('coinType', 'ETH'));
      expect(store.added.single, containsPair('isContract', true));
      expect(store.added.single, containsPair('contract', 'new-contract'));
      expect(store.added.single, containsPair('mKey', 'NEW-CONTRACT'));
      expect(store.added.single, containsPair('miniName', 'NEW'));
      expect(store.added.single, containsPair('unit', 'NEW'));
      expect(store.added.single, containsPair('balance', '0'));
      expect(store.added.single, containsPair('decimals', 6));
      expect(store.added.single, containsPair('canEdit', true));
      expect(find.byIcon(Icons.remove), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('removing an existing token calls the wallet store', (
    tester,
  ) async {
    final api = _TokenApi(
      MessageModel()
        ..data = [_token(contract: 'existing-contract', symbol: 'OLD')],
    );
    Object? result;
    await openPage(
      tester,
      _coin(hasExistingToken: true),
      api,
      onResult: (value) => result = value,
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(store.removed, hasLength(1));
    expect(store.removed.single, containsPair('contract', 'existing-contract'));
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('API failure clears loading and reports the response', (
    tester,
  ) async {
    final api = _TokenApi(MessageModel.error()..data = 'token service offline');
    await openPage(tester, _coin(), api);

    expect(api.requestedChains, ['Ethereum']);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(toasts, ['token service offline']);
    expect(store.added, isEmpty);
    expect(store.removed, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
  });
}
