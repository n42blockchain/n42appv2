import 'package:flutter/widgets.dart';

/// Logical-point spacing shared across phones, landscape and expanded scenes.
/// The 4pt rhythm and 16pt margins are product tokens, not fixed HIG mandates.
abstract final class AppSpacing {
  static double get space2 => 4; // ≈4dp 图标与文字、紧凑内距
  static double get space4 => 8; // ≈8dp 元素最小间距
  static double get space6 => 12; // ≈12dp 卡片内距、行距
  static double get space8 => 16; // ≈16dp 标准页边距、卡片间距
  static double get space12 => 24; // ≈24dp 区块间距
  static double get space16 => 32; // ≈32dp 大区块、空状态留白

  /// 标准页面水平内距。
  static EdgeInsets get pageHorizontal =>
      EdgeInsets.symmetric(horizontal: space8);

  /// 标准卡片内距。
  static EdgeInsets get cardInset =>
      EdgeInsets.symmetric(horizontal: space6, vertical: space6);
}
