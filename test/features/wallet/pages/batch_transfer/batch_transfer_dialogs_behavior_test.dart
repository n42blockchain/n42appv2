import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/batch_transfer_model.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_dialogs.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _PreviewProvider extends BatchTransferProvider {
  _PreviewProvider({this._txHash}) {
    initialize(
      chainSymbol: 'ETH',
      rpcUrl: 'https://rpc.invalid',
      chainId: 1,
      fromAddress: '0x${'a1' * 20}',
      tokenAddress: '0x${'d4' * 20}',
      tokenSymbol: 'USDC',
      decimals: 6,
    );
    addItem('0x${'b2' * 20}', BigInt.from(1500000), memo: 'invoice');
    addItem('0x${'c3' * 20}', BigInt.from(2000000));
  }

  final String? _txHash;

  @override
  String? get txHash => _txHash;

  @override
  BatchGasEstimate? get gasEstimate => BatchGasEstimate(
    gasLimit: BigInt.from(150000),
    gasPrice: BigInt.from(5000000000),
    totalFee: BigInt.from(750000000000000),
    isEip1559: false,
  );
}

Future<void> _openConfirmDialog(
  WidgetTester tester,
  _PreviewProvider provider,
  void Function(bool?) onResult,
) async {
  await tester.pumpWidget(
    wrapForTest(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const ValueKey('open_confirm'),
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (_) => BatchConfirmDialog(
                    provider: provider,
                    tokenSymbol: 'USDC',
                    formatGasFee: (fee) => '$fee wei',
                  ),
                );
                onResult(result);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open_confirm')));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('confirmation lists recipients, total, fee and cancel result', (
    tester,
  ) async {
    final provider = _PreviewProvider();
    addTearDown(provider.dispose);
    bool? result;

    await _openConfirmDialog(tester, provider, (value) => result = value);

    final dialog = find.byType(AlertDialog);
    expect(find.textContaining('2'), findsWidgets);
    expect(find.textContaining('3.5 USDC'), findsOneWidget);
    expect(find.textContaining('750000000000000 wei'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber), findsOneWidget);

    await tester.tap(
      find.descendant(of: dialog, matching: find.byType(TextButton)),
    );
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('confirmation returns true only after the confirm action', (
    tester,
  ) async {
    final provider = _PreviewProvider();
    addTearDown(provider.dispose);
    bool? result;

    await _openConfirmDialog(tester, provider, (value) => result = value);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(ElevatedButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('help dialog shows CSV format and closes after acknowledgement', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('open_help'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const BatchHelpDialog(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open_help')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'address,amount,memo\n0x123...,1.5,Note 1\n0xabc...,2.0,Note 2',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        S
            .of(tester.element(find.byType(AlertDialog)))
            .g_key_batch_memo_optional,
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('result sheet exports and closes with a transaction summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = _PreviewProvider(txHash: '0x${'ab' * 32}');
    addTearDown(provider.dispose);
    var exportCount = 0;

    await tester.pumpWidget(
      wrapForTest(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('open_result'),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BatchResultSheet(
                    provider: provider,
                    tokenSymbol: 'USDC',
                    onExport: (_) async => exportCount++,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open_result')));
    await tester.pumpAndSettle();

    expect(find.text('3.5 USDC'), findsOneWidget);
    expect(find.text('TxHash:'), findsOneWidget);
    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.file_download_outlined));
    await tester.pumpAndSettle();
    expect(exportCount, 1);

    final doneLabel = S
        .of(tester.element(find.byType(BatchResultSheet)))
        .g_key_batch_done;
    await tester.tap(find.text(doneLabel));
    await tester.pumpAndSettle();

    expect(find.byType(BatchResultSheet), findsNothing);
  });
}
