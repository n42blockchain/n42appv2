import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/coin_config_view.dart';
import 'package:n42_wallet/features/wallet/models/coin_model.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/manage_chains_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../integration_test/t26_b_device_regression_test.dart'
    as scenario;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final chains = [
    'N',
    'BTC',
    'ETH',
    'SOL',
    ...List.generate(61, (i) => 'CHAIN_$i'),
  ];
  late WalletActionProvider store;
  late TestFlutterSecureStoragePlatform storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = TestFlutterSecureStoragePlatform({});
    FlutterSecureStoragePlatform.instance = storage;
    app.globalProviderContainer = ProviderContainer();
    store = WalletActionProvider();
    final wallet = WalletInfo(walletName: 'Synthetic reorder wallet')
      ..coinInfo = <String, dynamic>{};
    store.walletInfoList.add(wallet);
    store.walletIndex = 0;
    for (final symbol in chains) {
      final info = <String, dynamic>{
        'coinType': symbol,
        'mKey': symbol,
        'name': symbol,
        'miniName': symbol,
        'icon': '',
        'decimals': 18,
      };
      wallet.coinInfo![symbol] = {
        'baseInfo': info,
        'mainnets': <String, dynamic>{},
        'showList': true,
      };
      store.coinModels.add(CoinModel.fromMap(info));
    }
  });
  tearDown(() => app.globalProviderContainer.dispose());

  testWidgets(
    'real chain page moves the dragged chain and persists its order',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [wapBridgeProvider.overrideWith((ref) => store)],
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) => MaterialApp(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: const ManageChainsPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scenario.dragReorderItemDownTwo(
        tester,
        itemKey: 'N',
        dragIcon: Icons.drag_handle_rounded,
        thirdItemKey: 'ETH',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(store.coinModels.map((coin) => coin.config.coinType), [
        'BTC',
        'ETH',
        'N',
        ...chains.skip(3),
      ]);
      final persisted =
          jsonDecode(storage.data['walletInfo']!) as Map<String, dynamic>;
      final wallets =
          (persisted['AstranetWallet'] as Map<String, dynamic>)['wallet']
              as List;
      expect((wallets.single as Map)['chainOrder'], [
        'BTC',
        'ETH',
        'N',
        ...chains.skip(3),
      ]);
      await scenario.dragReorderItemToTop(
        tester,
        itemKey: 'N',
        dragIcon: Icons.drag_handle_rounded,
        topItemKey: 'BTC',
      );
      await tester.pumpAndSettle();
      expect(store.coinModels.map((coin) => coin.config.coinType), chains);
      final restored =
          jsonDecode(storage.data['walletInfo']!) as Map<String, dynamic>;
      final restoredWallets =
          (restored['AstranetWallet'] as Map)['wallet'] as List;
      expect((restoredWallets.single as Map)['chainOrder'], chains);
    },
  );
}
