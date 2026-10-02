import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:n42_wallet/features/wallet/pages/token_discovery/token_discovery_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/token_discovery/discovered_token.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

class _WalletStoragePlatform extends TestFlutterSecureStoragePlatform {
  _WalletStoragePlatform(super.data);
}

class _WalletStore extends WalletActionProvider {
  _WalletStore() : super(stablecoinPriceRequest: (_) async => null);

  final Map<String, dynamic> chains = {};

  @override
  Map<String, dynamic> get walletMap => chains;
}

DiscoveredToken _token({
  String coinType = 'ETH',
  String address = '0xAbCd',
  String symbol = 'SYN',
  BigInt? balance,
}) => DiscoveredToken(
  coinType: coinType,
  blockchainType: 'Ethereum',
  contractAddress: address,
  symbol: symbol,
  name: 'Synthetic Token',
  decimals: 6,
  rawBalance: balance ?? BigInt.from(1250000),
);

Widget _app(Widget child, _WalletStore store) => ScreenUtilInit(
  designSize: const Size(360, 800),
  builder: (context, child) => ProviderScope(
    overrides: [wapBridgeProvider.overrideWith((ref) => store)],
    child: MaterialApp(
      theme: ThemeData.light(),
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: child,
    ),
  ),
  child: child,
);

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer providerContainer;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStoragePlatform.instance = _WalletStoragePlatform({});
    providerContainer = ProviderContainer();
    app.globalProviderContainer = providerContainer;
  });

  tearDown(() => providerContainer.dispose());

  testWidgets('selection controls update the batch add count', (tester) async {
    _setPhoneViewport(tester);
    final store = _WalletStore();
    await tester.pumpWidget(
      _app(
        TokenDiscoveryPage(
          tokens: [
            _token(),
            _token(address: '0x1234', symbol: 'ALT'),
          ],
        ),
        store,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1.25'), findsNWidgets(2));
    expect(find.text('Add (2)'), findsOneWidget);
    await tester.tap(find.text('Deselect all'));
    await tester.pumpAndSettle();
    expect(find.text('Add (0)'), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Add (2)'), findsOneWidget);
  });

  testWidgets('adding selected tokens maps chain metadata and returns true', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final store = _WalletStore();
    final wallet = WalletInfo(walletName: 'Test wallet')
      ..coinInfo = <String, dynamic>{};
    store.walletInfoList.add(wallet);
    store.walletIndex = 0;
    await store.addWalletChain({
      'baseInfo': {
        'coinType': 'ETH',
        'mKey': 'ETH',
        'name': 'Ethereum',
        'miniName': 'ETH',
        'unit': 'eth',
        'blockchainType': 'Ethereum',
        'decimals': 18,
        'icon': '',
        'isContract': false,
      },
      'isTest': false,
      'showList': true,
      'addrType': 'legacy',
      'pathIndex': 2,
      'mainnets': <String, dynamic>{},
      'testnets': [
        {'testnetContract': <String, dynamic>{}},
      ],
    });
    bool? result;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => TokenDiscoveryPage(tokens: [_token()]),
                ),
              );
            },
            child: const Text('Open review'),
          ),
        ),
        store,
      ),
    );
    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add (1)'));
    await tester.pumpAndSettle();

    final tokenMap = store.chains['ETH']['mainnets']['0XABCD'];
    expect(tokenMap, containsPair('contract', '0xAbCd'));
    expect(tokenMap, containsPair('coinType', 'ETH'));
    expect(find.text('No new tokens found'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('ignoring a token persists normalized contract and removes row', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final store = _WalletStore();
    await tester.pumpWidget(
      _app(TokenDiscoveryPage(tokens: [_token()]), store),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ignore'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ignoredTokenContracts'), contains('0xabcd'));
    expect(find.text('No new tokens found'), findsOneWidget);
  });
}
