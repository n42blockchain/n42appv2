import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporary;
  late File capturedArguments;
  late Map<String, String> environment;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('n42-device-runner-');
    capturedArguments = File('${temporary.path}/arguments');
    final flutter = File('${temporary.path}/flutter');
    await flutter.writeAsString(
      '#!/bin/bash\nprintf "%s\\n" "\$@" > "\$N42_CAPTURE_ARGUMENTS"\n',
    );
    await Process.run('chmod', ['700', flutter.path]);
    environment = {
      'PATH': '${temporary.path}:${Platform.environment['PATH'] ?? ''}',
      'FLUTTER_BIN': flutter.path,
      'N42_CAPTURE_ARGUMENTS': capturedArguments.path,
    };
  });

  tearDown(() async => temporary.delete(recursive: true));

  test(
    'Chat device runner preserves the app and forwards each argument',
    () async {
      final result = await Process.run('bash', [
        'scripts/run_chat_device_acceptance.sh',
        'device-fixture',
        'http://127.0.0.1:12345/fixture=/',
        '--profile',
        '--dart-define=LABEL=two words',
      ], environment: environment);

      expect(result.exitCode, 0, reason: '${result.stderr}');
      final args = await capturedArguments.readAsLines();
      expect(
        args,
        contains('--use-existing-app=http://127.0.0.1:12345/fixture=/'),
      );
      expect(args.first, 'drive');
      expect(args.last, '--keep-app-running');
      expect(args[args.indexOf('-d') + 1], 'device-fixture');
      expect(args, contains('--dart-define=LABEL=two words'));
    },
  );

  test(
    'Chat runner rejects removal and a missing device before Flutter starts',
    () async {
      for (final arguments in <List<String>>[
        [],
        ['device-fixture'],
        ['device-fixture', '--profile'],
        ['device-fixture', 'http://127.0.0.1:12345/', '--no-keep-app-running'],
        [
          'device-fixture',
          'http://127.0.0.1:12345/',
          '--keep-app-running=false',
        ],
        [
          'device-fixture',
          'http://127.0.0.1:12345/',
          '--use-existing-app=http://other/',
        ],
      ]) {
        final result = await Process.run('bash', [
          'scripts/run_chat_device_acceptance.sh',
          ...arguments,
        ], environment: environment);
        expect(result.exitCode, 2);
        expect(await capturedArguments.exists(), isFalse);
      }
    },
  );

  test(
    'full-flow drive path also preserves the installed application',
    () async {
      final result = await Process.run(
        'bash',
        ['scripts/run_automated_tests.sh', 'device'],
        environment: {
          ...environment,
          'DEVICE_ID': 'device-fixture',
          'PUBLISH_PORT': '1',
          'DEVICE_VM_SERVICE_URL': 'http://127.0.0.1:12345/fixture=/',
          'N42_E2E_CHAT_USERNAME': 'fixture-user',
          'N42_E2E_CHAT_PASSWORD': 'fixture-only',
        },
      );

      expect(result.exitCode, 0, reason: '${result.stderr}');
      final args = await capturedArguments.readAsLines();
      expect(args.first, 'drive');
      expect(args, contains('--keep-app-running'));
      expect(
        args,
        contains('--use-existing-app=http://127.0.0.1:12345/fixture=/'),
      );
      expect(args, isNot(contains('--no-keep-app-running')));
    },
  );
  test(
    'full-flow drive refuses to install when no existing connection is supplied',
    () async {
      final result = await Process.run(
        'bash',
        ['scripts/run_automated_tests.sh', 'device'],
        environment: {
          ...environment,
          'DEVICE_ID': 'device-fixture',
          'PUBLISH_PORT': '1',
          'DEVICE_VM_SERVICE_URL': '',
          'N42_E2E_CHAT_USERNAME': 'fixture-user',
          'N42_E2E_CHAT_PASSWORD': 'fixture-only',
        },
      );
      expect(result.exitCode, 2);
      expect(await capturedArguments.exists(), isFalse);
    },
  );
}
