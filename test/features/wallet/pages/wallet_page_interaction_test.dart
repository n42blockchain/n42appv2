import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/providers/service_providers.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_flow_utils.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_search_coin.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_board.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');

  late WalletActionProvider store;
  late WalletConnectProvider walletConnect;
  late List<String> toastMessages;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = WalletActionProvider()..buildwallet = true;
    walletConnect = WalletConnectProvider();
    toastMessages = [];
    app.globalProviderContainer = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(null)],
    );

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

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
    app.globalProviderContainer.dispose();
  });

  Future<void> pumpWalletPage(
    WidgetTester tester, {
    Future<void> Function(WalletActionProvider)? initializeWalletForTest,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        WalletPage(initializeWalletForTest: initializeWalletForTest),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => store),
          wcpBridgeProvider.overrideWith((ref) => walletConnect),
        ],
      ),
    );
    await tester.pump();
    for (var attempt = 0; attempt < 20 && !store.isWalletReady; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump();
  }

  testWidgets('wallet home remains in loading state until a wallet is ready', (
    tester,
  ) async {
    await pumpWalletPage(tester);

    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(WalletBoard), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'wallet home returns to loading while the selected wallet index is invalid',
    (tester) async {
      final wallet = WalletInfo(
        walletName: 'Synthetic wallet',
        password: 'synthetic-protected-wallet',
        walletUuid: 'synthetic-account',
        coinInfo: <String, dynamic>{},
      );

      await pumpWalletPage(
        tester,
        initializeWalletForTest: (provider) async {
          provider.walletInfoList.add(wallet);
          provider.walletIndex = 0;
          provider.walletMiningIndex = 0;
          provider.buildwallet = false;
          provider.refresh();
        },
      );

      expect(find.byType(WalletBoard), findsOneWidget);
      store.walletIndex = 1;
      store.refresh();
      await tester.pump();

      expect(find.byType(Loading), findsOneWidget);
      expect(find.byType(WalletBoard), findsNothing);
      expect(tester.takeException(), isNull);

      store.walletIndex = 0;
      store.refresh();
      await tester.pump();
      expect(find.byType(WalletBoard), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('loaded watch-only wallet refuses to open the send flow', (
    tester,
  ) async {
    final wallet = WalletInfo(
      walletName: 'Synthetic watch-only wallet',
      password: 'synthetic-protected-wallet',
      walletUuid: 'synthetic-watch-only-account',
      coinInfo: <String, dynamic>{},
    )..watchOnly = true;

    await pumpWalletPage(
      tester,
      initializeWalletForTest: (provider) async {
        provider.walletInfoList.add(wallet);
        provider.walletIndex = 0;
        provider.walletMiningIndex = 0;
        provider.buildwallet = false;
        provider.refresh();
      },
    );

    expect(store.isWalletReady, isTrue);
    expect(find.text('Synthetic watch-only wallet'), findsOneWidget);
    expect(find.byType(WalletBoard), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey<String>('wallet_action_send')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 8));

    expect(toastMessages, [S.current.g_key_watch_only_cant_send]);
    expect(find.byType(WalletSearchCoin), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('unbacked wallet without a recovery phrase cannot send', (
    tester,
  ) async {
    final wallet = WalletInfo(
      walletName: 'Synthetic unbacked wallet',
      password: '',
      walletUuid: 'synthetic-unbacked-account',
      coinInfo: <String, dynamic>{},
    );

    await pumpWalletPage(
      tester,
      initializeWalletForTest: (provider) async {
        provider.walletInfoList.add(wallet);
        provider.walletIndex = 0;
        provider.walletMiningIndex = 0;
        provider.buildwallet = false;
        provider.refresh();
      },
    );

    await tester.tap(find.byKey(const ValueKey<String>('wallet_action_send')));
    await tester.pump();

    expect(toastMessages, [walletBackupPhraseUnavailableMessage]);
    expect(find.byType(WalletSearchCoin), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('watch-only wallet can still open the receive asset selector', (
    tester,
  ) async {
    final wallet = WalletInfo(
      walletName: 'Synthetic watch-only wallet',
      password: 'synthetic-protected-wallet',
      walletUuid: 'synthetic-watch-only-account',
      coinInfo: <String, dynamic>{},
    )..watchOnly = true;

    await pumpWalletPage(
      tester,
      initializeWalletForTest: (provider) async {
        provider.walletInfoList.add(wallet);
        provider.walletIndex = 0;
        provider.walletMiningIndex = 0;
        provider.buildwallet = false;
        provider.refresh();
      },
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('wallet_action_receive')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WalletSearchCoin), findsOneWidget);
    expect(toastMessages, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'ENS and smart-account entries explain unavailable EVM features',
    (tester) async {
      final wallet = WalletInfo(
        walletName: 'Synthetic wallet without EVM address',
        password: 'synthetic-protected-wallet',
        walletUuid: 'synthetic-no-evm-account',
        coinInfo: <String, dynamic>{},
      );

      await pumpWalletPage(
        tester,
        initializeWalletForTest: (provider) async {
          provider.walletInfoList.add(wallet);
          provider.walletIndex = 0;
          provider.walletMiningIndex = 0;
          provider.buildwallet = false;
          provider.refresh();
        },
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('wallet_feature_ens')),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey<String>('wallet_feature_smart_account')),
      );
      await tester.pump();

      expect(toastMessages, [
        S.current.g_key_bridge_chain_not_supported,
        S.current.g_key_bridge_chain_not_supported,
      ]);
      expect(find.byType(WalletSearchCoin), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
