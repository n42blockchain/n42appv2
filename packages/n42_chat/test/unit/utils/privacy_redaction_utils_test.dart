import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/privacy_redaction_utils.dart';

void main() {
  group('maskPhoneNumber', () {
    test('returns null for null and empty values', () {
      expect(maskPhoneNumber(null), isNull);
      expect(maskPhoneNumber('  '), isNull);
    });

    test('masks middle digits while preserving formatting', () {
      expect(maskPhoneNumber('+1 647-123-4567'), '+1 647-***-**67');
    });

    test('masks short numeric strings conservatively', () {
      expect(maskPhoneNumber('1234'), '1**4');
    });

    test('returns original string when no digits exist', () {
      expect(maskPhoneNumber('n/a'), 'n/a');
    });
  });
}
