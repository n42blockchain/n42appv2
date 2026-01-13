// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:flutter/material.dart';

/// Theme mode conversion utilities - single source of truth
class ThemeModeUtils {
  ThemeModeUtils._();

  static ThemeMode fromInt(int value) => switch (value) {
    1 => ThemeMode.light,
    2 => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static int toInt(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 1,
    ThemeMode.dark => 2,
    ThemeMode.system => 0,
  };
}
