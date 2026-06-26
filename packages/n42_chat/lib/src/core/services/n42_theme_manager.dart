part of '../../n42_chat.dart';

/// N42Chat 主题/字体/国际化管理器
///
/// 从 N42Chat 主类中提取的主题相关字段和方法。
/// 作为 part file 存在，所有成员对 N42Chat 可见。
class _N42ThemeManager {
  _N42ThemeManager._();

  static ThemeMode _themeMode = ThemeMode.system;
  static FontSize _fontSize = FontSize.medium;
  static Locale _locale = const Locale('en');
  static bool _hostControlsAppearance = false;
  static final List<void Function(ThemeMode)> _themeListeners = [];
  static final List<void Function(FontSize)> _fontSizeListeners = [];
  static final List<void Function(Locale)> _localeListeners = [];

  /// 宿主 App 是否接管外观（明暗模式）。
  ///
  /// 嵌入主 App 时由宿主置为 true：此时 chat 不再用自身存储的
  /// themeMode 覆盖宿主下发的设置（详见入口 widget 的
  /// `_loadAppearanceSettings`），明暗模式以宿主为唯一来源。
  static bool get hostControlsAppearance => _hostControlsAppearance;

  static set hostControlsAppearance(bool value) {
    if (_hostControlsAppearance != value) {
      _hostControlsAppearance = value;
      debugLog('N42Chat: hostControlsAppearance = $value');
    }
  }

  /// 获取当前主题模式
  static ThemeMode get themeMode => _themeMode;

  /// 获取当前字体大小偏好
  static FontSize get fontSize => _fontSize;

  /// 获取当前语言设置
  static Locale get locale => _locale;

  /// 设置主题模式
  static void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      for (final listener in _themeListeners) {
        listener(mode);
      }
      debugLog('N42Chat: Theme mode changed to $mode');
    }
  }

  /// 添加主题变化监听器
  static void addThemeListener(void Function(ThemeMode) listener) {
    _themeListeners.add(listener);
  }

  /// 移除主题变化监听器
  static void removeThemeListener(void Function(ThemeMode) listener) {
    _themeListeners.remove(listener);
  }

  /// 设置字体大小
  static void setFontSize(FontSize fontSize) {
    if (_fontSize != fontSize) {
      _fontSize = fontSize;
      for (final listener in _fontSizeListeners) {
        listener(fontSize);
      }
      debugLog('N42Chat: Font size changed to $fontSize');
    }
  }

  /// 添加字体大小变化监听器
  static void addFontSizeListener(void Function(FontSize) listener) {
    _fontSizeListeners.add(listener);
  }

  /// 移除字体大小变化监听器
  static void removeFontSizeListener(void Function(FontSize) listener) {
    _fontSizeListeners.remove(listener);
  }

  static Locale _normalizeLocale(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    final countryCode = locale.countryCode;

    // Only default bare 'zh' (no country) to zh_TW;
    // preserve explicit zh_CN, zh_SG, etc.
    if (languageCode == 'zh' && (countryCode == null || countryCode.isEmpty)) {
      return const Locale('zh', 'TW');
    }

    if (countryCode == null || countryCode.isEmpty) {
      return Locale(languageCode);
    }
    return Locale(languageCode, countryCode.toUpperCase());
  }

  /// 设置语言
  static void setLocale(Locale locale) {
    final normalizedLocale = _normalizeLocale(locale);
    if (_locale != normalizedLocale) {
      _locale = normalizedLocale;
      N42DateUtils.setLocale(
        DateLocaleStrings.fromLocaleCode(normalizedLocale.languageCode),
      );
      for (final listener in _localeListeners) {
        listener(normalizedLocale);
      }
      debugLog('N42Chat: Locale changed to $normalizedLocale');
    }
  }

  /// 添加语言变化监听器
  static void addLocaleListener(void Function(Locale) listener) {
    _localeListeners.add(listener);
  }

  /// 移除语言变化监听器
  static void removeLocaleListener(void Function(Locale) listener) {
    _localeListeners.remove(listener);
  }

  /// 判断当前是否为深色模式
  static bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
