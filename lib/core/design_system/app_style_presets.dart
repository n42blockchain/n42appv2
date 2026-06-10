import 'package:flutter/material.dart';

/// 风格预设（Style Preset）。
///
/// 一套「风格」= 品牌强调色 + 推荐明暗模式。选中某风格时，强调色会经
/// `colorScheme.primary` / `AppColorTokens.brand` 全 App 传播（CTA、强调、
/// 选中态、焦点、进度条、导航高亮等全部跟随），从而呈现一致的整体观感。
///
/// 设计人员可直接在 [AppStylePresets.all] 增删/调整预设；详见
/// `docs/DESIGN_STYLES.md`。字阶 / 间距 / 圆角是跨风格统一的（有意为之，
/// 保证产品节奏一致），故不在风格预设里变动。
@immutable
class StylePreset {
  /// 稳定标识（用于匹配「当前风格」，**勿随意改名**，否则历史选择失配）。
  final String id;

  /// 显示名（中文）。如需多语言：把它换成 l10n key，见文档「本地化」。
  final String name;

  /// 一句话风格描述（设计意图）。
  final String description;

  /// 品牌强调色——驱动全 App 的 `colorScheme.primary`。
  final Color accent;

  /// 推荐明暗模式（选风格时一并应用；用户之后仍可单独切换明暗）。
  final ThemeMode mode;

  const StylePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.accent,
    required this.mode,
  });
}

/// 内置风格预设清单。**设计人员的主要编辑入口。**
abstract final class AppStylePresets {
  AppStylePresets._();

  static const List<StylePreset> all = <StylePreset>[
    StylePreset(
      id: 'ai_indigo',
      name: 'AI 靛蓝',
      description: '默认 · AI-native 现代加密钱包基调',
      accent: Color(0xFF5B6CFF),
      mode: ThemeMode.system,
    ),
    StylePreset(
      id: 'deep_space',
      name: '深空',
      description: '深色优先 · 沉浸专注',
      accent: Color(0xFF5B6CFF),
      mode: ThemeMode.dark,
    ),
    StylePreset(
      id: 'emerald',
      name: '翡翠',
      description: '清新 · 信任感',
      accent: Color(0xFF00A884),
      mode: ThemeMode.light,
    ),
    StylePreset(
      id: 'amethyst',
      name: '暗夜紫',
      description: '神秘 · 高端质感',
      accent: Color(0xFF8B5CF6),
      mode: ThemeMode.dark,
    ),
    StylePreset(
      id: 'sunset',
      name: '活力橙',
      description: '热情 · 活跃',
      accent: Color(0xFFF97316),
      mode: ThemeMode.light,
    ),
    StylePreset(
      id: 'classic_blue',
      name: '经典蓝',
      description: '稳重 · 经典品牌色',
      accent: Color(0xFF1976F9),
      mode: ThemeMode.system,
    ),
    StylePreset(
      id: 'rose',
      name: '玫瑰',
      description: '柔和 · 亲和',
      accent: Color(0xFFE5447B),
      mode: ThemeMode.light,
    ),
  ];

  /// 默认风格（首个）。
  static StylePreset get defaultPreset => all.first;

  /// 根据当前 (accent, mode) 反查命中的预设；都不匹配返回 null（= 自定义）。
  static StylePreset? match(Color accent, ThemeMode mode) {
    final argb = accent.toARGB32();
    for (final p in all) {
      if (p.accent.toARGB32() == argb && p.mode == mode) return p;
    }
    return null;
  }
}
