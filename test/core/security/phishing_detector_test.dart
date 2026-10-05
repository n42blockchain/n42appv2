import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PhishingDetector', () {
    late PhishingDetector detector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'phishing_blocklist_time_v1': DateTime.now().millisecondsSinceEpoch,
      });
      final prefs = await SharedPreferences.getInstance();
      detector = PhishingDetector.forTest();
      await detector.initialize(prefs);
    });

    test('fails open before initialization', () {
      final uninitializedDetector = PhishingDetector.forTest();

      expect(
        uninitializedDetector.checkUrl('https://metamask-login.com'),
        PhishingCheckResult.safe,
      );
    });

    group('checkUrl - seed blocklist', () {
      test('detects exact seed blocklist domain', () {
        expect(
          detector.checkUrl('https://metamask-login.com/phishing'),
          PhishingCheckResult.phishing,
        );
      });

      test('detects another seed blocklist domain', () {
        expect(
          detector.checkUrl('https://wallet-connect.live'),
          PhishingCheckResult.phishing,
        );
      });

      test('detects subdomain of blocklisted domain', () {
        expect(
          detector.checkUrl('https://app.metamask-login.com'),
          PhishingCheckResult.phishing,
        );
      });

      test('detects deep subdomain of blocklisted domain', () {
        expect(
          detector.checkUrl('https://a.b.c.metamask-login.com/path'),
          PhishingCheckResult.phishing,
        );
      });

      test('returns safe for legitimate domain', () {
        expect(
          detector.checkUrl('https://metamask.io'),
          PhishingCheckResult.safe,
        );
      });

      test('returns safe for google.com', () {
        expect(
          detector.checkUrl('https://google.com'),
          PhishingCheckResult.safe,
        );
      });

      test('returns safe for empty URL', () {
        expect(detector.checkUrl(''), PhishingCheckResult.safe);
      });

      test('returns safe for invalid URL', () {
        expect(detector.checkUrl('not a url at all'), PhishingCheckResult.safe);
      });

      test('returns safe for URL with no host', () {
        expect(
          detector.checkUrl('file:///local/path'),
          PhishingCheckResult.safe,
        );
      });

      test('handles URL with port number', () {
        expect(
          detector.checkUrl('https://metamask-login.com:8080/path'),
          PhishingCheckResult.phishing,
        );
      });

      test('handles URL with query params', () {
        expect(
          detector.checkUrl('https://metamask-login.com?redirect=true'),
          PhishingCheckResult.phishing,
        );
      });

      test('does not false-positive on partial domain match', () {
        expect(
          detector.checkUrl('https://metamask-login.company.com'),
          PhishingCheckResult.safe,
        );
      });
    });

    group('allowForSession', () {
      test('whitelists URL for session after allowForSession', () {
        const url = 'https://metamask-login.com/phishing-page';
        expect(detector.checkUrl(url), PhishingCheckResult.phishing);

        detector.allowForSession(url);

        expect(detector.checkUrl(url), PhishingCheckResult.safe);
      });

      test(
        'allowForSession with empty URL leaves blocklist behavior unchanged',
        () {
          const url = 'https://metamask-login.com';

          detector.allowForSession('');

          expect(detector.checkUrl(url), PhishingCheckResult.phishing);
        },
      );

      test(
        'allowForSession with invalid URL leaves blocklist behavior unchanged',
        () {
          const url = 'https://metamask-login.com';

          detector.allowForSession('not-a-url');

          expect(detector.checkUrl(url), PhishingCheckResult.phishing);
        },
      );
    });

    test('loads blocklist and whitelist from the cache file', () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'phishing-detector-test-',
      );
      addTearDown(() => temporaryDirectory.delete(recursive: true));
      final cacheFile = File('${temporaryDirectory.path}/blocklist.json');
      await cacheFile.writeAsString(
        jsonEncode({
          'blacklist': ['custom-phishing-domain.xyz'],
          'whitelist': ['trusted.example'],
        }),
      );

      SharedPreferences.setMockInitialValues({
        'phishing_blocklist_time_v1': DateTime.now().millisecondsSinceEpoch,
      });
      final prefs = await SharedPreferences.getInstance();
      final cachedDetector = PhishingDetector.forTest(
        cacheFileProvider: () async => cacheFile,
      );
      await cachedDetector.initialize(prefs);

      expect(
        cachedDetector.checkUrl('https://custom-phishing-domain.xyz'),
        PhishingCheckResult.phishing,
      );
      expect(
        cachedDetector.checkUrl('https://trusted.example'),
        PhishingCheckResult.safe,
      );
    });
  });
}
