import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';

void main() {
  group('getSafeBrowserTxHashUrl', () {
    test('encodes transaction hashes before composing explorer urls', () {
      final url = getSafeBrowserTxHashUrl(
        'ETH',
        '0xabc?next=https://evil.example/#frag',
        isTest: false,
      );

      expect(url, isNotEmpty);
      expect(url, startsWith('https://'));
      expect(
        url,
        contains('0xabc%3Fnext%3Dhttps%3A%2F%2Fevil.example%2F%23frag'),
      );
      expect(url, isNot(contains('?next=')));
      expect(url, isNot(contains('#frag')));
    });

    test('keeps valid non-hex transaction ids usable', () {
      final url = getSafeBrowserTxHashUrl(
        'SOL',
        '5Kd3NBUAdUnh28WwTnT5s9XrJrM2Wm7wzJ9K4tqfN5Qm',
        isTest: false,
      );

      expect(url, isNotEmpty);
      expect(url, contains('5Kd3NBUAdUnh28WwTnT5s9XrJrM2Wm7wzJ9K4tqfN5Qm'));
    });

    test('returns empty string for missing payload fields', () {
      expect(getSafeBrowserTxHashUrl(null, '0xabc', isTest: false), isEmpty);
      expect(getSafeBrowserTxHashUrl('ETH', null, isTest: false), isEmpty);
      expect(getSafeBrowserTxHashUrl('', '0xabc', isTest: false), isEmpty);
    });
  });
}
