// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:n42_wallet/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GEN-01 GEN-03 launches the real app and survives lifecycle changes',
    (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await _pumpUntilFound(tester, find.byType(MaterialApp));
      stopwatch.stop();

      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 30)));
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Navigator), findsWidgets);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'N42Wallet');
      expect(
        materialApp.routes?.keys,
        containsAll(<String>[
          '/HomePage',
          '/CreateOne',
          '/ImportOne',
          '/ImportPrivatekey',
          '/ImportCloudBackup',
          '/securitySetting',
        ]),
      );
      expect(tester.takeException(), isNull);

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(milliseconds: 500));
      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Navigator), findsWidgets);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final stopwatch = Stopwatch()..start();
  while (finder.evaluate().isEmpty && stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  expect(finder, findsOneWidget);
}
