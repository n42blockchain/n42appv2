import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n42_wallet/features/payments/presentation/local_payment_lab_host.dart';
import 'package:n42_wallet/features/payments/presentation/local_payment_lab_page.dart';
import 'package:n42_wallet/features/payments/presentation/local_packet_lab_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('lab entry honors the compile-time opt-in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocalPaymentLabHost()));
    if (const bool.fromEnvironment('N42_LOCAL_PAYMENT_LAB')) {
      expect(find.byType(LocalPaymentLabPage), findsOneWidget);
    } else {
      expect(find.byType(LocalPaymentLabPage), findsNothing);
      expect(
        find.textContaining('Local payment lab is disabled'),
        findsOneWidget,
      );
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'packet lab uses the same explicit opt-in with an isolated host',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LocalPaymentLabHost(redPackets: true)),
      );
      expect(find.byType(LocalPaymentLabPage), findsNothing);
      if (const bool.fromEnvironment('N42_LOCAL_PAYMENT_LAB')) {
        expect(find.byType(LocalPacketLabPage), findsOneWidget);
      } else {
        expect(find.byType(LocalPacketLabPage), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'changing host mode keeps initialized dependencies on same state',
    (tester) async {
      for (final packet in [true, false, true, false]) {
        await tester.pumpWidget(
          MaterialApp(home: LocalPaymentLabHost(redPackets: packet)),
        );
        await tester.pumpAndSettle();
        if (LocalPaymentLabHost.isEnabled) {
          expect(
            find.byType(packet ? LocalPacketLabPage : LocalPaymentLabPage),
            findsOneWidget,
          );
        } else {
          expect(
            find.textContaining('Local payment lab is disabled'),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
}
