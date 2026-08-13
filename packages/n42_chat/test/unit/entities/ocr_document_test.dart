import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/domain/entities/ocr_document.dart';

void main() {
  test(
    'orderedLines returns stable reading order and full translation text',
    () {
      const second = OcrLine(
        id: 'line-2',
        blockId: 'block-2',
        text: 'world',
        normalizedRect: Rect.fromLTWH(0.1, 0.5, 0.4, 0.1),
        readingOrder: 1,
      );
      const first = OcrLine(
        id: 'line-1',
        blockId: 'block-1',
        text: 'hello',
        normalizedRect: Rect.fromLTWH(0.1, 0.1, 0.4, 0.1),
        readingOrder: 0,
      );
      const document = OcrDocument(
        fullText: 'hello\nworld',
        pixelSize: Size(100, 200),
        blocks: [
          OcrBlock(
            id: 'block-2',
            text: 'world',
            normalizedRect: Rect.fromLTWH(0.1, 0.5, 0.4, 0.1),
            lines: [second],
            readingOrder: 1,
          ),
          OcrBlock(
            id: 'block-1',
            text: 'hello',
            normalizedRect: Rect.fromLTWH(0.1, 0.1, 0.4, 0.1),
            lines: [first],
            readingOrder: 0,
          ),
        ],
      );

      expect(document.orderedLines.map((line) => line.id), [
        'line-1',
        'line-2',
      ]);
      expect(document.isEmpty, isFalse);

      const result = ImageTranslationResult(
        blocks: [
          ImageTranslationBlock(
            sourceBlockId: 'block-1',
            sourceText: 'hello',
            translatedText: '你好',
            normalizedRect: Rect.fromLTWH(0.1, 0.1, 0.4, 0.1),
          ),
          ImageTranslationBlock(
            sourceBlockId: 'block-2',
            sourceText: 'world',
            translatedText: '世界',
            normalizedRect: Rect.fromLTWH(0.1, 0.5, 0.4, 0.1),
          ),
        ],
        targetLanguage: 'zh',
        isOnDevice: true,
      );
      expect(result.fullText, '你好\n世界');
    },
  );
}
