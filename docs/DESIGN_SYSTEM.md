# N42 设计规范（Design System）

> 单一事实来源（SSOT）。所有 UI 改动以本文件为基线；新代码不得引入未登记的色值/字号/间距/圆角。
> 适用范围：主程序 `n42appv2`、聊天插件 `n42_chat`（独立 repo）、直播模块 `features/live`。
> 配套工具：`/ui-review` skill（`.claude/skills/ui-review/`）按本规范审查任意页面并产出整改补丁。

版本：v1.1（2026-06-07，克制现代/AI 风细调：深冷中性 + 提亮语义 + 标题负字距，令牌实现已对齐本规范）· 维护：UI/UE 小组

---

## 0. 设计基调（Design Language）

**克制版「深色优先 · 现代加密钱包」。**

- **深色优先**：钱包/交易/DeFi/挖矿是 App 主体，行业惯例（Binance / OKX / MetaMask / Phantom）皆深色优先——突出数字、护眼、专业感；直播本就深色竖屏。**亮色主题必须保留**（已有双套），但设计先在深色下定稿。
- **单一品牌强调**：全局 CTA / 链接 / 选中态统一用品牌蓝 `#1976F9`（可被用户 accent 覆盖）。聊天气泡的微信绿仅作为**聊天语境专用语义色**保留，不外溢到钱包/直播。
- **层级靠对比而非装饰**：用背景分层（base → surface → elevated）+ 字重/字号建立层级，少用边框和阴影。
- **玻璃拟态/渐变克制**：仅用于浮层、直播间叠层、首页资产卡高光；列表/表单/详情页保持纯色，杜绝满屏渐变。
- **动效服务于反馈**：默认 `fast 150ms / base 250ms`，仅用于状态切换、入场、点赞飘心；不做无意义循环动画。

---

## 1. 设计令牌（Design Tokens）

令牌是规范的可执行载体。落地为 Dart 常量类，**禁止**在业务代码里再写裸 `Color(0x...)` / `fontSize: 28` / `EdgeInsets.all(16)`。

> 单位说明：主程序用 `flutter_screenutil`，设计基准 **750×1334（=375 逻辑宽的 2×）**。故下表「token 值」是 `.w / .sp` 传入值（≈逻辑像素 ×2）；括号内为 375 基准下的等效 dp，便于和 chat（M3，逻辑像素）对齐。chat repo 直接用括号内的逻辑像素值。

### 1.1 颜色 · 语义令牌（跨 repo 统一）

品牌与语义色统一一套，**两个 repo 数值必须一致**：

| 语义 | Token | Light | Dark | 用途 |
|---|---|---|---|---|
| 品牌主色 | `brand` | `#1976F9` | `#3B8CFF` | 主 CTA、链接、选中、进度 |
| 品牌弱 | `brandSubtle` | `#E8F1FE` | `#16365E` | 主色背景填充、选中底 |
| 成功 | `success` | `#1FB67A` | `#2ED391` | 涨、成功、确认 |
| 危险 | `danger` | `#F23D52` | `#FF5C6C` | 跌、失败、删除、风险 |
| 警告 | `warning` | `#FF8A1F` | `#FFA53D` | 警示、待处理 |
| 信息 | `info` | `#2E90FA` | `#52A6FF` | 中性提示 |
| 聊天-自气泡 | `chatBubbleSelf` | `#95EC69` | `#3EB575` | **仅聊天**，勿外溢 |

> 涨跌色遵循国内习惯（红涨绿跌）时，用 `danger`=涨、`success`=跌的语义映射在业务层切换，**不要新增色值**。

### 1.2 颜色 · 中性分层（深色优先）

| 角色 | Token | Dark | Light | 说明 |
|---|---|---|---|---|
| 背景底 | `bgBase` | `#0E0F13` | `#F5F6F8` | Scaffold 最底 |
| 表面 | `bgSurface` | `#16181F` | `#FFFFFF` | 卡片、列表项 |
| 浮起 | `bgElevated` | `#1E212B` | `#FFFFFF` | 弹窗、BottomSheet、菜单 |
| 分隔线 | `border` | `#2A2D38` | `#E6E8EC` | 描边、分割 |
| 文字主 | `textPrimary` | `#FFFFFF` | `#1A1C22` | 标题、关键数字 |
| 文字次 | `textSecondary` | `#A4A9B5` | `#5B6270` | 副文本、说明 |
| 文字弱 | `textTertiary` | `#6B7180` | `#9AA0AC` | 占位、时间戳、禁用 |
| 反白覆盖 | `overlay` | `rgba(0,0,0,.55)` | 同 | 直播/图片上叠层 |

