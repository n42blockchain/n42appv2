import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/pages/wallet_manage/keystore/keystore_export_utils.dart';

void main() {
  group('normalizeExportableKeystore', () {
    test('trims valid keystore payloads', () {
      expect(normalizeExportableKeystore('  {"crypto":{}}  '), '{"crypto":{}}');
    });

    test('rejects empty keystore payloads', () {
      expect(() => normalizeExportableKeystore('   '), throwsFormatException);
    });
  });

  group('decodeExportablePrivateKey', () {
    test('decodes base64 private keys to hex', () {
      final encoded = base64Encode([0x12, 0x34, 0xab, 0xcd]);
      expect(decodeExportablePrivateKey(encoded), '1234abcd');
    });

    test('rejects empty or invalid payloads', () {
      expect(() => decodeExportablePrivateKey(''), throwsFormatException);
      expect(() => decodeExportablePrivateKey('%%%'), throwsFormatException);
    });
  });
}
