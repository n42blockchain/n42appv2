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
      expect(source, contains('13.05%'));
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
