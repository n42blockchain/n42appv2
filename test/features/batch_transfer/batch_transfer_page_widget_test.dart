import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/batch_transfer/batch_transfer_page.dart';
import 'package:n42_wallet/features/wallet/provider/batch_transfer_provider.dart';
import 'package:n42_wallet/generated/l10n.dart';

const _recipient = '0x1234567890abcdef1234567890abcdef12345678';

Widget _app(Widget child) => ProviderScope(
  child: ScreenUtilInit(
    designSize: const Size(750, 1334),
    builder: (context, child) => MaterialApp(
      theme: ThemeData.light(),
      localizationsDelegates: const [S.delegate],
      supportedLocales: S.delegate.supportedLocales,
      home: child,
    ),
    child: child,
  ),
);

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<BatchTransferProvider> _pumpPage(WidgetTester tester) async {
  final provider = BatchTransferProvider();
  addTearDown(provider.dispose);
  await tester.pumpWidget(
    _app(
      BatchTransferPage(
        chainSymbol: 'ETH',
        rpcUrl: 'https://offline.invalid/rpc',
        chainId: 1,
        fromAddress: '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        tokenSymbol: 'USDC',
        decimals: 2,
        balance: BigInt.from(100000),
        batchTransferProvider: provider,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  testWidgets('amount with excess precision is rejected without truncation', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final provider = await _pumpPage(tester);

    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '1.234');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(provider.items, isEmpty);
    expect(find.text('Invalid amount'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding a recipient parses units and updates the summary', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final provider = await _pumpPage(tester);

    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '12.34');
    await tester.enterText(find.byType(TextField).at(2), 'Invoice 7');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(provider.recipientCount, 1);
    expect(provider.totalAmount, BigInt.from(1234));
    expect(provider.items.single.memo, 'Invoice 7');
    expect(find.text('Invoice 7'), findsOneWidget);
    expect(find.text('12.34 USDC'), findsNWidgets(2));
    expect(find.text('1'), findsNWidgets(2));
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      '',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('recipient amount above available balance is rejected', (
    tester,
  ) async {
    _setPhoneViewport(tester);
    final provider = await _pumpPage(tester);

    await tester.enterText(find.byType(TextField).at(0), _recipient);
    await tester.enterText(find.byType(TextField).at(1), '1001');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(provider.items, isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
