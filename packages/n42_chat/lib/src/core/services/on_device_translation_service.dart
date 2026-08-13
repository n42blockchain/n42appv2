import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class OnDeviceTranslationException implements Exception {
  const OnDeviceTranslationException(this.message);

  final String message;

  @override
  String toString() => 'OnDeviceTranslationException: $message';
}

class OnDeviceTranslationService {
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool supportsLanguage(String code) => _language(code) != null;

  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final source = _language(sourceLanguage);
    final target = _language(targetLanguage);
    if (!isSupported || source == null || target == null) {
      throw const OnDeviceTranslationException(
        'Language pair is unavailable on device',
      );
    }
    if (source == target || text.trim().isEmpty) return text;

    await _ensureModel(source);
    await _ensureModel(target);
    final translator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );
    try {
      return await translator.translateText(text);
    } catch (error) {
      throw OnDeviceTranslationException(
        'On-device translation failed: $error',
      );
    } finally {
      await translator.close();
    }
  }

  Future<void> _ensureModel(TranslateLanguage language) async {
    final code = language.bcpCode;
    if (await _modelManager.isModelDownloaded(code)) return;
    final downloaded = await _modelManager.downloadModel(code);
    if (!downloaded) {
      throw OnDeviceTranslationException(
        'Unable to download the $code language model',
      );
    }
  }

  TranslateLanguage? _language(String rawCode) {
    final code = rawCode.toLowerCase().replaceAll('_', '-').split('-').first;
    return switch (code) {
      'af' => TranslateLanguage.afrikaans,
      'ar' => TranslateLanguage.arabic,
      'bn' => TranslateLanguage.bengali,
      'cs' => TranslateLanguage.czech,
      'de' => TranslateLanguage.german,
      'en' => TranslateLanguage.english,
      'es' => TranslateLanguage.spanish,
      'fa' => TranslateLanguage.persian,
      'fi' => TranslateLanguage.finnish,
      'fr' => TranslateLanguage.french,
      'gu' => TranslateLanguage.gujarati,
      'he' => TranslateLanguage.hebrew,
      'hi' => TranslateLanguage.hindi,
      'id' => TranslateLanguage.indonesian,
      'it' => TranslateLanguage.italian,
      'ja' => TranslateLanguage.japanese,
      'ko' => TranslateLanguage.korean,
      'mr' => TranslateLanguage.marathi,
      'nl' => TranslateLanguage.dutch,
      'pl' => TranslateLanguage.polish,
      'pt' => TranslateLanguage.portuguese,
      'ru' => TranslateLanguage.russian,
      'sw' => TranslateLanguage.swahili,
      'ta' => TranslateLanguage.tamil,
      'te' => TranslateLanguage.telugu,
      'th' => TranslateLanguage.thai,
      'tr' => TranslateLanguage.turkish,
      'uk' => TranslateLanguage.ukrainian,
      'ur' => TranslateLanguage.urdu,
      'vi' => TranslateLanguage.vietnamese,
      'zh' => TranslateLanguage.chinese,
      _ => null,
    };
  }
}
