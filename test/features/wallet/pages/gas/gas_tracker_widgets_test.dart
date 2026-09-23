import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _BlockedHttpClient implements HttpClient {
  @override
  bool Function(X509Certificate cert, String host, int port)?
  badCertificateCallback;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Network access blocked by gas widget test');
}

class _BlockedNetworkOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _BlockedHttpClient();
}

void main() {
  testWidgets('gas alert sheet validates, saves, and restores a threshold', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _BlockedNetworkOverrides();
    addTearDown(() => HttpOverrides.global = previousOverrides);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapForTest(const GasTrackerPage()));
    await tester.pumpAndSettle();

    final pageContext = tester.element(find.byType(GasTrackerPage));
    final localization = S.of(pageContext);
    final ethereumAlert = find.byIcon(Icons.notifications_none).first;
    await tester.tap(ethereumAlert);
    await tester.pumpAndSettle();

    expect(
      find.text('Ethereum — ${localization.g_key_gas_alert}'),
      findsOneWidget,
    );
    final saveLabel = localization.g_key_gas_alert_save;
    await tester.ensureVisible(find.text(saveLabel));
    await tester.tap(find.text(saveLabel));
    await tester.pump();
    expect(find.text(localization.g_key_t_43), findsOneWidget);

    await tester.enterText(find.byType(TextField), '25');
    await tester.tap(find.text(localization.g_key_gas_alert_above));
    await tester.ensureVisible(find.text(saveLabel));
    await tester.tap(find.text(saveLabel));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    await tester.tap(find.byIcon(Icons.notifications_active));
    await tester.pumpAndSettle();
    expect(
      find.text('Ethereum — ${localization.g_key_gas_alert}'),
      findsOneWidget,
    );
    expect(find.text('25'), findsOneWidget);
  });
}