> 主程序现有 `AppThemeKeys`/`lightMap`/`darkMap` 不推翻——把上表登记为**语义别名**映射到现有 key，新代码只引用语义名。chat 现有 `AppColors` 同理收口。

### 1.3 字阶（Typography）

字体族：跟随系统（iOS SF / Android Roboto），不内嵌字体。字重仅用 `w400 / w500 / w600`。
**大标题紧排**：`displayLg/titleLg/title/headline` 带轻微负字距（-0.5 ~ -0.2），现代/AI 产品的紧致标题质感；正文及以下不加字距。

| Token | size (.sp / dp) | weight | 行高 | 用途 |
|---|---|---|---|---|
| `displayLg` | 48 / 24 | 600 | 1.2 | 资产总额、开屏大数字 |
| `titleLg` | 40 / 20 | 600 | 1.25 | 页面大标题 |
| `title` | 36 / 18 | 600 | 1.3 | 卡片标题、AppBar |
| `headline` | 32 / 16 | 600 | 1.3 | 小节标题、重要项 |
| `body` | 28 / 14 | 400 | 1.4 | 正文（默认） |
| `bodyStrong` | 28 / 14 | 600 | 1.4 | 正文强调、金额 |
| `bodySm` | 26 / 13 | 400 | 1.4 | 次要正文 |
| `caption` | 24 / 12 | 400 | 1.3 | 时间戳、辅助 |
| `captionSm` | 20 / 10 | 500 | 1.2 | 标签、徽章 |

> 收敛规则：现有散落的 `30/31` 一律就近归并到 `28` 或 `32`；`22/23` 归 `24`。

### 1.4 间距（Spacing，8pt 网格）

| Token | .w / dp | 典型用途 |
|---|---|---|
| `space2` | 8 / 4 | 图标与文字、紧凑内距 |
| `space4` | 16 / 8 | 元素间最小间距 |
| `space6` | 24 / 12 | 卡片内距、行距 |
| `space8` | 32 / 16 | **页面水平边距（标准）**、卡片间距 |
| `space12` | 48 / 24 | 区块间距 |
| `space16` | 64 / 32 | 大区块、空状态留白 |

> 收敛规则：现有 `30→32`、`20→16 或 24`、`10→8`。页面统一左右 `space8`。

### 1.5 圆角（Radius）

| Token | .w / dp | 用途 |
|---|---|---|
| `radiusSm` | 8 / 4 | 标签、徽章、小输入 |
| `radiusMd` | 16 / 8 | 二级卡片、图片 |
| `radiusLg` | 24 / 12 | 弹窗内卡片 |
| `radiusXl` | 32 / 16 | **主卡片 / 按钮（标准）** |
| `radiusSheet` | 40 / 20 | BottomSheet / Dialog 顶部 |
| `radiusPill` | 999 | 胶囊按钮、头像角标 |

> chat 消息气泡保留「三角 14dp + 一角 4dp」的微信特征，登记为 `radiusBubble`/`radiusBubbleTail`，不并入通用阶。

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
- 三类：**Primary**（`brand` 填充，白字，`radiusXl`，高 ≈ 96.h/48dp）、**Secondary**（`border` 描边，`textPrimary`）、**Text/Ghost**（无底，`brand` 字）。
- 危险操作用 Primary + `danger` 底。禁用态：`textTertiary` 字 + `bgSurface` 底，不可点。
- **必须有按压态**（透明度或缩放 `durFast`）与 loading 态（替换文案为 spinner）。
- 主程序 `button_widget.dart` 的 6 个 styleN 收敛映射到这三类，逐步弃用裸样式。

### 2.2 卡片 / 列表项
- 统一 `AppCard`：`bgSurface` + `radiusXl` + 内距 `space6/space8` + `elevCard`。各 feature **禁止**再自造 card 容器。
- 列表项最小可点高度 **≥ 48dp**；左右边距 `space8`；分隔线 `border` 1px，左缩进与内容对齐。

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
- 支持系统字号放大不溢出（`minTextAdapt` 已开，关键页验证 130%）。

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
4. **回归**：每模块 `flutter analyze` + 截图前后对比；关键页验证亮/暗双主题 + 130% 字号。

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
