import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/aa/models/smart_account.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_transaction_page.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _owner = '0x1111111111111111111111111111111111111111';
const _smartAccount = '0x2222222222222222222222222222222222222222';

SmartAccount _account({int chainId = 1}) => SmartAccount(
  address: _smartAccount,
  type: SmartAccountType.simpleAccount,
  ownerAddress: _owner,
  state: SmartAccountState.notDeployed,
  chainId: chainId,
  salt: BigInt.zero,
  factoryAddress: '0x${'f' * 40}',
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<S> openPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      wrapForTest(
        AABatchTransactionPage(account: _account(), walletAddress: _owner),
      ),
    );
    await tester.pumpAndSettle();
    return S.of(tester.element(find.byType(AABatchTransactionPage)));
  }

  testWidgets('empty batch can open templates and cannot submit', (
    tester,
  ) async {
    final l10n = await openPage(tester);

    expect(find.text(l10n.g_key_aa_no_operations), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byIcon(Icons.bookmarks_outlined));
    await tester.pumpAndSettle();
    expect(find.text(l10n.g_key_aa_batch_templates), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom operation without calldata stays out of batch', (
    tester,
  ) async {
    final l10n = await openPage(tester);
    await tester.tap(find.text(l10n.g_key_aa_add_operation));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.g_key_aa_custom));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, _owner);
    await tester.tap(find.text(l10n.g_key_159).last);
    await tester.pumpAndSettle();

    expect(find.byType(BatchOperationItem), findsNothing);
    expect(find.text('Calldata is required'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
