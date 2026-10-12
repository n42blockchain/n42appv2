# N42 设计规范（Design System）

> 单一事实来源（SSOT）。所有 UI 改动以本文件为基线；新代码不得引入未登记的色值/字号/间距/圆角。
> 适用范围：主程序 `n42appv2`、聊天插件 `n42_chat`（独立 repo）、直播模块 `features/live`。
> 配套工具：`/ui-review` skill（`.claude/skills/ui-review/`）按本规范审查任意页面并产出整改补丁。

版本：v2.0（2026-10-12，Apple 默认字阶、系统配色与逻辑点控件）· 维护：UI/UE 小组

---

## 0. 设计基调

默认使用 Apple 系统蓝、系统明暗中性色和语义颜色。保留菜单中全部旧配色预设、强调色选择和已保存的自定义选择；没有自定义选择时才使用新的 Apple 默认配色。明暗模式仍可分别选择。

字体、字阶、间距、圆角和触控规范跨配色保持一致。iOS/macOS 使用系统 SF Text/Display，其他平台使用系统字体回退。字体不随屏幕宽度放大或缩小，文字缩放通过系统 TextScaler 生效。

规范来源：[Apple Typography](https://developer.apple.com/design/human-interface-guidelines/typography)、[Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)、[Layout](https://developer.apple.com/design/human-interface-guidelines/layout)、[WWDC UI typography](https://developer.apple.com/videos/play/wwdc2020/10175/)。Flutter Cupertino 的系统字体别名和字距也作为实现参考。4pt 间距节奏、16pt 页边距和圆角档位是产品统一令牌；Apple HIG 没有规定所有页面必须使用同一个间距或圆角。

---

## 1. 设计令牌（Design Tokens）

令牌是规范的可执行载体。落地为 Dart 常量类，**禁止**在业务代码里再写裸 `Color(0x...)` / `fontSize: 28` / `EdgeInsets.all(16)`。

> 单位：以下字体、间距、圆角和触控范围均使用逻辑点，不经过 `.sp/.w`。旧插图、导出位图、部分业务几何仍可保留 ScreenUtil 的 750 设计坐标。

### 1.1 默认系统配色

| 角色 | Light | Dark |
|---|---|---|
| 强调色 | 系统蓝 `#007AFF` | 系统蓝 `#0A84FF` |
| 页面底 | systemGroupedBackground `#F2F2F7` | `#000000` |
| 卡片/分组 | secondarySystemGroupedBackground `#FFFFFF` | `#1C1C1E` |
| 主文字 | label | label |
| 次文字 | secondaryLabel | secondaryLabel |
| 弱文字 | tertiaryLabel | tertiaryLabel |
| 分隔线 | separator | separator |
| 成功/错误/警示 | systemGreen / systemRed / systemOrange | 对应深色系统色 |

### 1.2 自定义配色与固定语义

`ThemeAdapter.defaultAccent` 表示 Apple 默认；旧靛蓝、翡翠、深空、暗夜紫等预设保留。自定义强调色经 ColorScheme 和主题令牌传播，保留旧中性色表。已保存的颜色不被覆盖，重置回 Apple 默认。聊天入口保留宿主主题，不再另行覆盖背景、字距和系统字号。

照片、视频和直播叠层继续使用固定白色文字/半透明黑底，保证内容上可读。币种标识、图表分类和插图颜色属于业务内容，不作为系统控件强调色。聊天默认自气泡使用系统蓝，独立聊天背景设置保留。

### 1.3 字阶

| Token | 字号 | 字重 | 行高 | 字距 |
|---|---:|---:|---:|---:|
| displayXl | 34 | 700 | 41 | 0.38 |
| displayLg | 28 | 400 | 34 | 0.36 |
| titleLg | 22 | 400 | 28 | 0.35 |
| title | 20 | 400 | 25 | 0.38 |
| headline | 17 | 600 | 22 | -0.41 |
| body / bodyStrong | 17 | 400 / 600 | 22 | -0.41 |
| bodySm / subheadline | 15 | 400 | 20 | -0.23 |
| footnote | 13 | 400 | 18 | -0.08 |
| caption | 12 | 400 | 16 | 0 |
| captionSm | 11 | 400 | 13 | 0.07 |

字号使用默认 Dynamic Type 字阶；系统缩放不被截断。字体与字距采用 Cupertino/Apple 系统指标，不再统一加负字距。OTP 数字分组和开屏品牌字标可保留功能性字距；普通正文、标题、金额沿用语义样式。

### 1.4 间距

| Token | 逻辑点 | 用途 |
|---|---:|---|
| space2 | 4 | 紧凑内距 |
| space4 | 8 | 元素间距 |
| space6 | 12 | 卡片内距 |
| space8 | 16 | 页面水平边距、卡片间距 |
| space12 | 24 | 区块间距 |
| space16 | 32 | 大区块、空状态 |

### 1.5 圆角与触控

圆角档位为 4 / 8 / 12 / 16 / 20pt，使用现有 AppRadius 名称。共用主按钮使用 12pt，面板顶部使用 20pt。

触控范围至少 44×44pt。按钮、输入和导航使用最小高度；大字可以增加高度，不能压缩字体来适应固定高度。短屏内容允许滚动。钱包筛选栏在窄屏或大字下改为多行，固定头部的高度与内容一致。

### 1.6 高度 / 阴影（Elevation）

深色优先下**少用阴影、多用背景分层**。仅三档：

| Token | 用途 | 实现 |
|---|---|---|
| `elevFlat` | 列表项、AppBar | 无阴影，靠 `bgSurface` 与 `bgBase` 对比 |
| `elevCard` | 浮起卡片 | 暗色：`bgElevated` + 1px `border`；亮色：`y2 blur8 black8%` |
| `elevModal` | 弹窗/菜单 | 暗色：`bgElevated` + `overlay` 背景遮罩；亮色：`y8 blur24 black12%` |

### 1.7 动效（Motion）

| Token | 时长 | 曲线 | 用途 |
|---|---|---|---|
| `durFast` | 150ms | `easeOut` | 点击反馈、开关 |
| `durBase` | 250ms | `easeInOut` | 页面/弹窗入场 |
| `durSlow` | 400ms | `easeInOutCubic` | 飘心、强调 |

---

## 2. 组件准则（Component Guidelines）

### 2.1 按钮
- 三类：**Primary**（`brand` 填充，白字，`radiusLg`，最小 44pt、大字可增高）、**Secondary**（`border` 描边，`textPrimary`）、**Text/Ghost**（无底，`brand` 字）。
- 危险操作用 Primary + `danger` 底。禁用态：`textTertiary` 字 + `bgSurface` 底，不可点。
- **必须有按压态**（透明度或缩放 `durFast`）与 loading 态（替换文案为 spinner）。
- 主程序 `button_widget.dart` 的 6 个 styleN 收敛映射到这三类，逐步弃用裸样式。

### 2.2 卡片 / 列表项
- 统一 `AppCard`：`bgSurface` + `radiusXl` + 内距 `space6/space8` + `elevCard`。各 feature **禁止**再自造 card 容器。
- 列表项最小可点高度 **≥ 44pt**；左右边距 `space8`；分隔线 `border` 1px，左缩进与内容对齐。

### 2.3 输入框
- 统一 `AppTextField`：`bgSurface`/描边 `border`，聚焦描边 `brand`，错误描边 `danger` + 下方 `caption` 红字。
- 主程序 `text_field_widget.dart` 与 `comm_input.dart` 功能重叠，合并为一。

### 2.4 弹窗 / BottomSheet
- 统一 `AppDialog` / `AppSheet`：`bgElevated` + `radiusSheet` 顶角 + `overlay` 遮罩；标题 `title`，正文 `body`，操作区右对齐（次按钮在左）。
- 主程序 **7 个 `tips_dialog_*` 合并为 1 个参数化 `AppDialog`**（title / content / actions）。

### 2.5 反馈
- Toast/SnackBar：`bgElevated`，`body` 文案，≤ 2 行，默认 2s；错误用 `danger` 图标。
- 空状态：图标 + `headline` 标题 + `bodySm` 说明 + 可选 Primary 按钮，居中，上下 `space16`。
- Loading：列表用骨架屏优先，全屏用居中 spinner；**禁止**白屏无反馈。

### 2.6 无障碍 / 触控
- 触控目标 ≥ 44×44 dp。正文与背景对比度 ≥ 4.5:1，大字 ≥ 3:1。
- 不靠颜色单独传达状态（涨跌/成败需配图标或文字）。
- 支持系统字号放大不溢出（共享控件验证 100% / 160% / 200% / 300%，系统缩放不截断）。

### 2.7 徽章 / 状态药丸
- 统一 `AppBadge`：胶囊形（`radiusPill`），色调底（语义色 12% alpha）+ 同色文字（`captionSm`），可选前导**圆点** / **图标** / **自定义 leading**（承接「处理中」动画 spinner）。
- 色调 `AppBadgeTone`：`neutral`/`brand`/`success`/`warning`/`danger`/`info`，全部走 `AppColorTokens` 语义色，**禁止**裸 `Colors.green/orange/red`（§2.6 配图标，不靠颜色单独传达）。
- **仅用于显示态状态指示**（交易状态、节点/计划状态、在线数等），非交互。各 feature 散落的 `_buildStatusBadge`/`_buildStatusChip`/`buttonStyle3(onTap:null)` 逐步收敛至此（§2.2 禁重复）。
- **边界**：① **可点**的筛选 chip / tonal 小按钮不是 Badge（属按钮线）；② 贴在**品牌彩色卡 / 直播叠层**上的白底标签用固定叠层色或卡内反色，**不**用随主题的 `AppBadge`（否则亮色主题对比失效）。

---

## 3. 主题与跨 repo 一致性

- **主程序**：建 `lib/core/design_system/`（`app_color_tokens.dart` / `app_typography.dart` / `app_spacing.dart` / `app_radius.dart` / `app_motion.dart`），语义令牌映射到现有 `AppThemeKeys`。**启用 Material 3**（`useMaterial3: true`）作为后续目标，分页迁移。
- **chat 插件（n42_chat 独立 repo）**：已有 `AppColors`/`AppTextStyles`/`N42ChatTheme`（M3）。任务是①把品牌/语义色数值对齐 §1.1；②消除 100+ 处 `isDark ? a : b`，改用 `ColorToken.resolve(isDark)`；③补 `AppSpacing`/`AppRadius` 常量。**须在 n42_chat repo 改并发版**，主仓库缓存改动无效。
- **直播 `features/live`**：深色叠层场景，直接用语义令牌（`overlay`/`brand`/`textPrimary`）；现有 `Colors.black.withValues(alpha:.55)` 收敛为 `overlay`。

---

## 4. 落地路线（与 /ui-review 配合）

1. **建令牌层**（主程序 `core/design_system/` + chat 常量）——一次性，零行为变更。
2. **收敛重复组件**：`AppDialog`、`AppCard`、`AppTextField`、按钮三类。
3. **逐模块审查整改**：用 `/ui-review <feature>` 输出违规清单 + 补丁，按 feature 推进（建议序：直播 live → 钱包首页 wallet/home → 交易 swap/market → 挖矿 mining → 设置/个人 → chat）。
4. **回归**：每模块 `flutter analyze` + 截图前后对比；关键页验证亮/暗双主题 + 100%～300% 字号。

整改进度登记在 `docs/UI_POLISH_PROGRESS.md`（首次运行 /ui-review 时创建）。

---

## 5. 硬性红线（PR 检查项）

- [ ] 无新增裸 `Color(0x...)`（用语义令牌）。
- [ ] 无新增硬编码 `fontSize` / `EdgeInsets` 数字（用 typography / spacing 令牌）。
- [ ] 圆角取自 `radius*` 阶。
- [ ] 交互元素有按压/loading/禁用态。
- [ ] 触控目标 ≥ 44dp。
- [ ] 亮/暗双主题均验证。
- [ ] 不靠颜色单独传达状态。
