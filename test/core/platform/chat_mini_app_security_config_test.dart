import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/core/platform/chat_mini_app_security_config.dart';

void main() {
  test('empty deployment config preserves restricted built-in mode', () {
    final config = resolveChatMiniAppSecurity(
      policyUrl: '',
      policyKeys: '',
      launchKeys: '',
      upgradeUrl: '',
    );
    expect(config.policyUrl, isNull);
    expect(config.launchPublicKeys, isEmpty);
  });
  test('invalid public keys never downgrade configured managed mode', () {
    for (final keys in ['not json', '{"test":"short"}', '[]']) {
      final config = resolveChatMiniAppSecurity(
        policyUrl: 'https://config.example.test/policy',
        policyKeys: keys,
      );
      expect(config.policyUrl, 'https://config.example.test/policy');
      expect(config.policyPublicKeys, isEmpty);
    }
  });
  test('public keys, audience and upgrade destination reach plugin config', () {
    final key = base64Url.encode(List<int>.filled(32, 1));
    final config = resolveChatMiniAppSecurity(
      policyKeys: jsonEncode({'p': key}),
      launchKeys: jsonEncode({'l': key}),
      audience: 'staging',
      upgradeUrl: 'https://example.test/update',
    );
    expect(config.policyPublicKeys['p'], key);
    expect(config.launchPublicKeys['l'], key);
    expect(config.audience, 'staging');
    expect(config.upgradeUrl, 'https://example.test/update');
  });
}
