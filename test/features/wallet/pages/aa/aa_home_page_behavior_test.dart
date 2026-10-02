import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_create_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_list_page.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_home_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/smart_account_card.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _owner = '0x1111111111111111111111111111111111111111';

SmartAccount _account(int index, {int chainId = 1}) => SmartAccount(
  address: '0x${index.toString().padLeft(40, '0')}',
  type: SmartAccountType.simpleAccount,
  ownerAddress: _owner,
  state: SmartAccountState.notDeployed,
  chainId: chainId,
  salt: BigInt.from(index),
  factoryAddress: '0x${'f' * 40}',
  createdAt: DateTime(2026, 1, index),
  label: 'Account $index',
);

void main() {
  Future<S> openHome(
    WidgetTester tester, {
    required String walletAddress,
    AAAccountInfo? accountInfo,
  }) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      wrapForTest(
        AAHomePage(walletAddress: walletAddress, accountInfo: accountInfo),
      ),
    );
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(AAHomePage)));
  }

  testWidgets('unsupported owner address disables AA actions with guidance', (
    tester,
  ) async {
    final l10n = await openHome(tester, walletAddress: 'not-an-evm-address');

    expect(find.text(l10n.g_key_bridge_chain_not_supported), findsWidgets);
    expect(find.text(l10n.g_key_aa_my_accounts), findsOneWidget);

    await tester.tap(find.text(l10n.g_key_48));
    await tester.pump();
    expect(find.text(l10n.g_key_bridge_chain_not_supported), findsWidgets);

    await tester.tap(find.text(l10n.g_key_aa_create_account));
    await tester.pump();
    expect(find.byType(AAHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'valid owner sees onboarding guidance and can open account creation',
    (tester) async {
      final l10n = await openHome(
        tester,
        walletAddress: _owner,
        accountInfo: AAAccountInfo(smartAccounts: {}),
      );

      expect(find.text(l10n.g_key_aa_no_accounts), findsOneWidget);
      expect(find.text(l10n.g_key_aa_onboard_step1), findsOneWidget);
      expect(find.text(l10n.g_key_aa_onboard_step2), findsOneWidget);
      expect(find.text(l10n.g_key_aa_onboard_step3), findsOneWidget);

      await tester.tap(find.text(l10n.g_key_aa_batch));
      await tester.pump();
      expect(find.text(l10n.g_key_aa_create_first), findsOneWidget);

      await tester.tap(find.text(l10n.g_key_aa_create_account));
      await tester.pumpAndSettle();
      expect(find.byType(AAAccountCreatePage), findsOneWidget);
      expect(find.byType(AAAccountListPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home previews three accounts and opens the complete list', (
    tester,
  ) async {
    final accounts = [_account(1), _account(2), _account(3), _account(4)];
    final l10n = await openHome(
      tester,
      walletAddress: _owner,
      accountInfo: AAAccountInfo(smartAccounts: {1: accounts}),
    );

    expect(find.byType(SmartAccountCard), findsNWidgets(3));
    expect(find.text('Account 1'), findsOneWidget);
    expect(find.text('Account 3'), findsOneWidget);
    expect(find.text('Account 4'), findsNothing);

    await tester.tap(find.text(l10n.g_key_aa_view_all));
    await tester.pumpAndSettle();

    expect(find.byType(AAAccountListPage), findsOneWidget);
    expect(find.byType(SmartAccountCard), findsNWidgets(4));
    expect(find.text('Account 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
