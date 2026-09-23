import 'package:flutter_test/flutter_test.dart';
import 'package:n42_wallet/features/wallet/models/tokenview/parse_helpers.dart';

void main() {
  group('toIntSafe', () {
    test('converts integer, numeric, and string values', () {
      expect(toIntSafe(12), 12);
      expect(toIntSafe(12.9), 12);
      expect(toIntSafe('42'), 42);
    });

    test('returns null for null and invalid values', () {
      expect(toIntSafe(null), isNull);
      expect(toIntSafe('not an integer'), isNull);
    });
  });

  group('toDoubleSafe', () {
    test('converts double, numeric, and string values', () {
      expect(toDoubleSafe(12.5), 12.5);
      expect(toDoubleSafe(12), 12.0);
      expect(toDoubleSafe('0.125'), 0.125);
    });

    test('returns null for null and invalid values', () {
      expect(toDoubleSafe(null), isNull);
      expect(toDoubleSafe('not a number'), isNull);
    });
  });
}
