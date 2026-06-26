import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/local/preferences_datasource.dart';
import 'translation_service.dart';
import '../utils/debug_log.dart';

/// MyMemory 免费翻译服务实现
///
/// API: https://api.mymemory.translated.net/get?q={text}&langpair={source}|{target}
/// 免费、无需 API key，每日 5000 字符限额。
/// 作为 Google Translate / AI Translation 不可用时的最终 fallback。
class MyMemoryTranslationService implements ITranslationService {
  final PreferencesDataSource _storageDataSource;

  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  MyMemoryTranslationService({required PreferencesDataSource storageDataSource})
    : _storageDataSource = storageDataSource;

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    // Check cache first
    final cacheKey = _generateCacheKey(text);
    final cached = await _storageDataSource.getTranslationCache(
      cacheKey,
      targetLanguage,
    );
    if (cached != null) {
      return TranslationResult(
        translatedText: cached,
        detectedSourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }

    try {
      final source = sourceLanguage ?? (await detectLanguage(text)) ?? 'en';
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'q': text,
          'langpair':
              '${translationApiLanguageCode(source)}|'
              '${translationApiLanguageCode(targetLanguage)}',
        },
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => http.Response('', 408),
          );

      if (response.statusCode != 200) {
        return TranslationResult.error('MyMemory: HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final responseData = data['responseData'] as Map<String, dynamic>?;
      if (responseData == null) {
        return TranslationResult.error('MyMemory: invalid response');
      }

      final translatedText = responseData['translatedText']?.toString() ?? '';
      if (translatedText.isEmpty) {
        return TranslationResult.error('MyMemory: empty translation');
      }

      // Save to cache
      await _storageDataSource.saveTranslationCache(
        cacheKey,
        targetLanguage,
        translatedText,
      );

      final detectedLang =
          responseData['detectedLanguage']?.toString() ?? source;

      return TranslationResult(
        translatedText: translatedText,
        detectedSourceLanguage: detectedLang,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      debugLog('MyMemoryTranslationService: Translation error: $e');
      return TranslationResult.error('Translation failed: $e');
    }
  }

  String _generateCacheKey(String text) {
    return sha256.convert(utf8.encode(text)).toString().substring(0, 16);
  }

  static final RegExp _chineseRegExp = RegExp(r'[\u4e00-\u9fff]');
  static final RegExp _japaneseRegExp = RegExp(r'[\u3040-\u309f\u30a0-\u30ff]');
  static final RegExp _koreanRegExp = RegExp(r'[\uac00-\ud7af]');

  @override
  Future<String?> detectLanguage(String text) async {
    if (_chineseRegExp.hasMatch(text)) return 'zh';
    if (_japaneseRegExp.hasMatch(text)) return 'ja';
    if (_koreanRegExp.hasMatch(text)) return 'ko';
    return 'en';
  }

  @override
  List<TranslationLanguage> getSupportedLanguages() {
    return const [
      TranslationLanguage(code: 'ar', name: 'Arabic', localizedName: 'العربية'),
      TranslationLanguage(code: 'bn', name: 'Bengali', localizedName: 'বাংলা'),
      TranslationLanguage(code: 'cs', name: 'Czech', localizedName: 'Čeština'),
      TranslationLanguage(code: 'de', name: 'German', localizedName: 'Deutsch'),
      TranslationLanguage(
        code: 'en',
        name: 'English',
        localizedName: 'English',
      ),
      TranslationLanguage(
        code: 'es',
        name: 'Spanish',
        localizedName: 'Español',
      ),
      TranslationLanguage(
        code: 'fr',
        name: 'French',
        localizedName: 'Français',
      ),
      TranslationLanguage(code: 'hi', name: 'Hindi', localizedName: 'हिन्दी'),
      TranslationLanguage(
        code: 'id',
        name: 'Indonesian',
        localizedName: 'Bahasa Indonesia',
      ),
      TranslationLanguage(
        code: 'it',
        name: 'Italian',
        localizedName: 'Italiano',
      ),
      TranslationLanguage(code: 'ja', name: 'Japanese', localizedName: '日本語'),
      TranslationLanguage(code: 'ko', name: 'Korean', localizedName: '한국어'),
      TranslationLanguage(code: 'mr', name: 'Marathi', localizedName: 'मराठी'),
      TranslationLanguage(code: 'pl', name: 'Polish', localizedName: 'Polski'),
      TranslationLanguage(
        code: 'pt',
        name: 'Portuguese',
        localizedName: 'Português',
      ),
      TranslationLanguage(
        code: 'ru',
        name: 'Russian',
        localizedName: 'Русский',
      ),
      TranslationLanguage(
        code: 'sw',
        name: 'Swahili',
        localizedName: 'Kiswahili',
      ),
      TranslationLanguage(code: 'ta', name: 'Tamil', localizedName: 'தமிழ்'),
      TranslationLanguage(code: 'te', name: 'Telugu', localizedName: 'తెలుగు'),
      TranslationLanguage(code: 'tr', name: 'Turkish', localizedName: 'Türkçe'),
      TranslationLanguage(
        code: 'uk',
        name: 'Ukrainian',
        localizedName: 'Українська',
      ),
      TranslationLanguage(code: 'ur', name: 'Urdu', localizedName: 'اردو'),
      TranslationLanguage(
        code: 'vi',
        name: 'Vietnamese',
        localizedName: 'Tiếng Việt',
      ),
      TranslationLanguage(
        code: 'zh_TW',
        name: 'Traditional Chinese',
        localizedName: '繁體中文',
      ),
    ];
  }
}
