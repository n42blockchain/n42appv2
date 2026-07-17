import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QA automation quality gate', () {
    test(
      'integration tests contain no unconditional placeholder assertions',
      () {
        final files = _dartFilesUnder('integration_test');
        final violations = <String>[];
        final placeholder = RegExp(
          r'expect\s*\(\s*true\s*,\s*true\s*\)',
          multiLine: true,
        );

        for (final file in files) {
          if (placeholder.hasMatch(file.readAsStringSync())) {
            violations.add(file.path);
          }
        }

        expect(
          violations,
          isEmpty,
          reason:
              'Placeholder assertions make integration tests report false '
              'passes. Use a real app assertion or mark the case skipped with '
              'an explicit blocker.',
        );
      },
    );

    test(
      'the app integration smoke test launches the production entrypoint',
      () {
        final source = File(
          'integration_test/app_test.dart',
        ).readAsStringSync();

        expect(source, contains("package:n42_wallet/main.dart"));
        expect(source, contains('app.main();'));
        expect(source, contains("find.byType(MaterialApp)"));
        expect(source, contains('handleAppLifecycleStateChanged'));
      },
    );

    test('pending device cases are explicit skips with blockers', () {
      final source = File(
        'integration_test/flows/wallet_flow_test.dart',
      ).readAsStringSync();

      expect(source, contains(r'[BLOCKED: ${testCase.blocker}]'));
      expect(source, contains('skip: true'));
      expect(
        RegExp(
          r'^  _PendingDeviceCase\(',
          multiLine: true,
        ).allMatches(source).length,
        13,
      );
    });

    test('the QA master plan has unique case IDs and required coverage', () {
      final source = File('docs/QA_TEST_PLAN.md').readAsStringSync();
      final caseIdPattern = RegExp(
        r'^\| ([A-Z]+(?:-[A-Z]+)*-\d+) \|',
        multiLine: true,
      );
      final ids = caseIdPattern
          .allMatches(source)
          .map((match) => match.group(1)!)
          .toList(growable: false);
      final duplicates = <String>{};
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) {
          duplicates.add(id);
        }
      }

      expect(ids.length, greaterThanOrEqualTo(150));
      expect(duplicates, isEmpty, reason: 'Duplicate QA case IDs found.');
      expect(source, contains('## 8. Wallet 全量用例'));
      expect(source, contains('## 9. Chat 全量用例'));
      expect(source, contains('## 12. 权限专项矩阵'));
      expect(source, contains('## 17. 发布准入与签字'));
      expect(source, contains('13.60%'));
    });

    test('the automation runbook documents executable and honest gates', () {
      final source = File('docs/AUTOMATED_TESTING.md').readAsStringSync();

      expect(source, contains('./scripts/run_automated_tests.sh full'));
      expect(source, contains('flutter test --no-pub --coverage'));
      expect(source, contains('packages/n42_chat'));
      expect(source, contains('go test -count=1 ./...'));
      expect(source, contains('DEVICE_ID'));
      expect(source, contains('13.60%'));
      expect(source, contains('70%'));
      expect(source, contains('`SKIP`'));
      expect(source, contains('不计 Pass'));
    });

    test(
      'the full device flow performs real clicks and runtime-only login',
      () {
        final source = File(
          'integration_test/device_full_flow_test.dart',
        ).readAsStringSync();

        expect(source, contains("package:n42_wallet/main.dart"));
        expect(source, contains('app.main();'));
        expect(source, contains('tester.tap('));
        expect(source, contains('tester.enterText('));
        expect(
          source,
          contains("String.fromEnvironment('N42_E2E_CHAT_USERNAME')"),
        );
        expect(
          source,
          contains("String.fromEnvironment('N42_E2E_CHAT_PASSWORD')"),
        );
        expect(source, isNot(contains('skip: true')));
        expect(
          RegExp(r'DEVICE_STEP ').allMatches(source).length,
          greaterThanOrEqualTo(6),
        );

        final driver = File(
          'test_driver/integration_test.dart',
        ).readAsStringSync();
        expect(driver, contains('integrationDriver'));

        final script = File(
          'scripts/run_automated_tests.sh',
        ).readAsStringSync();
        expect(script, contains('PUBLISH_PORT'));
        expect(script, contains('flutter drive'));
        expect(script, contains('--publish-port'));
      },
    );

    test('WalletConnect lifecycle does not read ref during dispose', () {
      for (final path in <String>[
        'lib/features/wallet_connect/pages/wallet_connect_page.dart',
        'lib/features/wallet_connect/pages/wallet_connect_sheet.dart',
      ]) {
        final source = File(path).readAsStringSync();
        final disposeBody = RegExp(
          r'void dispose\(\)\s*\{([\s\S]*?)\n\s*\}',
        ).firstMatch(source)?.group(1);

        expect(disposeBody, isNotNull, reason: '$path has no dispose method');
        expect(
          disposeBody,
          isNot(contains('ref.')),
          reason: '$path must cache provider references before unmounting',
        );
      }
    });
  });
}

List<File> _dartFilesUnder(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('_test.dart'))
      .toList(growable: false);
}
