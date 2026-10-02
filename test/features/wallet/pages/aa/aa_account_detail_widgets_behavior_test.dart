import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_account_detail_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _owner = '0x1111111111111111111111111111111111111111';
const _accountAddress = '0x2222222222222222222222222222222222222222';

SmartAccount _account({int chainId = 1, DateTime? lastActivityAt}) =>
    SmartAccount(
      address: _accountAddress,
      type: SmartAccountType.simple7702Account,
      ownerAddress: _owner,
      state: SmartAccountState.notDeployed,
      chainId: chainId,
      salt: BigInt.zero,
      factoryAddress: '0x${'f' * 40}',
      createdAt: DateTime(2026, 2, 3),
      lastActivityAt: lastActivityAt,
      label: 'Primary smart wallet',
    );

void main() {
  Future<S> openPage(
    WidgetTester tester, {
    int chainId = 1,
    DateTime? lastActivityAt,
  }) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      wrapForTest(
        AAAccountDetailPage(
          account: _account(chainId: chainId, lastActivityAt: lastActivityAt),
          walletAddress: _owner,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(AAAccountDetailPage)));
  }

  testWidgets(
    'shows account identity, shortened metadata and optional activity',
    (tester) async {
      await openPage(tester, lastActivityAt: DateTime(2026, 10, 2));

      expect(find.text('Primary smart wallet'), findsWidgets);
      expect(find.text('EIP-7702 Account'), findsOneWidget);
      expect(find.text(_accountAddress), findsOneWidget);
      expect(find.text('0xffffff...ffffff'), findsOneWidget);
      expect(find.text('2026-02-03'), findsOneWidget);
      expect(find.text('2026-10-02'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('receive action shows a QR and selectable account address', (
    tester,
  ) async {
    final l10n = await openPage(tester);

    await tester.tap(find.text(l10n.g_key_33));
    await tester.pumpAndSettle();

    expect(find.text(l10n.g_key_aa_receive_address), findsOneWidget);
    expect(find.text(_accountAddress), findsWidgets);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history link is shown only for a supported account chain', (
    tester,
  ) async {
    await openPage(tester);
    expect(find.byKey(const ValueKey('aa_view_history')), findsOneWidget);

    await tester.pumpWidget(
      wrapForTest(
        AAAccountDetailPage(
          account: _account(chainId: 999999),
          walletAddress: _owner,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('aa_view_history')), findsNothing);
    expect(find.text('2026-02-03'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'undeployed account disables send and status check stays actionable',
    (tester) async {
      final l10n = await openPage(tester);

      final sendLabel = find.text(l10n.g_key_48);
      final sendButton = find
          .ancestor(of: sendLabel, matching: find.byType(GestureDetector))
          .first;
      expect(tester.widget<GestureDetector>(sendButton).onTap, isNull);

      final statusLabel = find.text(l10n.g_key_aa_check_status);
      final statusButton = find
          .ancestor(of: statusLabel, matching: find.byType(GestureDetector))
          .first;
      expect(tester.widget<GestureDetector>(statusButton).onTap, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );
}
