import 'dart:ui';
import 'package:mocktail/mocktail.dart';
import 'package:n42_chat/src/core/services/ai_service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:n42_chat/src/core/services/image_translation_coordinator.dart';
import 'package:n42_chat/src/core/services/on_device_translation_service.dart';
import 'package:n42_chat/src/core/services/translation_service.dart';
import 'package:n42_chat/src/domain/entities/ocr_document.dart';

class _MockAi extends Mock implements AiService {}

void main() {
  const document = OcrDocument(
    fullText: '你好',
    pixelSize: Size(100, 50),
    blocks: [
      OcrBlock(
        id: 'block-0',
        text: '你好',
        normalizedRect: Rect.fromLTWH(0.1, 0.2, 0.5, 0.3),
        lines: [],
        readingOrder: 0,
      ),
    ],
  );

  test(
    'batches OCR blocks once after consent and preserves geometry',
    () async {
      final ai = _MockAi();
      final remote = _FakeRemoteTranslation();
      when(
        () => ai.completion(
          any(),
          systemPrompt: any(named: 'systemPrompt'),
          maxTokens: any(named: 'maxTokens'),
          temperature: any(named: 'temperature'),
        ),
      ).thenAnswer(
        (_) async => const AiCompletionResult(text: '["hello", "world"]'),
      );
      final twoBlocks = OcrDocument(
        fullText: '你好 世界',
        pixelSize: document.pixelSize,
        blocks: [
          document.blocks.first,
          const OcrBlock(
            id: 'block-1',
            text: '世界',
            normalizedRect: Rect.fromLTWH(0.1, 0.6, 0.5, 0.3),
            lines: [],
            readingOrder: 1,
          ),
        ],
      );
      final coordinator = ImageTranslationCoordinator(
        onDevice: _FakeOnDeviceTranslation(error: true),
        remote: remote,
        batchAi: ai,
      );
      await expectLater(
        coordinator.translate(document: twoBlocks, targetLanguage: 'en'),
        throwsA(isA<OnDeviceTranslationException>()),
      );
      verifyZeroInteractions(ai);
      final result = await coordinator.translate(
        document: twoBlocks,
        targetLanguage: 'en',
        allowRemoteFallback: true,
      );
      expect(result.blocks.map((b) => b.translatedText), ['hello', 'world']);
      expect(
        result.blocks.last.normalizedRect,
        twoBlocks.blocks.last.normalizedRect,
      );
      verify(
        () => ai.completion(
          any(),
          systemPrompt: any(named: 'systemPrompt'),
          maxTokens: any(named: 'maxTokens'),
          temperature: any(named: 'temperature'),
        ),
      ).called(1);
      expect(remote.translateCalls, 0);
    },
  );

  for (final response in ['```json\n["hello"]\n```', '```\n["hello"]\n```']) {
    test('accepts fenced translation JSON: $response', () async {
      final ai = _MockAi();
      when(
        () => ai.completion(
          any(),
          systemPrompt: any(named: 'systemPrompt'),
          maxTokens: any(named: 'maxTokens'),
          temperature: any(named: 'temperature'),
        ),
      ).thenAnswer((_) async => AiCompletionResult(text: response));
      final coordinator = ImageTranslationCoordinator(
        onDevice: _FakeOnDeviceTranslation(error: true),
        remote: _FakeRemoteTranslation(),
        batchAi: ai,
      );
      final result = await coordinator.translate(
        document: document,
        targetLanguage: 'en',
        allowRemoteFallback: true,
      );
      expect(result.fullText, 'hello');
      expect(result.isOnDevice, isFalse);
    });
  }

  test(
    'rejects incomplete batch rather than assigning text to wrong blocks',
    () async {
      final ai = _MockAi();
      when(
        () => ai.completion(
          any(),
          systemPrompt: any(named: 'systemPrompt'),
          maxTokens: any(named: 'maxTokens'),
          temperature: any(named: 'temperature'),
        ),
      ).thenAnswer((_) async => const AiCompletionResult(text: '[]'));
      final coordinator = ImageTranslationCoordinator(
        onDevice: _FakeOnDeviceTranslation(error: true),
        remote: _FakeRemoteTranslation(),
        batchAi: ai,
      );
      await expectLater(
        coordinator.translate(
          document: document,
          targetLanguage: 'en',
          allowRemoteFallback: true,
        ),
        throwsA(isA<OnDeviceTranslationException>()),
      );
    },
  );

  test(
    'uses local language detection and on-device translation first',
    () async {
      final remote = _FakeRemoteTranslation();
      final coordinator = ImageTranslationCoordinator(
        onDevice: _FakeOnDeviceTranslation(result: 'hello'),
        remote: remote,
      );

      final result = await coordinator.translate(
        document: document,
        targetLanguage: 'en',
      );

      expect(result.fullText, 'hello');
      expect(result.sourceLanguage, 'zh');
      expect(result.isOnDevice, isTrue);
      expect(remote.translateCalls, 0);
      expect(remote.detectCalls, 0);
    },
  );

  test('does not send OCR text remotely without explicit fallback', () async {
    final remote = _FakeRemoteTranslation();
    final coordinator = ImageTranslationCoordinator(
      onDevice: _FakeOnDeviceTranslation(error: true),
      remote: remote,
    );

    await expectLater(
      coordinator.translate(document: document, targetLanguage: 'en'),
      throwsA(isA<OnDeviceTranslationException>()),
    );
    expect(remote.translateCalls, 0);
    expect(remote.detectCalls, 0);
  });

  test('sends recognized text only after remote fallback is allowed', () async {
    final remote = _FakeRemoteTranslation();
    final coordinator = ImageTranslationCoordinator(
      onDevice: _FakeOnDeviceTranslation(error: true),
      remote: remote,
    );

    final result = await coordinator.translate(
      document: document,
      targetLanguage: 'en',
      allowRemoteFallback: true,
    );

    expect(result.fullText, '[remote] 你好');
    expect(result.isOnDevice, isFalse);
    expect(remote.translateCalls, 1);
    expect(remote.lastText, '你好');
    expect(remote.detectCalls, 0);
  });
}

class _FakeOnDeviceTranslation extends OnDeviceTranslationService {
  _FakeOnDeviceTranslation({this.result, this.error = false});

  final String? result;
  final bool error;

  @override
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (error) {
      throw const OnDeviceTranslationException('model unavailable');
    }
    return result ?? text;
  }
}

class _FakeRemoteTranslation implements ITranslationService {
  int translateCalls = 0;
  int detectCalls = 0;
  String? lastText;

  @override
  Future<String?> detectLanguage(String text) async {
    detectCalls++;
    return 'zh';
  }

  @override
  List<TranslationLanguage> getSupportedLanguages() => const [];

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    translateCalls++;
    lastText = text;
    return TranslationResult(
      translatedText: '[remote] $text',
      targetLanguage: targetLanguage,
      detectedSourceLanguage: sourceLanguage,
    );
  }
}
