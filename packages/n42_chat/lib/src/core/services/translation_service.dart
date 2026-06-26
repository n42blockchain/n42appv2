import 'dart:ui';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/local/preferences_datasource.dart';
import 'ai_service.dart';
import '../utils/debug_log.dart';

final RegExp _chineseDetectRegExp = RegExp(r'[\u4e00-\u9fff]');
final RegExp _japaneseDetectRegExp = RegExp(r'[\u3040-\u309f\u30a0-\u30ff]');
final RegExp _koreanDetectRegExp = RegExp(r'[\uac00-\ud7af]');

/// 翻译服务接口
abstract class ITranslationService {
  /// 翻译文本
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  });

  /// 检测语言
  Future<String?> detectLanguage(String text);

  /// 获取支持的语言列表
  List<TranslationLanguage> getSupportedLanguages();
}

/// 翻译结果
class TranslationResult {
  /// 翻译后的文本
  final String translatedText;

  /// 检测到的源语言
  final String? detectedSourceLanguage;

  /// 目标语言
  final String targetLanguage;

  /// 是否成功
  final bool success;

  /// 错误信息
  final String? error;

  const TranslationResult({
    required this.translatedText,
    this.detectedSourceLanguage,
    required this.targetLanguage,
    this.success = true,
    this.error,
  });

  factory TranslationResult.error(String error) {
    return TranslationResult(
      translatedText: '',
      targetLanguage: '',
      success: false,
      error: error,
    );
  }
}

/// 支持的翻译语言
class TranslationLanguage {
  /// 语言代码
  final String code;

  /// 语言名称
  final String name;

  /// 本地化名称
  final String localizedName;

  const TranslationLanguage({
    required this.code,
    required this.name,
    required this.localizedName,
  });
}

/// Google 翻译服务实现
class GoogleTranslationService implements ITranslationService {
  final String? apiKey;
  final PreferencesDataSource _storageDataSource;

  GoogleTranslationService({
    this.apiKey,
    required PreferencesDataSource storageDataSource,
  }) : _storageDataSource = storageDataSource;

  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    // 首先检查缓存
    final cachedTranslation = await _storageDataSource.getTranslationCache(
      _generateCacheKey(text),
      targetLanguage,
    );
    if (cachedTranslation != null) {
      return TranslationResult(
        translatedText: cachedTranslation,
        detectedSourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }

    // 无 API Key 时返回错误提示，而非假翻译
    if (apiKey == null || apiKey!.isEmpty) {
      return TranslationResult.error('翻译服务不可用：未配置 API Key');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': translationApiLanguageCode(targetLanguage),
          'source': sourceLanguage == null
              ? null
              : translationApiLanguageCode(sourceLanguage),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        if (translations.isNotEmpty) {
          final translation = translations.first;
          final translatedText = translation['translatedText'] as String;
          final detectedSource =
              translation['detectedSourceLanguage'] as String?;

          // 保存到缓存
          await _storageDataSource.saveTranslationCache(
            _generateCacheKey(text),
            targetLanguage,
            translatedText,
          );

          return TranslationResult(
            translatedText: translatedText,
            detectedSourceLanguage: detectedSource ?? sourceLanguage,
            targetLanguage: targetLanguage,
          );
        }
      }

      return TranslationResult.error(
        'Translation failed: ${response.statusCode}',
      );
    } catch (e) {
      debugLog('Translation error: $e');
      return TranslationResult.error('Translation failed: $e');
    }
  }

  String _generateCacheKey(String text) {
    // 使用 SHA-256 前 16 字符作为稳定的缓存键
    return sha256.convert(utf8.encode(text)).toString().substring(0, 16);
  }

  @override
  Future<String?> detectLanguage(String text) async {
    if (_chineseDetectRegExp.hasMatch(text)) return 'zh';
    if (_japaneseDetectRegExp.hasMatch(text)) return 'ja';
    if (_koreanDetectRegExp.hasMatch(text)) return 'ko';
    return 'en';
  }

  @override
  List<TranslationLanguage> getSupportedLanguages() {
    return _sharedSupportedLanguages;
  }
}

/// AI 翻译服务实现（委托给 AiService）
class AiTranslationService implements ITranslationService {
  final AiService _aiService;
  final PreferencesDataSource _storageDataSource;

  AiTranslationService({
    required AiService aiService,
    required PreferencesDataSource storageDataSource,
  }) : _aiService = aiService,
       _storageDataSource = storageDataSource;

  /// 语言代码到自然语言名称的映射（AI 需要 "Chinese" 而非 "zh"）
  static const _languageNames = {
    'ar': 'Arabic',
    'bn': 'Bengali',
    'cs': 'Czech',
    'de': 'German',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'hi': 'Hindi',
    'id': 'Indonesian',
    'it': 'Italian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'mr': 'Marathi',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'sw': 'Swahili',
    'ta': 'Tamil',
    'te': 'Telugu',
    'tr': 'Turkish',
    'uk': 'Ukrainian',
    'ur': 'Urdu',
    'vi': 'Vietnamese',
    'zh': 'Chinese',
    'zh_TW': 'Traditional Chinese',
  };

