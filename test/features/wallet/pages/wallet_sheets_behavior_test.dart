import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n42_wallet/features/wallet/models/wallet_info.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_backup/backup_one.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_sheets.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:n42_wallet/features/wallet/provider/wallet_action_provider.dart';

import '../../../helpers/widget_test_helpers.dart';

class _WalletProvider extends Mock implements WalletActionProvider {}

void main() {
  late _WalletProvider walletProvider;
  late List<WalletInfo> wallets;

  setUp(() {
    walletProvider = _WalletProvider();
    wallets = [
      WalletInfo(walletName: 'Primary')..mainWallet = true,
      WalletInfo(walletName: 'Savings'),
    ];
    when(() => walletProvider.walletInfoLsit).thenReturn(wallets);
    when(() => walletProvider.walletIndex).thenReturn(0);
    when(
      () => walletProvider.walletInfo,
    ).thenReturn(WalletInfo(walletName: 'Primary'));
    when(() => walletProvider.setWalletIndex(any())).thenAnswer((_) async {});
  });

  Future<void> openAddressSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAddressSheet(context, ref, walletProvider),
                child: const Text('Open wallets'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open wallets'));
    await tester.pumpAndSettle();
  }

  testWidgets('selecting another wallet persists its index and closes sheet', (
    tester,
  ) async {
    await openAddressSheet(tester);

    await tester.tap(find.text('Savings'));
    await tester.pumpAndSettle();

    verify(() => walletProvider.setWalletIndex(1)).called(1);
    expect(find.text('Savings'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the already selected wallet only closes the sheet', (
    tester,
  ) async {
    await openAddressSheet(tester);

    await tester.tap(find.text('Primary'));
    await tester.pumpAndSettle();

    verifyNever(() => walletProvider.setWalletIndex(any()));
    expect(find.text('Primary'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backup reminder refuses to open for a wallet without mnemonic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(
        Scaffold(body: BackupReminderBanner(waValue: walletProvider)),
      ),
    );

    final context = tester.element(find.byType(BackupReminderBanner));
    final backupLabel = find.text(S.of(context).g_key_wallet_c36);
    await tester.tap(backupLabel);
    await tester.pumpAndSettle();

    expect(find.byType(BackupOne), findsNothing);
    expect(find.text('BackupOne'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add-token floating control invokes its supplied action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var taps = 0;
    await tester.pumpWidget(
      wrapForTest(Scaffold(body: AddTokenFloatingIcon(onTap: () => taps++))),
    );

    await tester.tap(find.byType(AddTokenFloatingIcon));

    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
