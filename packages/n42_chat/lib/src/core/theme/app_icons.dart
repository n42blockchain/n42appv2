import 'package:flutter/material.dart';

/// 应用统一图标常量
///
/// 各页面的图标语义化引用，避免散落的 `Icons.X` 字面量与同义不同名（如
/// `arrow_back_ios` vs `arrow_back_ios_new` vs `arrow_back_ios_new_rounded`）。
abstract class AppIcons {
  AppIcons._();

  /// 返回按钮（iOS 风格圆角）
  static const IconData back = Icons.arrow_back_ios_new_rounded;

  /// 关闭按钮
  static const IconData close = Icons.close_rounded;

  /// 添加（圆形 +）
  static const IconData add = Icons.add_circle_outline;

  /// 列表 chevron（详情进入指示）
  static const IconData chevron = Icons.chevron_right_rounded;

  /// 搜索图标（圆角）
  static const IconData search = Icons.search_rounded;

  /// 更多（三点菜单）
  static const IconData more = Icons.more_horiz_rounded;
}
