import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/create_wallet/create_finish.dart';
import 'package:n42_wallet/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

WalletInfo _wallet() => WalletInfo(
  walletName: 'Synthetic wallet',
  mnemonic: 'synthetic test phrase',
  password: 'local-test-password',
  walletUuid: 'synthetic-user',
  coinInfo: <String, dynamic>{},
);

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _pumpFinish(
  WidgetTester tester, {
  required String method,
  required WalletInfo wallet,
  required Future<void> Function(WalletInfo) saveWallet,
  Future<int> Function(WalletInfo)? validateImport,
}) async {
  await tester.pumpWidget(
    wrapForTest(
      CreateFinish(
        createMetod: method,
        wInfo: wallet,
        addWalletForTesting: saveWallet,
        checkWalletMnemonicForTesting: validateImport,
      ),
      overrides: [
        wapBridgeProvider.overrideWith((ref) => WalletActionProvider()),
      ],
    ),
  );
}

void main() {
  testWidgets('created wallet success screen can open keystore guidance', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final savedWallets = <WalletInfo>[];

    await _pumpFinish(
      tester,
      method: 'Create',
      wallet: _wallet(),
      saveWallet: (wallet) async => savedWallets.add(wallet),
    );
    await tester.pumpAndSettle();

    expect(savedWallets, hasLength(1));
    expect(find.text(S.current.g_key_wallet_c22), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c23), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c17), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c24), findsOneWidget);

    await tester.tap(find.text(S.current.g_key_wallet_c24));
    await tester.pumpAndSettle();

    expect(find.text(S.current.g_key_wallet_c25), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c26), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c27), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c28), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c29), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c30), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('imported wallet checks phrase then shows import completion', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    var validatedWallet = 0;
    final savedWallets = <WalletInfo>[];

    await _pumpFinish(
      tester,
      method: 'Import',
      wallet: _wallet(),
      validateImport: (wallet) async {
        expect(wallet.mnemonic, 'synthetic test phrase');
        validatedWallet++;
        return 0;
      },
      saveWallet: (wallet) async => savedWallets.add(wallet),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(validatedWallet, 1);
    expect(savedWallets, hasLength(1));
    expect(find.text(S.current.g_key_wallet_c15), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c16), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c17), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c24), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creation stays in loading state until wallet save completes', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final saveGate = Completer<void>();
    await _pumpFinish(
      tester,
      method: 'Create',
      wallet: _wallet(),
      saveWallet: (_) => saveGate.future,
    );
    await tester.pump();

    expect(find.text(S.current.g_key_wallet_c14), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(S.current.g_key_wallet_c17), findsNothing);
    expect(tester.takeException(), isNull);

    saveGate.complete();
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_key_wallet_c22), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
