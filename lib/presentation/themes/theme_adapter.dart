// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/design_system/app_typography.dart';
import '../../core/design_system/app_radius.dart';

/// Theme Adapter
///
/// Provides light and dark theme configurations for the application.
class ThemeAdapter {
  ThemeAdapter._();

  /// Default Apple system blue; saved custom accents remain unchanged.
  static const Color defaultAccent = Color(0xFF007AFF);

  /// Build light ThemeData with the given [accent] color.
  static ThemeData buildLight(
    Color accent, {
    TextScaler textScaler = TextScaler.noScaling,
  }) => _finish(
    ThemeData.light().copyWith(
      scaffoldBackgroundColor:
          AppThemeUtils.lightMap[AppThemeKeys.backGroundColor.name],
      primaryColor: accent,
      colorScheme: ColorScheme.light(primary: accent, secondary: accent),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(color: Color(0xff222222)),
        actionsIconTheme: IconThemeData(color: Color(0xff222222)),
        toolbarTextStyle: TextStyle(color: Color(0xff222222)),
        iconTheme: IconThemeData(color: Color(0xff222222)),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: accent),
        unselectedIconTheme: const IconThemeData(color: Color(0xffffffff)),
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xff222222),
      ),

      iconTheme: const IconThemeData(color: Color(0xff222222)),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Color(0xFFBAC2CC), fontSize: 16),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, style: BorderStyle.solid),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffc6c6c6),
            style: BorderStyle.solid,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffd9445a),
            style: BorderStyle.solid,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
      ),

      buttonTheme: _buttonTheme(accent),
      progressIndicatorTheme: _progressTheme(accent),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xffD9D9D9),
        space: 0,
        thickness: 1,
        indent: 10,
        endIndent: 10,
      ),

      textSelectionTheme: _textSelectionTheme(accent),
    ),
    accent,
    textScaler,
  );

  /// Build dark ThemeData with the given [accent] color.
  static ThemeData buildDark(
    Color accent, {
    TextScaler textScaler = TextScaler.noScaling,
  }) => _finish(
    ThemeData.dark().copyWith(
      scaffoldBackgroundColor:
          AppThemeUtils.darkMap[AppThemeKeys.backGroundColor.name],
      primaryColor: accent,
      colorScheme: ColorScheme.dark(primary: accent, secondary: accent),

      cardTheme: const CardThemeData(
        shadowColor: Color(0xff444444),
        color: Color(0xff2b2b2b),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(color: Color(0xffffffff)),
        toolbarTextStyle: TextStyle(color: Color(0xffffffff)),
        actionsIconTheme: IconThemeData(color: Color(0xffffffff)),
        iconTheme: IconThemeData(color: Color(0xffffffff)),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: accent),
        unselectedIconTheme: const IconThemeData(color: Color(0xffffffff)),
        selectedItemColor: accent,
        unselectedItemColor: const Color(0xff888888),
      ),

      iconTheme: const IconThemeData(color: Color(0xffffffff)),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Color(0xFFBEBEBE), fontSize: 16),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, style: BorderStyle.solid),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff545454),
            style: BorderStyle.solid,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffd9445a),
            style: BorderStyle.solid,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent.withValues(alpha: 0.5),
      ),

      buttonTheme: _buttonTheme(accent),
      progressIndicatorTheme: _progressTheme(accent),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xff303239),
        space: 0,
        thickness: 1,
        indent: 10,
        endIndent: 10,
      ),

      textSelectionTheme: _textSelectionTheme(accent),
    ),
    accent,
    textScaler,
  );

  static ThemeData _finish(
    ThemeData base,
    Color accent,
    TextScaler textScaler,
  ) {
    final dark = base.brightness == Brightness.dark;
    final apple = accent == defaultAccent;
    Color resolve(Color color) => color is CupertinoDynamicColor
        ? (dark ? color.darkColor : color.color)
        : color;
    final primary = apple ? resolve(CupertinoColors.systemBlue) : accent;
    final colors = AppThemeUtils.palette(base.brightness, accent);
    final foreground = colors[AppThemeKeys.mainTextColor.name]!;
    final surface = colors[AppThemeKeys.itemBgColor.name]!;
    final background = colors[AppThemeKeys.backGroundColor.name]!;
    final border = colors[AppThemeKeys.dividerColor.name]!;
    final text = AppTypography.textTheme.apply(
      bodyColor: foreground,
      displayColor: foreground,
    );
    final button = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textStyle: WidgetStatePropertyAll(AppTypography.headline),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.padded,
    );
    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      cardTheme: base.cardTheme.copyWith(color: surface),
      dividerColor: border,
      dividerTheme: base.dividerTheme.copyWith(color: border),
      primaryColor: primary,
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: primary,
        surface: surface,
        onSurface: foreground,
        error: colors[AppThemeKeys.errorTextColor.name],
        outline: border,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: base.brightness,
        primaryColor: apple ? CupertinoColors.systemBlue : accent,
        scaffoldBackgroundColor: background,
        barBackgroundColor: surface,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        toolbarHeight: math.max(44, textScaler.scale(17) * 22 / 17 + 12),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: background,
        foregroundColor: foreground,
        titleTextStyle: AppTypography.headline.copyWith(color: foreground),
        iconTheme: IconThemeData(color: foreground, size: 22),
        actionsIconTheme: IconThemeData(color: foreground, size: 22),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: button.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? primary.withValues(alpha: 0.3)
                : primary,
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: button.copyWith(
          backgroundColor: WidgetStatePropertyAll(primary),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: button.copyWith(
          foregroundColor: WidgetStatePropertyAll(primary),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: button.copyWith(
          foregroundColor: WidgetStatePropertyAll(primary),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(44, 44)),
          iconSize: WidgetStatePropertyAll(22),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: 44,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: AppTypography.body.copyWith(color: foreground),
        subtitleTextStyle: AppTypography.footnote.copyWith(
          color: colors[AppThemeKeys.mainTextColor6.name],
        ),
        iconColor: primary,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        hintStyle: AppTypography.body.copyWith(
          color: colors[AppThemeKeys.textFieldHintColor.name],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        constraints: const BoxConstraints(minHeight: 44),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: colors[AppThemeKeys.errorTextColor.name]!,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(
            color: colors[AppThemeKeys.errorTextColor.name]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: apple
            ? resolve(CupertinoColors.secondarySystemGroupedBackground)
            : surface,
        titleTextStyle: AppTypography.headline.copyWith(color: foreground),
        contentTextStyle: AppTypography.body.copyWith(color: foreground),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brSheetTop),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedItemColor: primary,
        selectedIconTheme: IconThemeData(color: primary),
        backgroundColor: surface,
        selectedLabelStyle: AppTypography.captionSm,
        unselectedLabelStyle: AppTypography.captionSm,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: primary,
      ),
      progressIndicatorTheme: _progressTheme(primary),
      textSelectionTheme: _textSelectionTheme(primary),
    );
  }

  // ── Shared theme components ─────────────────────────────────────────────

  static ButtonThemeData _buttonTheme(Color accent) =>
      ButtonThemeData(buttonColor: accent);

  static ProgressIndicatorThemeData _progressTheme(Color accent) =>
      ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: Colors.white24,
        refreshBackgroundColor: Colors.white24,
      );

  static TextSelectionThemeData _textSelectionTheme(Color accent) =>
      TextSelectionThemeData(cursorColor: accent);

  // ── Backward-compat statics (used in tests / legacy call sites) ──────────
  static ThemeData get themeDataLight => buildLight(defaultAccent);
  static ThemeData get themeDataDark => buildDark(defaultAccent);
}

