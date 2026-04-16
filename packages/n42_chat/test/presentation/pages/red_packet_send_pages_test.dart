import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/pages/red_packet/send_red_packet_page.dart';
import 'package:n42_chat/src/presentation/pages/red_packet/send_transfer_page.dart';
import 'package:n42_chat/src/presentation/widgets/common/slide_to_pay_button.dart';

Widget _buildHarness(Widget page) {
  return MaterialApp(
    localizationsDelegates: S.localizationsDelegates,
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => page),
            );
          },
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('failed red packet send keeps form open', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        SendRedPacketPage(
          receiverName: 'Alice',
          onSend: (amount, token, greeting, count, isLucky) async => false,
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '12.34');
    await tester.pump();
    tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed!.call();
    await tester.pump();

    expect(find.byType(SendRedPacketPage), findsOneWidget);

    final amountField = tester.widget<TextField>(find.byType(TextField).first);
    expect(amountField.controller?.text, '12.34');
  });

  testWidgets('successful red packet send closes page', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        SendRedPacketPage(
          receiverName: 'Alice',
          onSend: (amount, token, greeting, count, isLucky) async => true,
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '12.34');
    await tester.pump();
    tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.byType(SendRedPacketPage), findsNothing);
  });

  testWidgets('failed transfer send keeps form open and resets slider', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildHarness(
        SendTransferPage(
          receiverName: 'Alice',
          onSend: (amount, token, memo) async => false,
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '8.88');

    final slideButton = tester.widget<SlideToPayButton>(
      find.byType(SlideToPayButton),
    );
    slideButton.onConfirmed();
    await tester.pump();

    expect(find.byType(SendTransferPage), findsOneWidget);

    final amountField = tester.widget<TextField>(find.byType(TextField).first);
    expect(amountField.controller?.text, '8.88');
  });

  testWidgets('successful transfer send closes page', (tester) async {
    await tester.pumpWidget(
      _buildHarness(
        SendTransferPage(
          receiverName: 'Alice',
          onSend: (amount, token, memo) async => true,
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '8.88');

    final slideButton = tester.widget<SlideToPayButton>(
      find.byType(SlideToPayButton),
    );
    slideButton.onConfirmed();
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.byType(SendTransferPage), findsNothing);
  });
}