  @override
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    // 检查缓存
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
      final targetName = _languageNames[targetLanguage] ?? targetLanguage;
      final translatedText = await _aiService.translateMessage(
        text,
        targetName,
      );

      // 保存到缓存
      await _storageDataSource.saveTranslationCache(
        cacheKey,
        targetLanguage,
        translatedText,
      );

      final detectedSource = sourceLanguage ?? await detectLanguage(text);

      return TranslationResult(
        translatedText: translatedText,
        detectedSourceLanguage: detectedSource,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      debugLog('AiTranslationService: Translation error: $e');
      return TranslationResult.error('Translation failed: $e');
    }
  }

  String _generateCacheKey(String text) {
    return sha256.convert(utf8.encode(text)).toString().substring(0, 16);
  }

  @override
  Future<String?> detectLanguage(String text) async {
    if (_chineseDetectRegExp.hasMatch(text)) return 'zh';
    if (_japaneseDetectRegExp.hasMatch(text)) return 'ja';
    if (_koreanDetectRegExp.hasMatch(text)) return 'ko';
    return 'en';
  }

  @override
  List<TranslationLanguage> getSupportedLanguages() {
    return _sharedSupportedLanguages;
  }
}

const List<TranslationLanguage> _sharedSupportedLanguages = [
  TranslationLanguage(code: 'ar', name: 'Arabic', localizedName: 'العربية'),
  TranslationLanguage(code: 'bn', name: 'Bengali', localizedName: 'বাংলা'),
  TranslationLanguage(code: 'cs', name: 'Czech', localizedName: 'Čeština'),
  TranslationLanguage(code: 'de', name: 'German', localizedName: 'Deutsch'),
  TranslationLanguage(code: 'en', name: 'English', localizedName: 'English'),
  TranslationLanguage(code: 'es', name: 'Spanish', localizedName: 'Español'),
  TranslationLanguage(code: 'fr', name: 'French', localizedName: 'Français'),
  TranslationLanguage(code: 'hi', name: 'Hindi', localizedName: 'हिन्दी'),
  TranslationLanguage(code: 'id', name: 'Indonesian', localizedName: 'Bahasa Indonesia'),
  TranslationLanguage(code: 'it', name: 'Italian', localizedName: 'Italiano'),
  TranslationLanguage(code: 'ja', name: 'Japanese', localizedName: '日本語'),
  TranslationLanguage(code: 'ko', name: 'Korean', localizedName: '한국어'),
  TranslationLanguage(code: 'mr', name: 'Marathi', localizedName: 'मराठी'),
  TranslationLanguage(code: 'pl', name: 'Polish', localizedName: 'Polski'),
  TranslationLanguage(code: 'pt', name: 'Portuguese', localizedName: 'Português'),
  TranslationLanguage(code: 'ru', name: 'Russian', localizedName: 'Русский'),
  TranslationLanguage(code: 'sw', name: 'Swahili', localizedName: 'Kiswahili'),
  TranslationLanguage(code: 'ta', name: 'Tamil', localizedName: 'தமிழ்'),
  TranslationLanguage(code: 'te', name: 'Telugu', localizedName: 'తెలుగు'),
  TranslationLanguage(code: 'tr', name: 'Turkish', localizedName: 'Türkçe'),
  TranslationLanguage(code: 'uk', name: 'Ukrainian', localizedName: 'Українська'),
  TranslationLanguage(code: 'ur', name: 'Urdu', localizedName: 'اردو'),
  TranslationLanguage(code: 'vi', name: 'Vietnamese', localizedName: 'Tiếng Việt'),
  TranslationLanguage(code: 'zh', name: 'Simplified Chinese', localizedName: '简体中文'),
  TranslationLanguage(code: 'zh_TW', name: 'Traditional Chinese', localizedName: '繁體中文'),
];

String normalizeTranslationLanguageCode(String code) {
  final trimmed = code.trim();
  if (trimmed.isEmpty) return 'en';

  final normalized = trimmed.replaceAll('-', '_');
  final parts = normalized.split('_');
  final languageCode = parts.first.toLowerCase();
  if (languageCode == 'zh') {
    return 'zh_TW';
  }
  if (parts.length == 1 || parts[1].isEmpty) {
    return languageCode;
  }
  return '${languageCode}_${parts[1].toUpperCase()}';
}

String translationLanguageBaseCode(String code) {
  return normalizeTranslationLanguageCode(code).split('_').first;
}

String translationApiLanguageCode(String code) {
  return normalizeTranslationLanguageCode(code).replaceAll('_', '-');
}

/// 获取设备语言代码
String getDeviceLanguageCode() {
  final locale = PlatformDispatcher.instance.locale;
  return normalizeTranslationLanguageCode(
    locale.languageCode == 'zh' ? 'zh_TW' : locale.languageCode,
  );
}

/// 获取翻译目标语言（基于设备语言）
String getTargetLanguage(String? sourceLanguage) {
  final deviceLang = getDeviceLanguageCode();

  // 如果源语言和设备语言相同，翻译成英文
  if (sourceLanguage != null &&
      translationLanguageBaseCode(sourceLanguage) ==
          translationLanguageBaseCode(deviceLang)) {
    return deviceLang == 'en' ? 'zh_TW' : 'en';
  }

  return deviceLang;
}
