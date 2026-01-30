// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';

/// Theme Colors Extension
///
/// Provides optimized access to theme colors through BuildContext extension.
/// This reduces repeated Theme.of(context) calls and string map lookups.
///
/// Usage:
/// ```dart
/// // Instead of:
/// AppThemeUtils.getColorByKey(context, AppThemeKeys.mainBlueColor.name)
///
/// // Use:
/// context.colors.mainBlue
/// ```
extension ThemeColorsExtension on BuildContext {
  /// Get the theme colors helper
  AppColors get colors => AppColors.of(this);
}

/// Cached color accessor for current theme
class AppColors {
  final BuildContext _context;
  late final bool _isDark;

  AppColors._(this._context) {
    _isDark = Theme.of(_context).brightness == Brightness.dark;
  }

  /// Factory constructor with context
  static AppColors of(BuildContext context) => AppColors._(context);

  /// Primary brand color
  Color get mainBlue => const Color(0xFF1976F9);

  /// Background colors
  Color get background => _isDark ? const Color(0xFF121212) : const Color(0xffF5F5F5);
  Color get background2 => _isDark ? const Color(0xFF121212) : const Color(0xffFFF3F3);
  Color get background3 => _isDark ? const Color(0xff000000) : const Color(0xffFFFFFF);

  /// Text colors
  Color get mainText => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF222222);
  Color get secondaryText => _isDark ? const Color(0xFF8F8F8F) : const Color(0xFF8F8F8F);
  Color get subtitleText => _isDark ? const Color(0xFFbebebe) : const Color(0xFFbebebe);
  Color get disabledText => _isDark ? const Color(0xFF8A8A8E) : const Color(0xFF8A8A8E);

  /// Item colors
  Color get itemBackground => _isDark ? const Color(0xFF1E1E1E) : const Color(0xffffffff);
  Color get itemBackground2 => _isDark ? const Color(0xFF232427) : const Color(0xffF9FAFB);
  Color get itemText => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF222222);
  Color get itemSubtitle => _isDark ? const Color(0xFF8F8F8F) : const Color(0xFF8F8F8F);
  Color get itemBorder => _isDark ? const Color(0xFF303239) : const Color(0xFFD9D9D9);

  /// Button colors
  Color get buttonBackground => mainBlue;
  Color get buttonBackgroundDisabled => _isDark ? const Color(0xFFD1E4FE) : const Color(0xFFD1E4FE);
  Color get buttonText => const Color(0xFFFFFFFF);
  Color get buttonTextDisabled => mainBlue;

  /// Status colors
  Color get error => const Color(0xFFF03450);
  Color get errorBackground => const Color(0xFFFFF3EC);
  Color get success => const Color(0xff44A677);
  Color get warning => const Color(0xFFFF6F16);

  /// Divider and separator
  Color get divider => _isDark ? const Color(0xff303239) : const Color(0xffD9D9D9);
  Color get separator => _isDark ? const Color(0x50E4E4E4) : const Color(0xFFE4E4E4);

  /// Gradient colors
  Color get gradient1 => _isDark ? const Color(0xff232323) : const Color(0xFFFFFFFF);
  Color get gradient2 => _isDark ? const Color(0x80000000) : Colors.white54;

  /// Utility colors
  Color get white => Colors.white;
  Color get black => Colors.black;
  Color get grey => Colors.grey;
  Color get transparent => Colors.transparent;
  Color get transparentOverlay => const Color.fromRGBO(0, 0, 0, 0.2);

  /// Hint colors
  Color get hint => _isDark ? const Color(0xFFBEBEBE) : const Color(0xFFBAC2CC);
  Color get hintText => _isDark ? const Color(0xFF545454) : const Color(0xFFCCCCCC);

  /// Check if current theme is dark
  bool get isDark => _isDark;
}

/// Cached theme colors holder for widget-level caching
///
/// Usage in StatefulWidget:
/// ```dart
/// late ThemeColorsCache _colorsCache;
///
/// @override
/// void didChangeDependencies() {
///   super.didChangeDependencies();
///   _colorsCache = ThemeColorsCache(context);
/// }
/// ```
class ThemeColorsCache {
  final bool isDark;
  final Color mainBlue;
  final Color background;
  final Color mainText;
  final Color itemBackground;
  final Color itemText;
  final Color itemSubtitle;
  final Color divider;
  final Color error;
  final Color success;
  final Color warning;
  final Color buttonBackground;
  final Color buttonText;

  ThemeColorsCache(BuildContext context)
      : isDark = Theme.of(context).brightness == Brightness.dark,
        mainBlue = const Color(0xFF1976F9),
        background = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212) : const Color(0xffF5F5F5),
        mainText = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFFFFFFF) : const Color(0xFF222222),
        itemBackground = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E) : const Color(0xffffffff),
        itemText = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFFFFFFF) : const Color(0xFF222222),
        itemSubtitle = const Color(0xFF8F8F8F),
        divider = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff303239) : const Color(0xffD9D9D9),
        error = const Color(0xFFF03450),
        success = const Color(0xff44A677),
        warning = const Color(0xFFFF6F16),
        buttonBackground = const Color(0xFF1976F9),
        buttonText = const Color(0xFFFFFFFF);
}
