import '../../domain/entities/ocr_document.dart';
import 'on_device_translation_service.dart';
import 'translation_service.dart';

class ImageTranslationCoordinator {
  ImageTranslationCoordinator({required this.onDevice, required this.remote});

  final OnDeviceTranslationService onDevice;
  final ITranslationService remote;

  Future<ImageTranslationResult> translate({
    required OcrDocument document,
    required String targetLanguage,
    bool allowRemoteFallback = false,
  }) async {
    final sourceLanguage = _detectSource(document);
    final translated = <ImageTranslationBlock>[];
    var usedRemote = false;

    for (final block in document.blocks) {
      String text;
      try {
        text = await onDevice.translate(
          text: block.text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
      } catch (_) {
        if (!allowRemoteFallback) rethrow;
        final result = await remote.translate(
          text: block.text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
        if (!result.success) {
          throw OnDeviceTranslationException(
            result.error ?? 'Translation failed',
          );
        }
        text = result.translatedText;
        usedRemote = true;
      }
      translated.add(
        ImageTranslationBlock(
          sourceBlockId: block.id,
          sourceText: block.text,
          translatedText: text,
          normalizedRect: block.normalizedRect,
        ),
      );
    }

    return ImageTranslationResult(
      blocks: translated,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isOnDevice: !usedRemote,
      provider: usedRemote ? 'configured-remote' : 'mlkit-on-device',
    );
  }

  String _detectSource(OcrDocument document) {
    final detected = document.detectedLanguages
        .map((code) => code.toLowerCase())
        .where((code) => code.isNotEmpty && code != 'und')
        .toList();
    if (detected.isNotEmpty) return detected.first;
    final text = document.fullText;
    if (RegExp(r'[\u3040-\u30ff]').hasMatch(text)) return 'ja';
    if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) return 'ko';
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return 'hi';
    return 'en';
  }
}
