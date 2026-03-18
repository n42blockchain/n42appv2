// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/widgets.dart';

/// Language item data model
class LanguageItem {
  final String code;
  final String name;
  final String englishName;
  final String icon;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.englishName,
    required this.icon,
  });
}

const String _genericLanguageIcon = 'assets/home/setting/language.png';

/// All supported languages - single source of truth
const List<LanguageItem> kSupportedLanguages = [
  LanguageItem(
    code: 'en',
    name: 'English',
    englishName: 'English',
    icon: 'assets/home/setting/english.png',
  ),
  LanguageItem(
    code: 'zh_TW',
    name: '繁體中文',
    englishName: 'Traditional Chinese',
    icon: 'assets/home/setting/chinese.png',
  ),
  LanguageItem(
    code: 'ar',
    name: 'العربية',
    englishName: 'Arabic',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'bn',
    name: 'বাংলা',
    englishName: 'Bengali',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'cs',
    name: 'Čeština',
    englishName: 'Czech',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'de',
    name: 'Deutsch',
    englishName: 'German',
    icon: 'assets/home/setting/german.png',
  ),
  LanguageItem(
    code: 'es_ES',
    name: 'Español',
    englishName: 'Spanish',
    icon: 'assets/home/setting/spanish.png',
  ),
  LanguageItem(
    code: 'fr',
    name: 'Français',
    englishName: 'French',
    icon: 'assets/home/setting/french.png',
  ),
  LanguageItem(
    code: 'hi',
    name: 'हिन्दी',
    englishName: 'Hindi',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'id',
    name: 'Bahasa Indonesia',
    englishName: 'Indonesian',
    icon: 'assets/home/setting/indonesian.png',
  ),
  LanguageItem(
    code: 'it',
    name: 'Italiano',
    englishName: 'Italian',
    icon: 'assets/home/setting/italian.png',
  ),
  LanguageItem(
    code: 'ja',
    name: '日本語',
    englishName: 'Japanese',
    icon: 'assets/home/setting/japanese.png',
  ),
  LanguageItem(
    code: 'ko',
    name: '한국어',
    englishName: 'Korean',
    icon: 'assets/home/setting/korean.png',
  ),
  LanguageItem(
    code: 'mr',
    name: 'मराठी',
    englishName: 'Marathi',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'pl',
    name: 'Polski',
    englishName: 'Polish',
    icon: 'assets/home/setting/polish.png',
  ),
  LanguageItem(
    code: 'pt',
    name: 'Português',
    englishName: 'Portuguese',
    icon: 'assets/home/setting/portuguese.png',
  ),
  LanguageItem(
    code: 'pt_BR',
    name: 'Português (Brasil)',
    englishName: 'Portuguese (Brazil)',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'ru',
    name: 'Русский',
    englishName: 'Russian',
    icon: 'assets/home/setting/russian.png',
  ),
  LanguageItem(
    code: 'sw',
    name: 'Kiswahili',
    englishName: 'Swahili',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'ta',
    name: 'தமிழ்',
    englishName: 'Tamil',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'te',
    name: 'తెలుగు',
    englishName: 'Telugu',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'tr',
    name: 'Türkçe',
    englishName: 'Turkish',
    icon: 'assets/home/setting/turkish.png',
  ),
  LanguageItem(
    code: 'uk',
    name: 'Українська',
    englishName: 'Ukrainian',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'ur',
    name: 'اردو',
    englishName: 'Urdu',
    icon: _genericLanguageIcon,
  ),
  LanguageItem(
    code: 'vi',
    name: 'Tiếng Việt',
    englishName: 'Vietnamese',
    icon: 'assets/home/setting/vietnamese.png',
  ),
];

/// Map for quick lookup by language code
final Map<String, LanguageItem> kLanguageMap = {
  for (final lang in kSupportedLanguages)
    normalizeLanguageCode(lang.code): lang,
};

final Map<String, LanguageItem> _kLanguageBaseMap = () {
  final languageBaseMap = <String, LanguageItem>{};
  for (final lang in kSupportedLanguages) {
    languageBaseMap.putIfAbsent(
      normalizeLanguageBaseCode(lang.code),
      () => lang,
    );
  }
  return languageBaseMap;
}();

/// Normalize language code (`pt-br` -> `pt_BR`, `es_ES` -> `es_ES`)
String normalizeLanguageCode(String code) {
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

/// Normalize to base language code (`es_ES` -> `es`)
String normalizeLanguageBaseCode(String code) {
  return normalizeLanguageCode(code).split('_').first;
}

/// Convert a persisted code to [Locale].
Locale localeFromLanguageCode(String code) {
  final normalized = normalizeLanguageCode(code);
  final parts = normalized.split('_');
  if (parts.length > 1) {
    return Locale(parts[0], parts[1]);
  }
  return Locale(parts[0]);
}

/// Convert a [Locale] to persisted code.
String languageCodeFromLocale(Locale locale) {
  final languageCode = locale.languageCode.toLowerCase();
  if (languageCode == 'zh') {
    return 'zh_TW';
  }
  final countryCode = locale.countryCode;
  if (countryCode == null || countryCode.isEmpty) {
    return languageCode;
  }
  return '${languageCode}_${countryCode.toUpperCase()}';
}

/// Get language info by code, with fallback to English
LanguageItem getLanguageByCode(String code) {
  final normalized = normalizeLanguageCode(code);
  return kLanguageMap[normalized] ??
      _kLanguageBaseMap[normalizeLanguageBaseCode(normalized)] ??
      kSupportedLanguages.first;
}

/// Whether [candidateCode] is the effective supported option for [currentCode].
bool isLanguageSelected(String currentCode, String candidateCode) {
  final resolvedCode = normalizeLanguageCode(
    getLanguageByCode(currentCode).code,
  );
  return resolvedCode == normalizeLanguageCode(candidateCode);
}
