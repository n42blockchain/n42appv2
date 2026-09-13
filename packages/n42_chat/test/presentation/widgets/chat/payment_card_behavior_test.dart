import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/presentation/widgets/chat/transfer_message_widget.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    Widget card, {
    String language = 'en',
    bool dark = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        theme: dark ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(body: Center(child: card)),
      ),
    );
    await tester.pumpAndSettle();
  }

  const statuses = {
    TransferMessageStatus.pending: ['Waiting to receive', 'Tap to claim'],
    TransferMessageStatus.completed: ['Has been received', 'Received Transfer'],
    TransferMessageStatus.failed: ['Transfer failed', 'Transfer failed'],
    TransferMessageStatus.cancelled: [
      'Transfer cancelled',
      'Transfer cancelled',
    ],
    TransferMessageStatus.expired: ['Expired', 'Expired'],
  };
  for (final entry in statuses.entries) {
    for (final self in [true, false]) {
      testWidgets(
        'transfer ${entry.key.name} shows correct perspective for self=$self and opens details',
        (tester) async {
          var opened = 0;
          await show(
            tester,
            TransferMessageWidget(
              amount: '12.50',
              currency: 'eth',
              status: entry.key,
              isSelf: self,
              note: 'Dinner',
              onTap: () => opened++,
            ),
          );
          expect(find.text('Ξ12.50'), findsOneWidget);
          expect(find.text(entry.value[self ? 0 : 1]), findsOneWidget);
          expect(find.text('Dinner'), findsOneWidget);
          await tester.tap(find.text('Ξ12.50'));
          expect(opened, 1);
          final semantics = tester
              .widgetList<Semantics>(find.byType(Semantics))
              .where((s) => s.properties.label?.contains('Ξ12.50') == true)
              .single;
          expect(semantics.properties.button, isTrue);
          expect(semantics.properties.label, contains('Dinner'));
        },
      );
    }
  }
  for (final currency in {
    'CNY': '¥',
    'BTC': '₿',
    'USDT': r'$',
    'OTHER': '',
  }.entries) {
    testWidgets(
      'payment currency ${currency.key} is represented without changing the amount',
      (tester) async {
        await show(
          tester,
          PaymentRequestMessageWidget(
            amount: '0.012345',
            currency: currency.key,
            status: PaymentRequestMessageStatus.pending,
            isSelf: false,
          ),
        );
        expect(find.text('${currency.value}0.012345'), findsOneWidget);
        final semantics = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((s) => s.properties.label?.contains('0.012345') == true)
            .single;
        expect(semantics.properties.button, isFalse);
      },
    );
  }
  for (final status in PaymentRequestMessageStatus.values) {
    testWidgets(
      'payment request ${status.name} opens details in either perspective',
      (tester) async {
        var taps = 0;
        for (final self in [true, false]) {
          await show(
            tester,
            PaymentRequestMessageWidget(
              amount: '2',
              currency: 'ETH',
              status: status,
              isSelf: self,
              onTap: () => taps++,
            ),
          );
          expect(
            find.text(
              S
                  .of(tester.element(find.byType(PaymentRequestMessageWidget)))!
                  .transferSendPaymentRequest,
            ),
            findsOneWidget,
          );
          await tester.tap(find.text('Ξ2'));
          expect(tester.takeException(), isNull);
        }
        expect(taps, 2);
      },
    );
  }
  for (final status in RedPacketStatus.values) {
    testWidgets(
      'red packet ${status.name} remains readable and opens details',
      (tester) async {
        var taps = 0;
        await show(
          tester,
          RedPacketMessageWidget(
            status: status,
            isSelf: false,
            onTap: () => taps++,
          ),
        );
        expect(find.text('N42 Red Packet'), findsOneWidget);
        await tester.tap(find.text('N42 Red Packet'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Arabic dark payment card keeps full amount and accessible long note',
    (tester) async {
      const note =
          'This long payment note remains accessible even when visually truncated';
      await show(
        tester,
        const TransferMessageWidget(
          amount: '123456789.12345678',
          currency: 'BTC',
          status: TransferMessageStatus.pending,
          isSelf: true,
          note: note,
        ),
        language: 'ar',
        dark: true,
      );
      expect(
        Directionality.of(tester.element(find.byType(TransferMessageWidget))),
        TextDirection.rtl,
      );
      expect(find.text('₿123456789.12345678'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text(note)).overflow,
        TextOverflow.ellipsis,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
