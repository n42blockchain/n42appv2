import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Apple's default Dynamic Type scale in logical points. Screen width never
/// changes type size; MediaQuery's TextScaler handles accessibility scaling.
abstract final class AppTypography {
  static bool get _apple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static TextStyle _style(
    double size,
    double leading,
    double tracking, [
    FontWeight weight = FontWeight.w400,
  ]) => TextStyle(
    fontFamily: _apple
        ? (size >= 20 ? 'CupertinoSystemDisplay' : 'CupertinoSystemText')
        : null,
    fontSize: size,
    fontWeight: weight,
    height: leading / size,
    letterSpacing: tracking,
  );

  static TextStyle get displayXl => _style(34, 41, 0.38, FontWeight.w700);
  static TextStyle get displayLg => _style(28, 34, 0.36);
  static TextStyle get titleLg => _style(22, 28, 0.35);
  static TextStyle get title => _style(20, 25, 0.38);
  static TextStyle get headline => _style(17, 22, -0.41, FontWeight.w600);
  static TextStyle get body => _style(17, 22, -0.41);
  static TextStyle get bodyStrong => _style(17, 22, -0.41, FontWeight.w600);
  static TextStyle get bodySm => _style(15, 20, -0.23);
  static TextStyle get subheadline => _style(15, 20, -0.23);
  static TextStyle get footnote => _style(13, 18, -0.08);
  static TextStyle get caption => _style(12, 16, 0);
  static TextStyle get captionSm => _style(11, 13, 0.07);

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayXl,
    displayMedium: displayLg,
    displaySmall: titleLg,
    headlineLarge: displayLg,
    headlineMedium: titleLg,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: headline,
    titleSmall: subheadline,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: footnote,
    labelLarge: headline,
    labelMedium: caption,
    labelSmall: captionSm,
  );
}
