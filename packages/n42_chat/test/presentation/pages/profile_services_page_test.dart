import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/l10n/app_localizations.dart';
import 'package:n42_chat/src/n42_chat.dart';
import 'package:n42_chat/src/presentation/pages/profile/orders_and_cards_page.dart';
import 'package:n42_chat/src/presentation/pages/profile/services_page.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: const Locale('en'),
  home: child,
);

void main() {
  testWidgets('Me services exposes functional service entry points', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ServicesPage()));
    await tester.pumpAndSettle();

    expect(find.text('N42 Bean'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('Red Packet'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Card Pack'), findsOneWidget);

    await tester.tap(find.text('Red Packet'));
    await tester.pumpAndSettle();
    expect(find.text('Select Contact'), findsOneWidget);
    expect(find.text('No contacts found'), findsOneWidget);
  });

  testWidgets(
    'orders hub loads activity and card pack has an honest fallback',
    (tester) async {
      N42Chat.setOpenCardPackHandler(null);
      await tester.pumpWidget(_app(const OrdersAndCardsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Orders & Cards'), findsOneWidget);
      expect(find.text('No orders'), findsOneWidget);

      await tester.tap(find.text('Card Pack'));
      await tester.pumpAndSettle();
      expect(find.text('Cards and passes'), findsOneWidget);
      await tester.tap(find.text('Open Card Pack'));
      await tester.pump();
      expect(find.text('Card Pack requires the main app'), findsOneWidget);
    },
  );
}
