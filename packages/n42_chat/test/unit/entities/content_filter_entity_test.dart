import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/content_filter_entity.dart';

void main() {
  group('ContentFilterConfig.fromJson', () {
    test('ignores malformed list entries instead of throwing', () {
      final config = ContentFilterConfig.fromJson({
        'enabled': true,
        'forbidden_words': ['secret', 42, '  classified  ', null],
        'action': 'hide',
        'sensitive_data_types': ['email', 7, 'wallet_address', null],
      });

      expect(config.enabled, isTrue);
      expect(config.action, FilterAction.hide);
      expect(config.forbiddenWords, ['secret', 'classified']);
      expect(config.sensitiveDataTypes, [
        SensitiveDataType.email,
        SensitiveDataType.walletAddress,
      ]);
    });
  });
}
