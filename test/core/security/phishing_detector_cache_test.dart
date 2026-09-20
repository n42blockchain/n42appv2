import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory directory;
  late SharedPreferences prefs;
  final detector = PhishingDetector.instance;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('n42-phishing-cache-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getApplicationSupportDirectory');
          return directory.path;
        });
    await File('${directory.path}/phishing_blocklist_v1.json').writeAsString(
      jsonEncode({
        'blacklist': ['cached-attack.example', 'overlap.example', 42, null],
        'whitelist': ['overlap.example', null, 42],
      }),
    );
    SharedPreferences.setMockInitialValues({
      'phishing_blocklist_v1': '{"blacklist":["legacy-only.example"]}',
      // A fresh cache keeps this test entirely offline.
      'phishing_blocklist_time_v1': DateTime.now().millisecondsSinceEpoch,
    });
    prefs = await SharedPreferences.getInstance();
    await detector.initialize(prefs);
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });

  test('migrates oversized preferences while loading the replacement file', () {
    expect(prefs.containsKey('phishing_blocklist_v1'), isFalse);
    expect(
      detector.checkUrl('https://cached-attack.example/login'),
      PhishingCheckResult.phishing,
    );
    expect(
      detector.checkUrl('https://deep.child.cached-attack.example'),
      PhishingCheckResult.phishing,
    );
    expect(
      detector.checkUrl('https://metamask-wallet.com'),
      PhishingCheckResult.phishing,
    );
  });

  test(
    'cached explicit whitelist overrides blocked domain and descendants',
    () {
      expect(
        detector.checkUrl('https://overlap.example'),
        PhishingCheckResult.safe,
      );
      expect(
        detector.checkUrl('https://app.overlap.example'),
        PhishingCheckResult.safe,
      );
    },
  );

  test(
    'session approval is restricted to the exact host and stays off disk',
    () async {
      const url = 'https://approved.cached-attack.example/path';
      final file = File('${directory.path}/phishing_blocklist_v1.json');
      final before = await file.readAsString();
      expect(detector.checkUrl(url), PhishingCheckResult.phishing);
      detector.allowForSession(url);
      expect(detector.checkUrl(url), PhishingCheckResult.safe);
      expect(
        detector.checkUrl('https://sibling.cached-attack.example'),
        PhishingCheckResult.phishing,
      );
      expect(
        detector.checkUrl('https://child.approved.cached-attack.example'),
        PhishingCheckResult.phishing,
      );
      expect(await file.readAsString(), before);
    },
  );

  test('malformed URLs do not throw or accidentally approve blocked hosts', () {
    expect(detector.checkUrl('https://[invalid'), PhishingCheckResult.safe);
    detector.allowForSession('https://[invalid');
    expect(
      detector.checkUrl('https://cached-attack.example'),
      PhishingCheckResult.phishing,
    );
  });
}
