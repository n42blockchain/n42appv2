import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

final _recipient = '0x${List.filled(20, 'b2').join()}';

Future<BatchTransferProvider> _mountPage(
  WidgetTester tester, {
  BigInt? balance,
}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final provider = BatchTransferProvider();
  addTearDown(provider.dispose);
  await tester.pumpWidget(
    wrapForTest(
      BatchTransferPage(
        chainSymbol: 'ETH',
        rpcUrl: 'https://rpc.invalid',
        chainId: 1,
        fromAddress: '0x${List.filled(20, 'a1').join()}',
        tokenAddress: '0x${List.filled(20, 'd4').join()}',
        tokenSymbol: 'USDC',
        decimals: 6,
        balance: balance ?? BigInt.from(10000000),
        batchTransferProvider: provider,
      ),
    ),
  );
  await tester.pump();
  return provider;
}

Future<void> _enterItem(
  WidgetTester tester, {
  required String amount,
  String memo = '',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), _recipient);
  await tester.enterText(fields.at(1), amount);
  await tester.enterText(fields.at(2), memo);
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rejects non-zero fractional digits beyond token precision', (
    tester,
  ) async {
    final provider = await _mountPage(tester);

    await _enterItem(tester, amount: '1.2345678');

    expect(provider.items, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '1.2345678',
    );
    expect(find.text('Invalid amount'), findsOneWidget);
  });

  testWidgets('accepts excess trailing zeros without changing exact amount', (
    tester,
  ) async {
    final provider = await _mountPage(tester);

    await _enterItem(tester, amount: '1.2300000', memo: '  invoice  ');

    expect(provider.items, hasLength(1));
    expect(provider.items.single.amount, BigInt.from(1230000));
    expect(provider.items.single.memo, 'invoice');
    expect(find.textContaining('1.23 USDC'), findsWidgets);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      isEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(2)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('balance guard keeps the recipient out of the transfer list', (
    tester,
  ) async {
    final provider = await _mountPage(tester, balance: BigInt.from(5000000));

    await _enterItem(tester, amount: '5.000001');

    expect(provider.items, isEmpty);
    expect(find.textContaining('USDC'), findsWidgets);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      _recipient,
    );
  });

  testWidgets('help action opens the batch import instructions', (
    tester,
  ) async {
    await _mountPage(tester);
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text(
        'address,amount,memo\n0x123...,1.5,Note 1\n0xabc...,2.0,Note 2',
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty list keeps continue disabled', (tester) async {
    await _mountPage(tester);
    final label = S
        .of(tester.element(find.byType(BatchTransferPage)))
        .g_key_batch_continue;
    final continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, label),
    );

    expect(continueButton.onPressed, isNull);
    expect(
      find.text(
        S
            .of(tester.element(find.byType(BatchTransferPage)))
            .g_key_batch_import_csv,
      ),
      findsOneWidget,
    );
  });
}
