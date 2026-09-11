import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/security/dapp_security_service.dart';
import 'package:n42_wallet/core/security/phishing_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'phishing_blocklist_time_v1': DateTime.now().millisecondsSinceEpoch,
    });
    await PhishingDetector.instance.initialize(
      await SharedPreferences.getInstance(),
    );
  });

  test(
    'HTTPS verification cannot be reused for insecure HTTP on the same host',
    () {
      expect(
        DAppSecurityService.check('https://uniswap.org/swap').level,
        DAppSecurityLevel.verified,
      );
      final insecure = DAppSecurityService.check('http://uniswap.org/swap');
      expect(insecure.level, DAppSecurityLevel.caution);
      expect(insecure.reason, 'Not using HTTPS');
    },
  );

  test('visiting HTTP first does not poison later HTTPS verification', () {
    expect(
      DAppSecurityService.check('http://aave.com').level,
      DAppSecurityLevel.caution,
    );
    expect(
      DAppSecurityService.check('https://aave.com').level,
      DAppSecurityLevel.verified,
    );
  });

  test('phishing seed blocklist takes priority over HTTPS', () {
    final result = DAppSecurityService.check('https://metamask-login.com');
    expect(result.level, DAppSecurityLevel.blocked);
    expect(result.reason, 'Known phishing site');
    expect(
      DAppSecurityService.check('https://sub.metamask-login.com').level,
      DAppSecurityLevel.blocked,
    );
  });

  test('trusted-domain matching respects domain boundaries and case', () {
    expect(
      DAppSecurityService.check('https://APP.UNISWAP.ORG').level,
      DAppSecurityLevel.verified,
    );
    expect(
      DAppSecurityService.check('https://app.uniswap.org/path?q=1').level,
      DAppSecurityLevel.verified,
    );
    for (final url in [
      'https://uniswap.org.attacker.test',
      'https://eviluniswap.org',
    ]) {
      expect(
        DAppSecurityService.check(url).level,
        isNot(DAppSecurityLevel.verified),
      );
    }
  });

  test('invalid URLs and suspicious domains retain a caution reason', () {
    for (final url in ['', 'not-a-url', 'https://[']) {
      expect(DAppSecurityService.check(url).reason, 'Invalid URL');
    }
    for (final url in [
      'https://claim.example.test',
      'https://example.click',
      'https://wallet.example.test',
    ]) {
      final result = DAppSecurityService.check(url);
      expect(result.level, DAppSecurityLevel.caution);
      expect(result.reason, 'Suspicious domain name');
    }
    expect(
      DAppSecurityService.check('https://example.org').level,
      DAppSecurityLevel.safe,
    );
  });

  test(
    'cache capacity eviction preserves subsequent domain classification',
    () {
      for (var i = 0; i < 205; i++) {
        expect(
          DAppSecurityService.check('https://site-$i.example.test').level,
          DAppSecurityLevel.safe,
        );
      }
      expect(
        DAppSecurityService.check('https://uniswap.org').level,
        DAppSecurityLevel.verified,
      );
      expect(
        DAppSecurityService.check('http://uniswap.org').level,
        DAppSecurityLevel.caution,
      );
    },
  );

  test(
    'permission history loads persisted entries, ignores reads and isolates origins',
    () async {
      SharedPreferences.setMockInitialValues({'dapp_perms_v1': '{broken'});
      expect(await DAppPermissionsTracker.getAll(), isEmpty);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'dapp_perms_v1',
        jsonEncode({
          'https://first.test': ['eth_requestAccounts'],
        }),
      );
      expect(await DAppPermissionsTracker.getForOrigin('https://first.test'), [
        'eth_requestAccounts',
      ]);
      await DAppPermissionsTracker.record('', 'personal_sign');
      await DAppPermissionsTracker.record(
        'https://second.test',
        'eth_blockNumber',
      );
      expect(await DAppPermissionsTracker.getForOrigin(''), isEmpty);
      expect(
        await DAppPermissionsTracker.getForOrigin('https://second.test'),
        isEmpty,
      );
      await DAppPermissionsTracker.record(
        'https://second.test',
        'personal_sign',
      );
      await DAppPermissionsTracker.record(
        'https://second.test',
        'eth_sendTransaction',
      );
      await DAppPermissionsTracker.record(
        'https://second.test',
        'personal_sign',
      );
      final methods = await DAppPermissionsTracker.getForOrigin(
        'https://second.test',
      );
      expect(methods, ['personal_sign', 'eth_sendTransaction']);
      expect(() => methods.add('eth_sign'), throwsUnsupportedError);
      expect(jsonDecode(prefs.getString('dapp_perms_v1')!), {
        'https://first.test': ['eth_requestAccounts'],
        'https://second.test': ['personal_sign', 'eth_sendTransaction'],
      });
      await DAppPermissionsTracker.clearForOrigin('https://second.test');
      expect(
        await DAppPermissionsTracker.getForOrigin('https://second.test'),
        isEmpty,
      );
      expect(await DAppPermissionsTracker.getForOrigin('https://first.test'), [
        'eth_requestAccounts',
      ]);
    },
  );
}
