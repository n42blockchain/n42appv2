import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_add_operation_sheet.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _recipient = '0x1111111111111111111111111111111111111111';
const _token = '0x2222222222222222222222222222222222222222';

void main() {
  Future<S> mount(
    WidgetTester tester, {
    required ValueChanged<BatchOperation> onAdd,
  }) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrapForTest(Scaffold(body: AddOperationSheet(onAdd: onAdd))),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return S.of(tester.element(find.byType(AddOperationSheet)));
  }

  testWidgets('approve requires a valid token contract before adding', (
    tester,
  ) async {
    BatchOperation? added;
    final l10n = await mount(tester, onAdd: (operation) => added = operation);
    await tester.tap(find.text(l10n.g_key_aa_approve));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(2), '1');
    await tester.tap(find.text(l10n.g_key_159));
    await tester.pumpAndSettle();

    expect(added, isNull);
    expect(find.text('Token contract address is required'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ERC-20 transfer cannot fall back to an ETH transfer', (
    tester,
  ) async {
    BatchOperation? added;
    final l10n = await mount(tester, onAdd: (operation) => added = operation);
    await tester.enterText(find.byType(TextField).first, _recipient);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USDT').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '1.5');
    await tester.tap(find.text(l10n.g_key_159));
    await tester.pumpAndSettle();

    expect(added, isNull);
    expect(find.text('Token contract address is required'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('valid ERC-20 transfer retains token, contract, and amount', (
    tester,
  ) async {
    BatchOperation? added;
    final l10n = await mount(tester, onAdd: (operation) => added = operation);
    await tester.enterText(find.byType(TextField).first, _recipient);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('USDT').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), _token);
    await tester.enterText(find.byType(TextField).last, '1.5');
    await tester.tap(find.text(l10n.g_key_159));
    await tester.pumpAndSettle();

    expect(added?.type, BatchOperationType.transfer);
    expect(added?.tokenSymbol, 'USDT');
    expect(added?.tokenAddress, _token);
    expect(added?.amount, BigInt.from(1500000000000000000));
    expect(tester.takeException(), isNull);
  });
}
