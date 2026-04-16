import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/matrix_uia_utils.dart';

void main() {
  group('matrixUiaSupportsPassword', () {
    test('returns true when any flow contains password stage', () {
      const rawBody = '''
      {
        "flows": [
          {"stages": ["m.login.sso"]},
          {"stages": ["m.login.password"]}
        ]
      }
      ''';

      expect(matrixUiaSupportsPassword(rawBody), isTrue);
    });

    test('returns false when password stage is absent', () {
      const rawBody = '''
      {
        "flows": [
          {"stages": ["m.login.sso"]}
        ]
      }
      ''';

      expect(matrixUiaSupportsPassword(rawBody), isFalse);
    });

    test('returns false for invalid payloads', () {
      expect(matrixUiaSupportsPassword(null), isFalse);
      expect(matrixUiaSupportsPassword('not-json'), isFalse);
      expect(matrixUiaSupportsPassword('{}'), isFalse);
    });
  });
}
