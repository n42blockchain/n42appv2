import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/gas/gas_tracker_page.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../../../helpers/widget_test_helpers.dart';

class _BlockedHttpClient implements HttpClient {
  @override
  bool Function(X509Certificate cert, String host, int port)?
  badCertificateCallback;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Network access blocked by gas card test');
}

class _BlockedNetworkOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _BlockedHttpClient();
}

void main() {
  testWidgets('gas cards remain readable when all live price requests fail', (
    tester,
  ) async {
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _BlockedNetworkOverrides();
    addTearDown(() => HttpOverrides.global = previousOverrides);

    await tester.pumpWidget(wrapForTest(const GasTrackerPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(GasTrackerPage));
    final localizations = S.of(context);
    expect(find.text(localizations.g_key_gas_realtime_prices), findsOneWidget);
    for (final network in [
      'Ethereum',
      'BNB Chain',
      'Polygon',
      'Arbitrum',
      'Optimism',
      'Avalanche',
    ]) {
      await tester.scrollUntilVisible(find.text(network), 300);
      expect(find.text(network), findsOneWidget);
      expect(find.text('...'), findsAtLeastNWidgets(1));
      expect(find.text(localizations.g_key_106), findsAtLeastNWidgets(1));
    }
    expect(find.text(localizations.g_key_gas_network_busy), findsNothing);
    expect(find.text(localizations.g_key_gas_network_normal), findsNothing);
    expect(find.text(localizations.g_key_gas_network_idle), findsNothing);
  });
}