/// Theme Utility Functions
class AppThemeUtils {
  AppThemeUtils._();

  /// Get color by key based on current theme.
  ///
  /// [AppThemeKeys.mainBlueColor] always resolves through
  /// `Theme.of(context).colorScheme.primary` so it automatically
  /// reflects any custom accent color set by the user.
  static Color getColorByKey(BuildContext? context, String key) {
    if (context == null) return Colors.red;

    if (key == AppThemeKeys.mainBlueColor.name) {
      return Theme.of(context).colorScheme.primary;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final accent = theme.cupertinoOverrideTheme?.primaryColor;
    final apple =
        accent == CupertinoColors.systemBlue ||
        (accent == null &&
            theme.colorScheme.primary == ThemeAdapter.defaultAccent);
    final colorMap = palette(
      isDark ? Brightness.dark : Brightness.light,
      apple
          ? ThemeAdapter.defaultAccent
          : (accent ?? theme.colorScheme.primary),
    );

    return colorMap[key] ?? const Color(0xff000000);
  }

  /// Existing custom palette with Apple's semantic colors as the default.
  static Map<String, Color> palette(Brightness brightness, Color accent) {
    final dark = brightness == Brightness.dark;
    final colors = {...(dark ? darkMap : lightMap)};
    if (accent != ThemeAdapter.defaultAccent) {
      for (final key in [
        AppThemeKeys.mainBlueColor,
        AppThemeKeys.mainButtonBgColor,
        AppThemeKeys.mainButtonTextColor3,
        AppThemeKeys.refreshBGColor,
      ]) {
        colors[key.name] = accent;
      }
      return colors;
    }
    Color resolve(Color color) => color is CupertinoDynamicColor
        ? (dark ? color.darkColor : color.color)
        : color;
    void set(List<AppThemeKeys> keys, Color color) {
      for (final key in keys) {
        colors[key.name] = resolve(color);
      }
    }

    set([
      AppThemeKeys.backGroundColor,
      AppThemeKeys.backGroundColor2,
    ], CupertinoColors.systemGroupedBackground);
    set([
      AppThemeKeys.backGroundColor3,
      AppThemeKeys.itemBgColor,
      AppThemeKeys.itemBgColor4,
    ], CupertinoColors.secondarySystemGroupedBackground);
    set([
      AppThemeKeys.itemBgColor2,
      AppThemeKeys.itemBgColor5,
      AppThemeKeys.itemBgColor6,
    ], CupertinoColors.tertiarySystemGroupedBackground);
    set([
      AppThemeKeys.mainTextColor,
      AppThemeKeys.itemTextColor,
      AppThemeKeys.mainTextColor7,
    ], CupertinoColors.label);
    set([
      AppThemeKeys.mainTextColor6,
      AppThemeKeys.itemSubtitleTextColor,
      AppThemeKeys.mainTextColor8,
    ], CupertinoColors.secondaryLabel);
    set([
      AppThemeKeys.mainTextColor4,
      AppThemeKeys.mainTextColor3,
      AppThemeKeys.textFieldHintColor,
      AppThemeKeys.hintTextColor,
    ], CupertinoColors.tertiaryLabel);
    set([
      AppThemeKeys.dividerColor,
      AppThemeKeys.itemBorderColor,
      AppThemeKeys.itemLineColor,
    ], CupertinoColors.separator);
    set([
      AppThemeKeys.mainBlueColor,
      AppThemeKeys.mainButtonBgColor,
      AppThemeKeys.mainButtonTextColor3,
      AppThemeKeys.refreshBGColor,
    ], CupertinoColors.systemBlue);
    set([AppThemeKeys.rightTextColor], CupertinoColors.systemGreen);
    set([AppThemeKeys.errorTextColor], CupertinoColors.systemRed);
    set([AppThemeKeys.textColorOrange], CupertinoColors.systemOrange);
    return colors;
  }

  /// Light theme colors
  static final Map<String, Color> lightMap = {
    AppThemeKeys.backGroundColor.name: const Color(0xffF5F6F8),
    AppThemeKeys.backGroundColor2.name: const Color(0xffFFF3F3),
    AppThemeKeys.backGroundColor3.name: const Color(0xffFFFFFF),
    AppThemeKeys.linearGradient1.name: const Color(0xFFFFFFFF),
    AppThemeKeys.linearGradient2.name: Colors.white54,
    AppThemeKeys.mainBlueColor.name: const Color(0xFF5B6CFF),
    AppThemeKeys.mainTextColor.name: const Color(0xFF1A1C22),
    AppThemeKeys.mainTextColor3.name: const Color(0xFFbebebe),
    AppThemeKeys.mainTextColor4.name: const Color(0xFF9AA0AC),
    AppThemeKeys.mainTextColor5.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainTextColor6.name: const Color(0xFF5C616D),
    AppThemeKeys.mainTextColor7.name: const Color(0xFF0d0d0d),
    AppThemeKeys.mainTextColor8.name: const Color(0xFF808084),
    AppThemeKeys.mainTextColor10.name: const Color(0xFF8E8E93),
    AppThemeKeys.mainWhiteColor.name: Colors.white,
    AppThemeKeys.mainBlockColor.name: Colors.black,
    AppThemeKeys.refreshBGColor.name: const Color(0xFF5B6CFF),
    AppThemeKeys.refreshValueColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.ff888888.name: const Color(0xFF888888),
    AppThemeKeys.itemBgColor.name: const Color(0xffffffff),
    AppThemeKeys.itemBgColor2.name: const Color(0xffF9FAFB),
    AppThemeKeys.itemBgColor4.name: const Color(0xFFFFFFFF),
    AppThemeKeys.itemBgColor5.name: const Color(0xFFEDEFF2),
    AppThemeKeys.itemBgColor6.name: const Color(0xFFE6E6E7),
    AppThemeKeys.itemBgColor8.name: const Color(0xFFEBEBEB),
    AppThemeKeys.itemTextColor.name: const Color(0xFF222222),
    AppThemeKeys.itemSubtitleTextColor.name: const Color(0xFF6B7280),
    AppThemeKeys.itemBorderColor.name: const Color(0xFFE6E8EC),
    AppThemeKeys.itemLineColor.name: const Color(0xFFE6E8EC),
    AppThemeKeys.errorBgColor.name: const Color(0xFFFFF3EC),
    AppThemeKeys.errorBgColor2.name: const Color(0xFFF23D52).withAlpha(51),
    AppThemeKeys.errorTextColor.name: const Color(0xFFF23D52),
    AppThemeKeys.rightTextColor.name: const Color(0xff1FB67A),
    AppThemeKeys.textColorOrange.name: const Color(0xFFFF8A1F),
    AppThemeKeys.dividerColor.name: const Color(0xffE6E8EC),
    AppThemeKeys.mainButtonBgColor.name: const Color(0xFF5B6CFF),
    AppThemeKeys.mainButtonBgColor3.name: const Color(0xFFD1E4FE),
    AppThemeKeys.mainButtonTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainButtonTextColor3.name: const Color(0xFF5B6CFF),
    AppThemeKeys.transparentBgColor.name: const Color.fromRGBO(0, 0, 0, 0.2),
    AppThemeKeys.alertBgColor.name: const Color(0xFF000000).withAlpha(204),
    AppThemeKeys.textColorGrey.name: const Color(0xFFCDCBCB),
    AppThemeKeys.mainGreyColor.name: Colors.grey,
    AppThemeKeys.ff444444.name: const Color(0xFF444444),
    AppThemeKeys.textFieldHintColor.name: const Color(0xFFBAC2CC),
    AppThemeKeys.hintTextColor.name: const Color(0xFFCCCCCC),
    AppThemeKeys.iconTextDisableColor.name: const Color(0xffEDEFF2),
    AppThemeKeys.timeBorderColor.name: const Color(0xffD1E4FE),
  };

  /// Dark theme colors
  static final Map<String, Color> darkMap = {
    AppThemeKeys.backGroundColor.name: const Color(0xFF0E0F13),
    AppThemeKeys.backGroundColor2.name: const Color(0xFF0E0F13),
    AppThemeKeys.backGroundColor3.name: const Color(0xff000000),
    AppThemeKeys.linearGradient1.name: const Color(0xff232323),
    AppThemeKeys.linearGradient2.name: const Color(0x80000000),
    AppThemeKeys.mainBlueColor.name: const Color(0xFF5B6CFF),
    AppThemeKeys.mainTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainTextColor3.name: const Color(0xFFbebebe),
    AppThemeKeys.mainTextColor4.name: const Color(0xFF6B7180),
    AppThemeKeys.mainTextColor5.name: const Color(0xFF222222),
    AppThemeKeys.mainTextColor6.name: const Color(0xFFA4A9B5),
    AppThemeKeys.mainTextColor7.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainTextColor8.name: const Color(0xFFBEBEBE),
    AppThemeKeys.mainTextColor10.name: const Color(0xFFD9D9D9),
    AppThemeKeys.mainWhiteColor.name: Colors.white,
    AppThemeKeys.mainBlockColor.name: Colors.black,
    AppThemeKeys.refreshBGColor.name: const Color(0xFF5B6CFF),
    AppThemeKeys.refreshValueColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.ff888888.name: Colors.white38,
    AppThemeKeys.itemBgColor.name: const Color(0xFF16181F),
    AppThemeKeys.itemBgColor2.name: const Color(0xFF232427),
    AppThemeKeys.itemBgColor4.name: const Color(0xFF373739),
    AppThemeKeys.itemBgColor5.name: const Color(0xFF232323),
    AppThemeKeys.itemBgColor6.name: const Color(0xFF16181F),
    AppThemeKeys.itemBgColor8.name: const Color(0xFFEBEBEB),
    AppThemeKeys.itemTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.itemSubtitleTextColor.name: const Color(0xFF9AA3B2),
    AppThemeKeys.itemBorderColor.name: const Color(0xFF2A2D38),
    AppThemeKeys.itemLineColor.name: const Color(0x50E4E4E4),
    AppThemeKeys.errorBgColor.name: const Color(0xFFFFF3EC),
    AppThemeKeys.errorBgColor2.name: const Color(0xFFFF5C6C).withAlpha(51),
    AppThemeKeys.errorTextColor.name: const Color(0xFFFF5C6C),
    AppThemeKeys.rightTextColor.name: const Color(0xff2ED391),
    AppThemeKeys.textColorOrange.name: const Color(0xFFFFA53D),
    AppThemeKeys.dividerColor.name: const Color(0xff2A2D38),
    AppThemeKeys.mainButtonBgColor.name: const Color(0xFF5B6CFF),
    AppThemeKeys.mainButtonBgColor3.name: const Color(0xFF2A3D5C),
    AppThemeKeys.mainButtonTextColor.name: const Color(0xFFFFFFFF),
    AppThemeKeys.mainButtonTextColor3.name: const Color(0xFF8B95FF),
    AppThemeKeys.transparentBgColor.name: const Color.fromRGBO(0, 0, 0, 0.2),
    AppThemeKeys.alertBgColor.name: const Color(0xFFffffff),
    AppThemeKeys.textColorGrey.name: const Color(0xFFCDCBCB),
    AppThemeKeys.mainGreyColor.name: Colors.grey,
    AppThemeKeys.ff444444.name: Colors.white70,
    AppThemeKeys.textFieldHintColor.name: const Color(0xFFBEBEBE),
    AppThemeKeys.hintTextColor.name: const Color(0xFF545454),
    AppThemeKeys.iconTextDisableColor.name: const Color(0xff373739),
    AppThemeKeys.timeBorderColor.name: const Color(0xff373739),
  };
}

/// Theme Color Keys
enum AppThemeKeys {
  backGroundColor,
  backGroundColor2,
  backGroundColor3,
  linearGradient1,
  linearGradient2,
  mainBlueColor,
  mainTextColor,
  mainTextColor3,
  mainTextColor4,
  mainTextColor5,
  mainTextColor6,
  mainTextColor7,
  mainTextColor8,
  mainTextColor10,
  mainWhiteColor,
  mainBlockColor,
  refreshBGColor,
  refreshValueColor,
  ff888888,
  itemBgColor,
  itemBgColor2,
  itemBgColor4,
  itemBgColor5,
  itemBgColor6,
  itemBgColor8,
  itemTextColor,
  itemSubtitleTextColor,
  itemBorderColor,
  itemLineColor,
  errorBgColor,
  errorBgColor2,
  errorTextColor,
  rightTextColor,
  textColorOrange,
  dividerColor,
  mainButtonBgColor,
  mainButtonBgColor3,
  mainButtonTextColor,
  mainButtonTextColor3,
  transparentBgColor,
  alertBgColor,
  textColorGrey,
  mainGreyColor,
  ff444444,
  textFieldHintColor,
  hintTextColor,
  iconTextDisableColor,
  timeBorderColor,
}
