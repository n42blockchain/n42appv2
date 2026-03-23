// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

part of 'core_providers.dart';

// ============================================
// Theme Provider
// ============================================

/// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ref.watch(spUtilProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SPUtil _spUtil;

  ThemeModeNotifier(this._spUtil) : super(ThemeMode.system) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final mode = await _spUtil.getThemeMode();
    if (!mounted) return;
    state = ThemeModeUtils.fromInt(mode ?? 0);
    _syncToN42Chat(state);
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _spUtil.setThemeMode(ThemeModeUtils.toInt(mode));
    _syncToN42Chat(mode);
  }

  void _syncToN42Chat(ThemeMode mode) {
    if (N42Chat.isInitialized) N42Chat.setThemeMode(mode);
  }
}

// ============================================
// Accent Color Provider
// ============================================

/// Accent color provider — persisted via SharedPreferences.
/// Default is [ThemeAdapter.defaultAccent] (N42 brand blue).
final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((
  ref,
) {
  return AccentColorNotifier(ref.watch(spUtilProvider));
});

class AccentColorNotifier extends StateNotifier<Color> {
  final SPUtil _spUtil;

  AccentColorNotifier(this._spUtil) : super(ThemeAdapter.defaultAccent) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final value = await _spUtil.getAccentColor();
    if (!mounted) return;
    if (value != null && value != 0) {
      state = Color(value);
    }
  }

  void setAccent(Color color) {
    state = color;
    _spUtil.setAccentColor(color.toARGB32());
  }

  void reset() {
    state = ThemeAdapter.defaultAccent;
    _spUtil.setAccentColor(0); // 0 = default
  }
}

// ============================================
// Locale Provider
// ============================================

/// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.watch(spUtilProvider));
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SPUtil _spUtil;

  LocaleNotifier(this._spUtil) : super(const Locale('en')) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final code = await _spUtil.getSysLang();
    if (!mounted) return;
    if (code != null) {
      state = _codeToLocale(code);
      _syncToN42Chat(state);
    }
  }

  void setLocale(String code) {
    final normalizedCode = normalizeLanguageCode(code);
    state = _codeToLocale(normalizedCode);
    _spUtil.setSysLang(normalizedCode);
    _syncToN42Chat(state);
  }

  void _syncToN42Chat(Locale locale) {
    if (N42Chat.isInitialized) N42Chat.setLocale(locale);
  }

  Locale _codeToLocale(String code) {
    return localeFromLanguageCode(code);
  }

  /// Get locale info for display
  Map<String, String> getLocaleInfo(Locale locale) {
    final lang = getLanguageByCode(languageCodeFromLocale(locale));
    return {"icon": lang.icon, "title": lang.name};
  }
}
