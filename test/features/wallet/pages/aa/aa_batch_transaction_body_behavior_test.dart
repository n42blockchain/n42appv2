import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/aa/aa_batch_transaction_body.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/batch_operation_item.dart';
import 'package:n42_wallet/features/wallet/widgets/aa/paymaster_option_card.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

const _address = '0x1111111111111111111111111111111111111111';

BatchOperation _transfer() => BatchOperation(
  type: BatchOperationType.transfer,
  targetAddress: _address,
  tokenSymbol: 'ETH',
  amount: BigInt.from(1250000000000000000),
  decimals: 18,
  description: 'Treasury payment',
);

Widget _body({
  List<BatchOperation> operations = const [],
  PaymasterOption selectedPaymaster = PaymasterOption.none,
  bool isEstimating = false,
  bool isSending = false,
  BigInt? estimatedTotalGas,
  String? estimateError,
  String gasCost = '0.0042 ETH',
  VoidCallback? onShowTemplates,
  VoidCallback? onAddOperation,
  VoidCallback? onSaveTemplate,
  VoidCallback? onShowPaymaster,
  VoidCallback? onSendBatch,
  void Function(int index)? onRemoveOperation,
  VoidCallback? onClearAll,
}) => AABatchTransactionBody(
  operations: operations,
  selectedPaymaster: selectedPaymaster,
  isEstimating: isEstimating,
  isSending: isSending,
  estimatedTotalGas: estimatedTotalGas,
  estimateError: estimateError,
  formatGasCost: () => gasCost,
  onShowTemplates: onShowTemplates ?? () {},
  onAddOperation: onAddOperation ?? () {},
  onSaveTemplate: onSaveTemplate ?? () {},
  onShowPaymaster: onShowPaymaster ?? () {},
  onSendBatch: onSendBatch ?? () {},
  onRemoveOperation: onRemoveOperation ?? (_) {},
  onClearAll: onClearAll ?? () {},
);

void main() {
  testWidgets('empty batch offers templates and adding its first operation', (
    tester,
  ) async {
    _useViewport(tester);
    var templatesOpened = false;
    var addPressed = false;
    await tester.pumpWidget(
      wrapForTest(
        _body(
          onShowTemplates: () => templatesOpened = true,
          onAddOperation: () => addPressed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(AABatchTransactionBody)));

    expect(find.text(l10n.g_key_aa_no_operations), findsOneWidget);
    expect(find.text(l10n.g_key_aa_add_first_operation), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    await tester.tap(find.byIcon(Icons.bookmarks_outlined));
    await tester.ensureVisible(find.text(l10n.g_key_aa_add_operation));
    await tester.tap(find.text(l10n.g_key_aa_add_operation));
    expect(templatesOpened, isTrue);
    expect(addPressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('operations expose edit-list actions, gas error, and submit', (
    tester,
  ) async {
    _useViewport(tester);
    final removed = <int>[];
    var cleared = false;
    var saved = false;
    var paymasterOpened = false;
    var sent = false;
    await tester.pumpWidget(
      wrapForTest(
        _body(
          operations: [_transfer()],
          estimateError: 'Fee service unavailable',
          onRemoveOperation: removed.add,
          onClearAll: () => cleared = true,
          onSaveTemplate: () => saved = true,
          onShowPaymaster: () => paymasterOpened = true,
          onSendBatch: () => sent = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(AABatchTransactionBody)));

    expect(find.text('1.25 ETH'), findsOneWidget);
    expect(find.text('Treasury payment'), findsOneWidget);
    expect(find.text('Fee service unavailable'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.delete_outline));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.ensureVisible(find.text(l10n.g_key_batch_clear_all));
    await tester.tap(find.text(l10n.g_key_batch_clear_all));
    await tester.ensureVisible(find.text(l10n.g_key_aa_batch_save_template));
    await tester.tap(find.text(l10n.g_key_aa_batch_save_template));
    await tester.ensureVisible(find.byType(PaymasterOptionCard));
    await tester.tap(find.byType(PaymasterOptionCard));
    await tester.tap(find.byType(ElevatedButton));

    expect(removed, [0]);
    expect(cleared, isTrue);
    expect(saved, isTrue);
    expect(paymasterOpened, isTrue);
    expect(sent, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sponsored gas shows the free state and estimated savings', (
    tester,
  ) async {
    _useViewport(tester);
    var sent = false;
    await tester.pumpWidget(
      wrapForTest(
        _body(
          operations: [_transfer()],
          selectedPaymaster: PaymasterOption.sponsored,
          estimatedTotalGas: BigInt.from(21000),
          gasCost: '0.0042 ETH',
          onSendBatch: () => sent = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = S.of(tester.element(find.byType(AABatchTransactionBody)));

    expect(find.text(l10n.g_key_aa_free), findsWidgets);
    expect(find.textContaining('0.0042 ETH'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(sent, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('estimating and sending states disable duplicate submission', (
    tester,
  ) async {
    _useViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        _body(operations: [_transfer()], isEstimating: true, isSending: true),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(
      find.text(
        S
            .of(tester.element(find.byType(AABatchTransactionBody)))
            .g_key_aa_batch_submitting,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

void _useViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
