import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/utils/content_filter_utils.dart';
import 'package:n42_chat/src/domain/entities/content_filter_entity.dart';

void main() {
  group('applyContentFilterToText', () {
    test('replaces forbidden keywords', () {
      const filter = ContentFilterConfig(
        enabled: true,
        forbiddenWords: ['secret'],
      );

      final result = applyContentFilterToText('this is secret data', filter);

      expect(result.matched, isTrue);
      expect(result.shouldHide, isFalse);
      expect(result.content, 'this is *** data');
    });

    test('detects and redacts email and wallet addresses', () {
      const filter = ContentFilterConfig(
        enabled: true,
        sensitiveDataTypes: [
          SensitiveDataType.email,
          SensitiveDataType.walletAddress,
        ],
      );

      final result = applyContentFilterToText(
        'reach me at alice@example.com or 0x1234567890abcdef1234567890abcdef12345678',
        filter,
      );

      expect(result.matched, isTrue);
      expect(result.content, 'reach me at *** or ***');
    });

    test('uses hide mode for matched credit card data', () {
      const filter = ContentFilterConfig(
        enabled: true,
        action: FilterAction.hide,
        sensitiveDataTypes: [SensitiveDataType.creditCard],
      );

      final result = applyContentFilterToText(
        'card 4111 1111 1111 1111',
        filter,
      );

      expect(result.matched, isTrue);
      expect(result.shouldHide, isTrue);
      expect(result.content, 'card 4111 1111 1111 1111');
    });

    test('ignores invalid credit-card-like numbers', () {
      const filter = ContentFilterConfig(
        enabled: true,
        sensitiveDataTypes: [SensitiveDataType.creditCard],
      );

      final result = applyContentFilterToText(
        'reference 1234 5678 9012 3456',
        filter,
      );

      expect(result.matched, isFalse);
      expect(result.content, 'reference 1234 5678 9012 3456');
    });
  });
}
