import 'dart:convert';

import 'package:canonical_json/canonical_json.dart';
import 'package:cryptography/cryptography.dart';
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

    test(
      'preserves canonical JSON bytes used by Matrix Ed25519 signatures',
      () async {
        final composedPayload = <String, dynamic>{'unicode': 'Café'};
        final decomposedPayload = <String, dynamic>{'unicode': 'Cafe\u0301'};
        final expectedBytes = utf8.encode('{"unicode":"Café"}');

        final composedBytes = canonicalJson.encode(composedPayload);
        final decomposedBytes = canonicalJson.encode(decomposedPayload);
        expect(composedBytes, expectedBytes);
        expect(decomposedBytes, expectedBytes);
        // Matrix's OlmManager.signJson converts each canonical byte to a
        // character before signing the resulting string. Preserve that exact
        // byte-to-character behavior while using the host Ed25519 provider.
        final matrixSigningMessage = String.fromCharCodes(expectedBytes);
        expect(matrixSigningMessage, '{"unicode":"CafÃ©"}');

        final ed25519 = Ed25519();
        final keyPair = await ed25519.newKeyPairFromSeed(
          List<int>.generate(32, (index) => index),
        );
        final signature = await ed25519.sign(
          utf8.encode(matrixSigningMessage),
          keyPair: keyPair,
        );

        expect(
          await ed25519.verify(
            utf8.encode(String.fromCharCodes(decomposedBytes)),
            signature: signature,
          ),
          isTrue,
        );
        expect(
          await ed25519.verify(
            utf8.encode(
              String.fromCharCodes(
                canonicalJson.encode({...decomposedPayload, 'unicode': 'Cafe'}),
              ),
            ),
            signature: signature,
          ),
          isFalse,
        );
      },
    );
  });
}
