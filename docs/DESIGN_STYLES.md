# N42 钱包 · 设计风格说明（给设计人员）

> 配套技术规范见 [`DESIGN_SYSTEM.md`](./DESIGN_SYSTEM.md)。本文面向设计人员，
> 讲清楚「整个 App 的视觉由哪些令牌决定」「有哪几套可切换风格」「怎么新增/调整一套风格」。

---

## 1. 一句话原理

App 的所有 UI 颜色、字号、间距、圆角都来自一套**设计令牌（design tokens）**，
业务页面不再写死颜色/字号。其中**品牌强调色**是可在运行时切换的——换一个强调色，
全 App 的 CTA 按钮、强调文字、选中态、输入框焦点、进度条、导航高亮会**一起变**。

一套「**风格（Style）**」就是：**品牌强调色 + 推荐的明暗模式**。切换风格 = 同时换这两样，
立刻得到一种统一的整体观感。

---

## 2. 设计令牌速查

| 维度 | 令牌 | 可否随风格切换 | 说明 |
|---|---|---|---|
| **品牌强调色** | `AppColorTokens.brand`（= `colorScheme.primary`） | ✅ **可切换**（风格核心） | CTA / 强调 / 选中 / 焦点 / 进度 / 导航高亮 全部跟随 |
| 语义色 | `success`(绿) `danger`(红) `warning`(橙) `info`(蓝) | ❌ 固定 | 成功/失败/警示语义，跨风格统一不混淆 |
| 中性/文字 | `textPrimary` `textSecondary` `textTertiary` `textSubtitle` | ❌ 固定（随明暗自适应） | 文字分层 |
| 背景/层次 | `bgBase` `bgSurface` `bgElevated` `border` | ❌ 固定（随明暗自适应） | 页面/卡片/分隔 |
| 字阶 | `AppTypography.displayXl/displayLg/titleLg/title/headline/body/bodySm/caption/captionSm` | ❌ 固定 | 9 级字阶 + hero 档；字重仅 w400/w500/w600 |
| 间距 | `AppSpacing.space2/4/6/8/12/16`（8pt 网格） | ❌ 固定 | 统一节奏 |
| 圆角 | `AppRadius.sm/md/lg/xl/sheet/pill` | ❌ 固定 | 统一圆润度 |
| 动效 | `AppMotion.fast(150ms)/base(250ms)/slow(400ms)` + 曲线 | ❌ 固定 | 统一手感 |

> **为什么字阶/间距/圆角不随风格变？** 这些决定产品的「节奏与骨架」，跨风格保持一致才显专业、
> 不割裂。风格之间的差异通过**品牌色 + 明暗**表达，已足够拉开观感。如确有「圆润 vs 硬朗」
> 等结构性诉求，需走令牌层改造（工作量大），请与研发评估。

---

## 3. 内置风格（当前 7 套）

| 风格 | 品牌色 | 推荐模式 | 气质 |
|---|---|---|---|
| **AI 靛蓝**（默认） | `#5B6CFF` | 跟随系统 | AI-native 现代加密钱包基调 |
| **深空** | `#5B6CFF` | 深色 | 深色优先 · 沉浸专注 |
| **翡翠** | `#00A884` | 浅色 | 清新 · 信任感 |
| **暗夜紫** | `#8B5CF6` | 深色 | 神秘 · 高端质感 |
| **活力橙** | `#F97316` | 浅色 | 热情 · 活跃 |
| **经典蓝** | `#1976F9` | 跟随系统 | 稳重 · 经典品牌色（旧版） |
| **玫瑰** | `#E5447B` | 浅色 | 柔和 · 亲和 |

清单定义在 `lib/core/design_system/app_style_presets.dart` 的 `AppStylePresets.all`。

---

## 4. 用户在哪里切换

**设置 → 主题（`g_key_126`）页面**，从上到下：

1. **风格** —— 7 张风格卡片（品牌色预览 + 明暗图标 + 名称 + 描述）。点一下即整体切换（同时应用品牌色与明暗）。当前命中的风格会高亮；若用户单独微调过颜色/明暗，则显示「自定义」。
2. **外观** —— 单独切 深色 / 浅色 / 跟随系统。
3. **强调色** —— 8 个色点供精细微调单一品牌色（+「重置为默认」）。

> 风格切换是「快捷整套」，下面两节是「精细微调」。三者共用同一份持久化状态
> （`accentColorProvider` + `themeModeProvider`），改任何一处都会立即全 App 生效并记住。

---

## 5. 如何新增 / 调整一套风格

只需改一个文件：`lib/core/design_system/app_style_presets.dart`。

在 `AppStylePresets.all` 列表里加一项：

```dart
StylePreset(
  id: 'ocean',                 // 稳定标识，勿改名（用于记住用户选择）
  name: '深海',                 // 显示名（中文）
  description: '冷静 · 专业',    // 一句话设计意图
  accent: Color(0xFF0EA5E9),   // 品牌强调色（驱动全 App）
  mode: ThemeMode.dark,        // 推荐明暗：dark / light / system
),
```

保存即生效，切换页会自动多出这张卡片。**无需改其它任何文件。**

### 选色注意（无障碍红线，规范 §5）

- 品牌色要在**深色与浅色背景上都有足够对比度**（用作按钮底色时其上为白字，需 ≥ 4.5:1）。
- 避免与语义色撞色：别选接近 `success` 绿 / `danger` 红 / `warning` 橙的色，否则用户会把品牌强调误读成「成功/危险/警告」。
- 太浅的色（如柠檬黄）做按钮底 + 白字会看不清，慎选。

---

## 6. 本地化（可选）

风格的 `name` / `description` 目前是中文字面量（便于设计直接编辑）。若需多语言：

1. 在 `lib/l10n/intl_en.arb`（模板）加 key，如 `"g_style_ocean": "Ocean"`；各语言 ARB 补译。
2. `flutter pub run intl_utils:generate` 重新生成。
3. 把 `StylePreset.name` 换成在 UI 里 `S.of(context).g_style_ocean` 读取（需把 `name`
   改成 `String Function(BuildContext)`，请与研发配合）。

章节标题「风格 / 外观 / 强调色」已走 l10n（`g_theme_style` / `g_theme_mode` / `g_theme_accent_color`），
新语言只需补这几条翻译。

---

## 7. 给设计的协作清单

- 要加风格 → 给出 **名称 + 一句话气质 + 品牌色 hex + 推荐明暗**，研发 1 行代码即可上。
- 要改默认风格 → 说明新默认品牌色；研发改 `ThemeAdapter.defaultAccent` + 把该预设放到 `all` 首位。
- 验收一套风格请在**深色与浅色都看一遍**：CTA 按钮、选中态、输入框焦点、底部导航、空状态。
- 不要在业务稿里指定散落的具体 hex/字号——只描述「用品牌色 / 用 success 绿 / 用 body 字阶」，
  研发对应到令牌，未来换风格才不会失控。
