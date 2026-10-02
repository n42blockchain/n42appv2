import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/data/datasources/matrix/message/matrix_text_message_content.dart'
    as matrix_text;
import 'package:unorm_dart/unorm_dart.dart' as unorm;

void main() {
  group('unorm_dart compatibility', () {
    test('keeps canonical and compatibility normalization behavior', () {
      const decomposed = 'Cafe\u0301';

      expect(unorm.nfc(decomposed), 'Café');
      expect(unorm.nfd('Café'), decomposed);
      expect(unorm.nfkc('\u2460'), '1');
      expect(unorm.nfkd('\u2460'), '1');
    });

    test('keeps pinned Chat normalization stable for text identity', () {
      const decomposed = 'Cafe\u0301';
      const composed = 'Café';

      final normalizedDecomposed = matrix_text.normalizeMatrixText(
        '$decomposed\r\n👩🏽‍💻',
      );
      final normalizedComposed = matrix_text.normalizeMatrixText(
        '$composed\n👩🏽‍💻',
      );

      expect(normalizedDecomposed, 'Café\n👩🏽‍💻');
      expect(normalizedDecomposed, normalizedComposed);
      expect({normalizedDecomposed, normalizedComposed}, hasLength(1));
    });

    test('keeps normalized Matrix body and safe formatted text', () {
      final content = matrix_text.buildTextMessageContent(
        'Cafe\u0301\r\n<b>safe</b>',
      );

      expect(content['body'], 'Café\n<b>safe</b>');
      expect(content['formatted_body'], 'Café<br>&lt;b&gt;safe&lt;/b&gt;');
    });
  });
}
