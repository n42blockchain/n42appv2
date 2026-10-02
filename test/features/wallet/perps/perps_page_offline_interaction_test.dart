import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/perps/perps_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected Hyperliquid network request');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  late HttpOverrides? previousOverrides;

  setUp(() {
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _FailFastHttpOverrides();
  });

  tearDown(() => HttpOverrides.global = previousOverrides);

  testWidgets('offline load keeps all read-only tabs usable and refreshable', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(const PerpsPage(walletAddress: '0xsynthetic')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Tab), findsNWidgets(3));
    expect(find.textContaining('read-only'), findsNothing);
    expect(find.text(S.current.g_key_perps_read_only), findsOneWidget);

    await tester.tap(find.byType(Tab).at(1));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_ui_no_positions), findsOneWidget);

    await tester.tap(find.byType(Tab).at(2));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_ui_no_orders), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();
    expect(find.text(S.current.g_ui_no_orders), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
