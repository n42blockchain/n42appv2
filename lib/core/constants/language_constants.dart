// Copyright 2021-2026 N42 Inc. All rights reserved.

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

/// All supported languages - single source of truth
const List<LanguageItem> kSupportedLanguages = [
  LanguageItem(code: 'en', name: 'English', englishName: 'English', icon: 'assets/home/setting/english.png'),
  LanguageItem(code: 'ja', name: '日本語', englishName: 'Japanese', icon: 'assets/home/setting/japanese.png'),
  LanguageItem(code: 'ko', name: '한국어', englishName: 'Korean', icon: 'assets/home/setting/korean.png'),
  LanguageItem(code: 'es_ES', name: 'Español', englishName: 'Spanish', icon: 'assets/home/setting/spanish.png'),
  LanguageItem(code: 'fr', name: 'Français', englishName: 'French', icon: 'assets/home/setting/french.png'),
  LanguageItem(code: 'de', name: 'Deutsch', englishName: 'German', icon: 'assets/home/setting/german.png'),
  LanguageItem(code: 'it', name: 'Italiano', englishName: 'Italian', icon: 'assets/home/setting/italian.png'),
  LanguageItem(code: 'pt', name: 'Português', englishName: 'Portuguese', icon: 'assets/home/setting/portuguese.png'),
  LanguageItem(code: 'ru', name: 'Русский', englishName: 'Russian', icon: 'assets/home/setting/russian.png'),
  LanguageItem(code: 'vi', name: 'Tiếng Việt', englishName: 'Vietnamese', icon: 'assets/home/setting/vietnamese.png'),
  LanguageItem(code: 'id', name: 'Bahasa Indonesia', englishName: 'Indonesian', icon: 'assets/home/setting/indonesian.png'),
  LanguageItem(code: 'tr', name: 'Türkçe', englishName: 'Turkish', icon: 'assets/home/setting/turkish.png'),
  LanguageItem(code: 'pl', name: 'Polski', englishName: 'Polish', icon: 'assets/home/setting/polish.png'),
];

/// Map for quick lookup by language code
final Map<String, LanguageItem> kLanguageMap = {
  for (final lang in kSupportedLanguages) _normalizeCode(lang.code): lang,
};

/// Normalize language code (es_ES -> es)
String _normalizeCode(String code) => code.split('_').first;

/// Get language info by code, with fallback to English
LanguageItem getLanguageByCode(String code) {
  return kLanguageMap[_normalizeCode(code)] ?? kSupportedLanguages.first;
}
