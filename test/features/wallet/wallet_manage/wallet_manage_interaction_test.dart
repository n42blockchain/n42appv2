import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/component/enums/coin_type.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/wallet_manage.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:flutter/services.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _WalletStore extends WalletActionProvider {}

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
            toasts.add((call.arguments as Map)['msg'] as String);
          }
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
  });

  Future<void> open(
    WidgetTester tester,
    WalletInfo wallet, {
    int index = 0,
    int activeIndex = 0,
  }) async {
    store = _WalletStore();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    store.walletIndex = activeIndex;
    await tester.pumpWidget(
      wrapForTest(
        WalletManage(walletInfo: wallet, walletIndex: index),
        overrides: [wapBridgeProvider.overrideWith((ref) => store)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offers main-wallet action only for a non-main N42 wallet', (
    tester,
  ) async {
    final wallet = WalletInfo(walletName: 'Secondary')
      ..mainWallet = false
      ..coinInfo = {CoinType.N.name: const <String, dynamic>{}};
    await open(tester, wallet, index: 2);

    expect(find.text(S.current.g_key_15), findsOneWidget);
    await tester.tap(find.text(S.current.g_key_15));
    await tester.pumpAndSettle();

    expect(toasts, contains('Main wallet not found!'));
    await tester.pump(const Duration(seconds: 8));
  });

  testWidgets(
    'hides deletion for the current wallet and shows it for another',
    (tester) async {
      final wallet = WalletInfo(walletName: 'Current');
      await open(tester, wallet, index: 0);
      expect(find.text(S.current.g_key_113), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await open(
        tester,
        WalletInfo(walletName: 'Other'),
        index: 1,
        activeIndex: 0,
      );
      expect(find.text(S.current.g_key_113), findsOneWidget);
      await tester.tap(find.text(S.current.g_key_113));
      await tester.pumpAndSettle();

      expect(find.text(S.current.g_face_3), findsOneWidget);
      await tester.tap(find.text(S.current.g_key_79));
      await tester.pumpAndSettle();
      expect(find.text(S.current.g_face_3), findsNothing);
      expect(find.text('Other'), findsOneWidget);
    },
  );
  testWidgets('backup and password actions follow wallet setup state', (
    tester,
  ) async {
    final wallet = WalletInfo(
      walletName: 'Synthetic wallet',
      mnemonic: 'synthetic test-only phrase',
    );
    await open(tester, wallet);

    expect(find.text(S.current.g_key_wallet_c38), findsOneWidget);
    expect(find.text(S.current.g_key_206), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await open(
      tester,
      WalletInfo(
        walletName: 'Password wallet',
        mnemonic: 'synthetic test-only phrase',
        password: 'synthetic-test-password',
      ),
    );

    expect(find.text(S.current.g_key_206), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c38), findsNothing);
  });
}
