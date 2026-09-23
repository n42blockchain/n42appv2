import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_page.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';
import 'package:n42_wallet/features/wallet/widgets/wallet_search_coin.dart';
import 'package:n42_wallet/features/wallet_connect/presentation/providers/wallet_connect_providers.dart';
import 'package:n42_wallet/features/wallet_connect/provider/wallet_connect_provider.dart';
import 'package:n42_wallet/features/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_helpers.dart';

class _UninitializedWalletProvider extends WalletActionProvider {
  @override
  bool get isWalletReady => false;

  @override
  Future<void> initWallet({bool shouldInitCoinInfo = false}) async {}

  @override
  void refresh() {}
}

class _ReadyWalletProvider extends WalletActionProvider {
  _ReadyWalletProvider({required WalletInfo wallet}) {
    walletInfoLsit.add(wallet);
    walletIndex = 0;
  }

  @override
  Future<void> initWallet({bool shouldInitCoinInfo = false}) async {}

  @override
  void refresh() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<_ReadyWalletProvider> pumpReadyWalletHome(
    WidgetTester tester,
    WalletInfo walletInfo,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final wallet = _ReadyWalletProvider(wallet: walletInfo);
    final walletConnect = WalletConnectProvider();
    await tester.pumpWidget(
      wrapForTest(
        const WalletPage(),
        overrides: [
          wapBridgeProvider.overrideWith((ref) => wallet),
          wcpBridgeProvider.overrideWith((ref) => walletConnect),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return wallet;
  }

  testWidgets('wallet home shows loading until the selected wallet is ready', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapForTest(
        const WalletPage(),
        overrides: [
          wapBridgeProvider.overrideWith(
            (ref) => _UninitializedWalletProvider(),
          ),
        ],
      ),
    );
    await tester.pump();

    expect(find.byType(Loading), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('watch-only wallet can receive but cannot open send flow', (
    tester,
  ) async {
    await pumpReadyWalletHome(
      tester,
      WalletInfo(walletName: 'Cold wallet', password: 'protected', coinInfo: {})
        ..watchOnly = true,
    );

    expect(find.text('Cold wallet'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('wallet_select_account')),
        matching: find.byIcon(Icons.visibility_outlined),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('wallet_action_send')), findsOneWidget);
    expect(find.byKey(const ValueKey('wallet_action_receive')), findsOneWidget);
    expect(find.byType(WalletSearchCoin), findsNothing);

    await tester.tap(find.byKey(const ValueKey('wallet_action_send')));
    await tester.pump();
    expect(find.byType(WalletSearchCoin), findsNothing);

    await tester.tap(find.byKey(const ValueKey('wallet_action_receive')));
    await tester.pumpAndSettle();
    expect(find.byType(WalletSearchCoin), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unbacked wallet without a recovery phrase fails closed', (
    tester,
  ) async {
    await pumpReadyWalletHome(
      tester,
      WalletInfo(walletName: 'Unbacked wallet', password: '', coinInfo: {}),
    );

    await tester.tap(find.byKey(const ValueKey('wallet_action_send')));
    await tester.pump();

    expect(find.byType(WalletSearchCoin), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unprotected wallet asks for backup before opening send flow', (
    tester,
  ) async {
    await pumpReadyWalletHome(
      tester,
      WalletInfo(
        walletName: 'Recovery wallet',
        mnemonic: 'abandon ability able about above absent',
        password: '',
        coinInfo: {},
      ),
    );

    await tester.tap(find.byKey(const ValueKey('wallet_action_send')));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.byType(TextButton)),
      findsOneWidget,
    );
    expect(find.byType(WalletSearchCoin), findsNothing);
    await tester.tap(
      find.descendant(of: dialog, matching: find.byType(TextButton)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
