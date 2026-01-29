// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter/material.dart';

/// Standard spacing values
///
/// Use these constants for consistent spacing throughout the app.
/// Based on an 4px grid system for visual harmony.
abstract class AppSpacing {
  AppSpacing._();

  /// 4px - Extra small spacing
  static const double xs = 4;

  /// 8px - Small spacing
  static const double sm = 8;

  /// 12px - Medium spacing
  static const double md = 12;

  /// 16px - Large spacing
  static const double lg = 16;

  /// 24px - Extra large spacing
  static const double xl = 24;

  /// 32px - 2x extra large spacing
  static const double xxl = 32;

  /// 48px - 3x extra large spacing
  static const double xxxl = 48;

  /// 64px - 4x extra large spacing
  static const double huge = 64;

  // Insets (EdgeInsets helpers)

  /// All sides xs (4px)
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// All sides sm (8px)
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// All sides md (12px)
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// All sides lg (16px)
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// All sides xl (24px)
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// Horizontal sm (8px)
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal md (12px)
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal lg (16px)
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Vertical sm (8px)
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Vertical md (12px)
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// Vertical lg (16px)
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  // SizedBox helpers for use as spacers

  /// Vertical spacer xs (4px)
  static const SizedBox verticalXs = SizedBox(height: xs);

  /// Vertical spacer sm (8px)
  static const SizedBox verticalSmBox = SizedBox(height: sm);

  /// Vertical spacer md (12px)
  static const SizedBox verticalMdBox = SizedBox(height: md);

  /// Vertical spacer lg (16px)
  static const SizedBox verticalLgBox = SizedBox(height: lg);

  /// Vertical spacer xl (24px)
  static const SizedBox verticalXlBox = SizedBox(height: xl);

  /// Horizontal spacer xs (4px)
  static const SizedBox horizontalXsBox = SizedBox(width: xs);

  /// Horizontal spacer sm (8px)
  static const SizedBox horizontalSmBox = SizedBox(width: sm);

  /// Horizontal spacer md (12px)
  static const SizedBox horizontalMdBox = SizedBox(width: md);

  /// Horizontal spacer lg (16px)
  static const SizedBox horizontalLgBox = SizedBox(width: lg);

  /// Horizontal spacer xl (24px)
  static const SizedBox horizontalXlBox = SizedBox(width: xl);
}

/// Standard border radius values
abstract class AppRadius {
  AppRadius._();

  /// 4px - Small radius
  static const double sm = 4;

  /// 8px - Medium radius
  static const double md = 8;

  /// 12px - Large radius
  static const double lg = 12;

  /// 16px - Extra large radius
  static const double xl = 16;

  /// 24px - 2x extra large radius
  static const double xxl = 24;

  /// 999px - Pill/circular radius
  static const double pill = 999;

  // BorderRadius helpers

  /// All corners sm (4px)
  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));

  /// All corners md (8px)
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));

  /// All corners lg (12px)
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));

  /// All corners xl (16px)
  static const BorderRadius allXl = BorderRadius.all(Radius.circular(xl));

  /// All corners pill (circular)
  static const BorderRadius allPill = BorderRadius.all(Radius.circular(pill));

  /// Top corners md (8px)
  static const BorderRadius topMd = BorderRadius.vertical(
    top: Radius.circular(md),
  );

  /// Top corners lg (12px)
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(lg),
  );

  /// Bottom corners md (8px)
  static const BorderRadius bottomMd = BorderRadius.vertical(
    bottom: Radius.circular(md),
  );

  /// Bottom corners lg (12px)
  static const BorderRadius bottomLg = BorderRadius.vertical(
    bottom: Radius.circular(lg),
  );
}

/// Standard icon sizes
abstract class AppIconSize {
  AppIconSize._();

  /// 16px - Extra small icon
  static const double xs = 16;

  /// 20px - Small icon
  static const double sm = 20;

  /// 24px - Medium icon (default)
  static const double md = 24;

  /// 32px - Large icon
  static const double lg = 32;

  /// 48px - Extra large icon
  static const double xl = 48;

  /// 64px - 2x extra large icon
  static const double xxl = 64;
}

/// Standard avatar sizes
abstract class AppAvatarSize {
  AppAvatarSize._();

  /// 24px - Extra small avatar
  static const double xs = 24;

  /// 32px - Small avatar
  static const double sm = 32;

  /// 40px - Medium avatar
  static const double md = 40;

  /// 48px - Large avatar
  static const double lg = 48;

  /// 64px - Extra large avatar
  static const double xl = 64;

  /// 96px - 2x extra large avatar
  static const double xxl = 96;
}

/// Standard button heights
abstract class AppButtonHeight {
  AppButtonHeight._();

  /// 32px - Small button
  static const double sm = 32;

  /// 40px - Medium button
  static const double md = 40;

  /// 48px - Large button (default)
  static const double lg = 48;

  /// 56px - Extra large button
  static const double xl = 56;
}
