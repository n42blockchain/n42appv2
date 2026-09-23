import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_transaction_body.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  testWidgets('empty batch explains how to begin and cannot be submitted', (
    tester,
  ) async {
    await _pumpBody(tester, operations: const []);

    expect(find.text(S.current.g_key_aa_no_operations), findsOneWidget);
    expect(find.text(S.current.g_key_aa_add_first_operation), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton).last).onPressed,
      isNull,
    );
  });

  testWidgets('populated sponsored batch exposes gas error and edit actions', (
    tester,
  ) async {
    int? removedIndex;
    var cleared = false;
    var paymasterTapped = false;
    final operation = BatchOperation(
      type: BatchOperationType.transfer,
      targetAddress: '0x1111111111111111111111111111111111111111',
      amount: BigInt.parse('2000000000000000000'),
      tokenSymbol: 'ETH',
      decimals: 18,
      description: 'Treasury transfer',
    );

    await _pumpBody(
      tester,
      operations: [operation],
      selectedPaymaster: PaymasterOption.sponsored,
      estimatedTotalGas: BigInt.from(50000),
      estimateError: 'Bundler estimate unavailable',
      onRemoveOperation: (index) => removedIndex = index,
      onClearAll: () => cleared = true,
      onShowPaymaster: () => paymasterTapped = true,
    );

    expect(find.text('Treasury transfer'), findsOneWidget);
    expect(find.text('Bundler estimate unavailable'), findsOneWidget);
    expect(find.text(S.current.g_key_aa_free), findsWidgets);
    expect(find.byType(BatchOperationItem), findsOneWidget);

    final removeButton = find.byIcon(Icons.delete_outline);
    await tester.ensureVisible(removeButton);
    await tester.tap(removeButton);
    expect(removedIndex, 0);

    final clearButton = find.text(S.current.g_key_batch_clear_all);
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    expect(cleared, isTrue);

    final paymasterCard = find.byType(PaymasterOptionCard);
    await tester.ensureVisible(paymasterCard);
    await tester.tap(paymasterCard);
    expect(paymasterTapped, isTrue);
  });
}

Future<void> _pumpBody(
  WidgetTester tester, {
  required List<BatchOperation> operations,
  PaymasterOption selectedPaymaster = PaymasterOption.none,
  BigInt? estimatedTotalGas,
  String? estimateError,
  ValueChanged<int>? onRemoveOperation,
  VoidCallback? onClearAll,
  VoidCallback? onShowPaymaster,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapForTest(
      AABatchTransactionBody(
        operations: operations,
        selectedPaymaster: selectedPaymaster,
        isEstimating: false,
        isSending: false,
        estimatedTotalGas: estimatedTotalGas,
        estimateError: estimateError,
        formatGasCost: () => '0.0042 ETH',
        onShowTemplates: () {},
        onAddOperation: () {},
        onSaveTemplate: () {},
        onShowPaymaster: onShowPaymaster ?? () {},
        onSendBatch: () {},
        onRemoveOperation: onRemoveOperation ?? (_) {},
        onClearAll: onClearAll ?? () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}
