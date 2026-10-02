import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/ens/ens_home_page.dart';

import '../../../helpers/widget_test_helpers.dart';

class _RejectingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('Unexpected HTTP in ENS home test');
}

class _FailFastHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _RejectingHttpClient();
}

void main() {
  const invalidAddress = 'not-an-evm-address';

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTest(const EnsHomePage(walletAddress: invalidAddress)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty state and disables ENS actions without wallet', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('ENS'), findsOneWidget);

    final searchAction = tester.widget<GestureDetector>(
      find
          .ancestor(
            of: find.byIcon(Icons.search_rounded),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    searchAction.onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    final messenger = ScaffoldMessenger.of(
      tester.element(find.byType(EnsHomePage)),
    );
    messenger.hideCurrentSnackBar();
    await tester.pumpAndSettle();
    final renewAction = tester.widget<GestureDetector>(
      find
          .ancestor(
            of: find.byIcon(Icons.autorenew_rounded),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    renewAction.onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('chain selector updates the selected chain chip', (tester) async {
    await pumpHome(tester);

    final nonDefault = EnsChainConfig.supportedChains.firstWhere(
      (chain) => chain.id != EnsChainConfig.defaultChain.id,
    );
    await tester.ensureVisible(find.text(nonDefault.name));
    await tester.tap(find.text(nonDefault.name));
    await tester.pumpAndSettle();

    expect(find.text(nonDefault.suffix), findsOneWidget);
  });

  testWidgets(
    'empty-state and floating search actions stay on home and show guidance',
    (tester) async {
      await pumpHome(tester);

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.domain_rounded), findsOneWidget);
      await tester.tap(find.text('Search & Register'));
      await tester.pumpAndSettle();
      expect(find.text('Chain not supported'), findsWidgets);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(EnsHomePage), findsOneWidget);

      final searchFab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      searchFab.onPressed!();
      await tester.pumpAndSettle();
      expect(find.text('Chain not supported'), findsWidgets);
      expect(find.byType(EnsHomePage), findsOneWidget);
    },
  );

  testWidgets('valid wallet shows owned-name error and lets the user retry', (
    tester,
  ) async {
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = _FailFastHttpOverrides();
    try {
      await tester.pumpWidget(
        wrapForTest(
          const EnsHomePage(
            walletAddress: '0x0000000000000000000000000000000000000001',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      HttpOverrides.global = previousOverrides;
    }
  });
}
