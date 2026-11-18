# UI 美化整改进度

依据 `docs/DESIGN_SYSTEM.md`，用 `/ui-review <模块>` 逐模块推进。每模块：审查 → 整改 → analyze + 双主题验证 → 登记。

## 令牌层（地基，零行为变更）✅ 2026-06-01
`lib/core/design_system/`：`AppColorTokens`（随主题语义色 + 固定叠层色两组）、`AppTypography`（9 级字阶）、`AppSpacing`（8pt 网格）、`AppRadius`、`AppMotion`。barrel `design_system.dart`。
中性/语义色映射现有 `AppThemeKeys` 主题表，保证迁移零视觉断层。

## 组件库（地基二）✅ 2026-06-01
`lib/core/design_system/widgets/`：`AppButton`（primary/secondary/text/danger/**warning** + loading/禁用；warning 用于 approve/unstake 等谨慎填充态，2026-06-06 加）、`AppCard`、`AppTextField`、`AppDialog`（+ `confirm` 便捷，替代 7 个 `tips_dialog`）、`AppEmptyState`、`showAppSheet`、**`AppBadge`**（2026-06-06 新增；胶囊状态徽章，6 色调 tone + dot/icon/leading，承接「处理中」spinner；规范 §2.7）。均随主题。后续模块整改直接复用；主程序替换 `button_widget`/`tips_dialog`/`text_field_widget` 调用点为高风险大改，逐模块推进。
已在 live 接入验证：三个 sheet 改 `showAppSheet`、开奖二次确认改 `AppDialog.confirm`、直播广场空态改 `AppEmptyState`。**`AppBadge` 验证站点**：`bridge_history_page` 状态徽章（裸 `Colors.orange/blue/green/red`→`warning/info/success/danger` tone）。**AppBadge 边界**：可点筛选 chip / tonal 小按钮属按钮线；贴品牌彩卡 / 直播叠层的白底标签用固定叠层色，**不**用随主题 AppBadge。**待收割的重复徽章**（后续）：`home/feature_entry_card`、`wallet/batch_transfer.BatchStatusBadge`、`wallet/aa` 状态、`mining_v2/node_detail` WS 圆点等。

## 模块进度

| 模块 | 状态 | 日期 | 改动 | 备注 |
|---|---|---|---|---|
| `features/live` | ✅ 完成 | 2026-06-01 | 13 文件 | 见下 |
| `market` 行情模块 | ✅ 完成（P0+核心P1） | 2026-07-03 | 10 文件 | **三路并行审查（P0×10 P1×62 P2×43）→ P0 全清**：K线周期 chip/P&L 加交易/页头返回铃铛/详情 FAB.small→标准/链接行 85→96.w/列表铃铛星标→IconButton/**提醒 sheet CTA 50.h(25dp)→96.h**/方向 chip→InkWell+88.h+选中 check 图标/交易 sheet 保存钮 96.h。**字阶修复**：price_alert_sheet 全表 captionSm(10dp) 错阶→caption 基线+标题 headline+按钮 bodyStrong（此前整张 sheet 文字缩水一半）。核心 P1：pctColor 公共入口→success/danger 令牌、行情列表行按压态恢复可见（splash 禁用+3% 高亮→默认 splash+8%）+行高达标、星标裸 0xFFFACC15→highlight 令牌、按钮圆角→brXl。验证：全 market analyze 净+535 wallet 单测全过。**遗留**：sections `_tc` shorthand→令牌化（10+ 点）、rank/涨跌徽章→AppBadge、_EmptyState→AppEmptyState、自造输入→AppTextField、两 sheet→showAppSheet、保存/删除成功静默无 toast、market_page 死代码块删除、`.h/.sp` 与 `.w` 单位制混用统一、双主题+130% 真机验证 |
| `wallet` 首页文件簇 | ✅ 完成 | 2026-07-03 | 10 文件 | **/ui-review wallet 三路并行审查（P0×21 P1×52 P2×35）→ P0 全清 + 机械 P1**。文件：`wallet_page`(+helpers/top_bar/sheets)、`wallet_coin_item`/`coin_list_header`/`coin_list_section`、`wallet_board`、`feature_entry_cards`(+items)。**P0 触控红线全清**：pin 按钮/悬浮加币/顶栏标题/WalletConnect/加代币/Market/Portfolio/排序/阈值/Discovery 关闭/显示全部/备份链接全部 GestureDetector→InkWell 且 ≥88.w 命中区（视觉不变，命中区外扩）；**列表头 165→192.w** 换取两行各 88.w；钱包切换列表行高 80→96.w + **选中态加 check 图标**（不靠颜色传达）；**币种行 ripple 被不透明卡遮挡→Material 承接卡面色**（列表主交互恢复按压态）；资产卡操作钮 Material(transparent) 让 ripple 画在渐变上；_LoadingBanner warning 实底白字（亮色 2.2:1）→12% 色调底+同色字+图标。P1：codemod 残留圆角→brMd/brSm、非 8pt 间距归令牌、裸 `Color(0xFF4CAF50)` 默认参数→success、三元边框→tokens.border、`_cardDecoration` 签名 double→BorderRadius。**验证**：全 wallet analyze 净 + 535 单测全过。**遗留（P2/结构性）**：wallet_board 渐变/阴影裸色提取 `AppGradients` 常量、displayLg/captionSm 冗余 copyWith、部署状态徽章收敛 AppBadge、sheetBottom→showAppSheet 迁移（4 处）、swap 模式菜单 ListTile 未 l10n、双主题+130% 字号真机验证。**2026-11-15 HIG 审计收尾**：sheetBottom 在 helper 层改为 sheet 自身 Material 承载（覆盖全部 22 处，含钱包 4 处）；swap 菜单 ListTile 实已 l10n，真问题是 ink 被遮挡（debug 断言），已随 sheetBottom 修复；wallet_board 现为纯品牌色（渐变已不存在），裸 `Colors.white`→叠层令牌；双主题+130% 以 widget 截图验证（见下方批次），真机仍待验 |
| `home` | ✅ 完成 | 2026-07-03 | 18/26（余 8 为无 UI/逻辑文件） | 已整改：`feature_entry_card`、widgets/（`nav_setting_item`/`nav_select_image`/`share_list`/`check_version_alert`）、setting/（`about_app`/`setting_sys_language`/`setting_share`/`setting_theme`）。模式：字号→AppTypography、间距/圆角→AppSpacing/AppRadius、GestureDetector→InkWell（列表项用 Ink+InkWell 保 splash）、裸状态色→语义色、accent 选中色随主题；颜色已用 getColorByKey 的保留（合规）。剩余 UI 文件 ~9：`personal_setting`/`personal_setting_fields`/`setting_home_page`/`change_email_ui_helpers`/`home_page`/`home_draw_page`(+widgets)/`home_page_navigation`/`face_recognition_public`（同模式，待逐个 /ui-review）。**2026-07-03 收尾（9 文件，两路并行审查 P0×9 P1×23 P2×25→P0 全清）**：底部导航 5 tab 恢复按压反馈（splash/highlight 被 transparent 关闭——全 App 最高频交互无反馈）+未选中色 withAlpha(100)→textTertiary；rail 菜单钮 24dp→48dp；抽屉关闭钮 44.w(22dp!)→88.w 圆形；抽屉头像/添加好友 CTA/登录退出钮→InkWell+≥88.w；抽屉菜单项命中高 96.w；邀请码复制图标(16dp 嵌套热区)→IconButton；改邮箱主按钮 50.h(≈25dp)→96.h+brXl+bodyStrong、重发码→TextButton(带禁用态)。face_recognition_public 纯逻辑无 UI。**遗留**：抽屉姓名区与头像双 GestureDetector 合并、自造徽章→AppBadge、验证码输入→AppTextField、email deco 裸 0xFFEF4444→danger、_settingCard→AppCard、导航阴影→elev 令牌|
| `wallet`（首页/收发/资产） | ✅ 完成 | 2026-11-17 | 12 文件 | 已整改：首页**资产卡 `wallet_board`**（前景白→固定叠层色、保留品牌渐变）、**币种列表项 `wallet_coin_item`**（裸灰→textTertiary、涨跌徽章）、**账户项 `item_wallet`**、**收款页 `wallet_receive_qr`(+content)**（链选择 chip 按压态、QR 卡/按钮/金额框、裸边框 0xFFE4E4E4→border、越界 w700→w600）。**发送页核心 3 文件**（`wallet_chain_send_form`/`wallet_chain_send`/`wallet_chain_send_gas`）：颜色本已走 `getColorByKey` 合规，整改字号→AppTypography、间距→AppSpacing（30→space8/20→space4/10→space2）、圆角→AppRadius（16→brMd/8→brSm/60→brPill），删金额框 2 处 alpha0 无效阴影裸色值。**币详情页核心 4 文件**（`wallet_chain_info` 主页 + `wallet_chain_info_board` 资产/操作卡 + `wallet_chain_info_transactions_item` 交易项 + `wallet_chain_info_title`）：颜色多数合规，整改字号/间距/圆角；**消红线裸色值**——交易项风险标签 `0xFFF44336/FF9800/4CAF50`→`AppColorTokens.danger/warning/success`、mempool 卡 `Colors.orange`→`warning`；去 `FontWeight.bold`(w700)→`bodyStrong`(w600)。覆盖钱包首页 + 收发 + 币详情全链路最高可见组件。**遗留**：~~发送页 MAX 按钮/加号按钮嵌 `textFieldStyle2` 内缺按压态（改造受限，标 P1）；触控 60.w(~30dp)<44dp 同因~~（2026-11-15 已在 `textFieldStyle2/3` 槽位层统一修复，见下方批次）；币详情 `buttonWidgetV2` 自造按钮可收敛到 `AppButton`；`wallet_chain_info_actions/sync/xrp` 逻辑/特殊链未审。剩余同模式：`wallet_page` 骨架/各链 `*_widgets`/swap/market 等数十文件（逐个 /ui-review）。**2026-11-17 全页审计**：钱包全部页面（收发/币详情/各链/swap/dex/market/NFT/AA/ENS/备份/管理/批量转账等）已纳入全量触控与对比度审计并修复，见下方「2026-11-17」批次 |
| `swap`（ast_swap） | ✅ 完成 | 2026-07-03 | 14 文件 | **ast_swap 兑换全链路令牌化完成**：核心交互链（`swap_ast_pay/get_widget`、`swap_ast_form_widgets`、`swap_ast_home(_build)`）+ 次级页（`summary`/`select_chain`/`transactions`/`miner_fee`/`transaction_detail`）。字号→AppTypography、间距→AppSpacing(8pt 网格)、圆角→AppRadius；颜色本已走 `getColorByKey` 合规、**零裸色值**；保留图标尺寸/布局高/1px 分割线/4px 微距。`price_utils` 无 UI 跳过。**复审优化**：费用数值 body→`bodyStrong`（金额强调 §1.3）、错误卡圆角 `brSm`→`brMd`（二级卡片 §1.5）、消残留裸间距 36→`space12`。**遗留（可用性专项，宜跨页统一阈值后整改，不逐页突击以免密度不一致）**：① 触控 <44dp——AppBar 双图标(~22dp)、订单项(40dp)、复选框/百分比/条款链接；② 透明背景 InkWell 按压态不可见、条款链接 `GestureDetector` 无反馈；③ `miner_fee` 余额/费用不足仅靠 `errorTextColor` 传达（§5 红线，需配图标/文字）；④ 金额关键数字跨页统一 `bodyStrong`（本页 pair+amount 共用 style 处未拆分）；⑤ 固定高 80(40dp) 双行区（`transactions`/`transaction_detail` 顶部）需 130% 字号 + 双主题真机验证裁切。**2026-07-03 触控专项收尾**：AppBar 双图标 44.w(22dp)→88.w 命中（视觉不变）、条款链接 GestureDetector→InkWell+垂直外扩、订单项 80→96.w；miner_fee「仅靠色」经核实已在早前配 warning icon（遗留清单过时）；复选框项不存在（误记）。swap 模块转 ✅。market 已单列 ✅ |
| `mining_v2`（令牌整改） | ✅ 完成（约定范围） | 2026-06-06 | 状态色+字重+圆角+getColorByKey 类型化 | **按钮收敛后接令牌整改**。已完成两个违规类：① **越界字重全清**（13 处 w700/bold→w600，9 文件）；② **§5 红线状态色**——`risk_card` 风险三档、`status_widget` 活跃/暂停/在线、`node_detail` 在线/离线/同步+正常率+到期、`today_v2` banner 状态球，裸 hex `#32D74B/#EB5851/#FF9500/#4CAF50/#F44336`→`AppColorTokens success/danger/warning`（`_statusColor`/`_uptimeColor`/`_getRiskColor` 改为带 context 的类型化访问）。**剩余（后续批次）**：装饰性渐变/icon-tint（`full_node_v2_widgets` 粉/橙渐变、`board_widget`/`n_level` 青蓝渐变、`plans_widget` 品牌渐变、`share_mining` 背景渐变——非 §5 状态误用，属品牌装饰，需谨慎；`background_mining` 禁用态色→textTertiary/bgSurface）。**圆角已完成**：50 处裸 `BorderRadius.circular`→`AppRadius.brSm/Md/Lg/Xl`（最近令牌收敛，perl 批量）。**剩余（需决策）**：① `getColorByKey`→类型化卡在 `AppColorTokens` scope——mining_v2 约 65 处用已映射键（可直接迁），约 18 处用未暴露键（`itemSubtitleTextColor`×13/`itemTextColor`×5/`mainWhiteColor`×3/`errorBgColor`/`itemLineColor` 等），需先决定是否给 token 层加 getter（否则混用更乱）；② 装饰性渐变（品牌取舍）。盘点见会话 Explore 报告。|
| `mining_v1` / `mining_v2`（按钮收敛） | ✅ 完成 | 2026-06-05 | v1:4 文件 + v2:11 文件 | **按钮收敛子线**：所有品牌填充/带 loading 的 CTA（`buttonStyle2`/`buttonStyle6` + 两处裸 `ElevatedButton(mainBlueColor)`）→ `AppButton`（primary，loading 透传）。v2 覆盖：`mining_plans_v2`/`mining_setting`/`mining_full_node_v2(_widgets)`/`mining_node_detail(_widgets)`/`mining_today_v2(_widgets)`/`mining_output_pk`/`mining_import`/`mining_output_tip`/`share_mining`。**显式 defer（非 AppButton 可表达，留待组件库扩展）**：① `plans_widget` buttonStyle3 **显示态状态药丸**（`onTap:null` + 全圆角 + 自定义色）——是状态指示器不是按钮，应归入未来 `AppStatusPill`/`AppBadge`（同 v1 `today_mining`/`select_plan` 药丸、live `_OnlineBadge`）；② `mining_full_node_v2_widgets:337` **白底橙字「导出私钥」**（`0xFFFF6B35` 警示色）——AppButton 无 warning 变体，宜先加 `AppButtonVariant.warning` 再收敛。**令牌整改（色/字阶/间距/圆角 + InkWell 按压态）仍 ⬜ 待办**，与按钮收敛是两条线。AlertDialog actions 的 TextButton 归 AppDialog 线，本批未动。|
| **全局 `getColorByKey`→类型化** | ✅ 完成 | 2026-06-06 | 全 features 模块 | `AppColorTokens` 扩 `textSubtitle`/`textItem`/`dangerBg`，逐模块 perl codemod 把字面映射键 `getColorByKey(ctx, AppThemeKeys.X.name)`→`AppColorTokens.of(ctx).Y`（mining_v2/bridge/staking/browser/home/profile/news/hardware/earn/mining_v1/wallet_connect/wallet/widgets/component/utils）。全 lib analyze 0 错误 0 警告。保留特例：三元/动态键、未映射特例键（mainWhiteColor/mainButtonBg/textFieldHint 等）、泛型 `_themeColor` helper。**注**：本迁移只统一颜色访问方式（类型化、防漂移），各模块字阶/间距/圆角/裸渐变等令牌整改仍按模块表推进。|
| **全局圆角令牌化** | ✅ 完成 | 2026-06-06 | 全 features | `BorderRadius.circular(setWidth(N))` + `BorderRadius.all(Radius.circular(setWidth(N)))` → `AppRadius.brSm/Md/Lg/Xl`（最近令牌收敛 3-30；映射表外 2/4/28/40/50/60/80/86/999 及 vertical/only 形式保留）。perl 批量 + 智能补 design_system import。|
| **全局字重归一** | ✅ 完成 | 2026-06-06 | 全 features（203 处） | `FontWeight.bold`/`w700`→`w600`（§1.3 上限）。|
| **全局字阶** | 🟡 机械层完成 | 2026-06-07 | 全 features（~935 处） | TextStyle→`AppTypography.<role>.copyWith(...)`：2-字段(532)+3-字段含字重(323)+helper 色 `_themeColor/getColorByKey`(80)。字重/动态三元/颜色均保留。**剩余 ~162 真字阶残留**=长尾（letterSpacing/height/嵌套 copyWith），逐站点手工。|
| **全局间距** | 🟡 机械层完成 | 2026-06-07 | 全 features（1887 处） | `EdgeInsets.all`/`horizontal/vertical`/`SizedBox` 间隙 `setWidth`→`AppSpacing`（最近令牌 §1.4）。只动确定间距，避开 Positioned/Container/icon 尺寸。截图核对密度无回归。剩余 setWidth 多为尺寸（合理保留）。|
| **截图核对工作流** | ✅ 建立 | 2026-06-07 | `test/screenshots/` | 真主题+Windows 中文字体+双主题+runAsync；覆盖 cv/setting_home/gesture/google_auth。复用见文件头注释。|
| `home`（字阶+间距） | ✅ 完成 | 2026-06-07 | 11 文件 | setSp→AppTypography（逐站点保字重/ls）、安全间距 setWidth→AppSpacing；截图双主题核对（setting_home/gauth/gesture）。响应式字号变量/图标尺寸按设计保留。|
| `全局按钮收敛` | ✅ 完成 | 2026-06-06 | 全 app | 所有 `buttonStyleN` + 裸 `Elevated/Filled/OutlinedButton` CTA → `AppButton`（ast_swap/wallet/create/backup/manage/add-token/gas/dex/mining v1+v2/browser/wallet_connect/bridge/staking/terms/share）。新增 `AppButtonVariant.warning`、`AppBadge`。cancel/confirm 配对 cancel→secondary。|
| `profile` / 设置 | ✅ 完成 | 2026-11-17 | home/setting + profile | 个人资料、安全设置（谷歌验证/手势密码）、语言/主题/关于/改邮箱：触控 ≥44pt、图标按钮补标签、按压态、130% 字号；见下方「2026-11-17」批次 |
| `n42_chat`（独立 repo） | ✅ 完成（待发版） | 2026-11-17 | 全部页面 | 2026-11-16 round 2 已完成 `primaryOf` 跟随宿主 accent 与 `isDark ?` 色值三元→`ChatColors`（本行此前的“剩 70 处 / 固定靛蓝”已过时）。**2026-11-17** n42_chat 全部页面完成全量审计与修复（分支 `fix/ui-full-20261117`，未推送、宿主 pin 未升级），见下方批次 |

## 2026-06-19 收尾批次（分支 feat/ui-token-migration）

**Phase 1 · 令牌盲区补齐（字阶）完成**。前几轮 codemod 的盲区/长尾清理：
- **aa 子树**（`wallet/pages/aa/`，全 codemod 盲区）：fontSize→AppTypography + `BorderRadius.circular(N.w)`→AppRadius + 安全间距→AppSpacing（5 文件实改）；身份/会话类型识别色板 + 品牌 accent（含 `0xFFFF9800` 批操作橙，**非 warning**）保留。
- **字阶长尾**：market(38)、dex_swap+transactions+aa_transaction_preview(25)、dapp_security_badge+loading(4)、send/add_token/batch_transfer/address_book/nft/home/browser/widgets(29) 的裸 `TextStyle(fontSize)`→`AppTypography.<role>.copyWith`（保字重：显式字重原样搬入；role 默认 w500/w600 的正文/提示类补 w400；28+w600→bodyStrong）。
- **合理保留**：组件参数式 fontSize（`button_widget`/`text_field_widget`/各链自定义输入框/`EnsAddressDisplay`/`buttonStyle3` 的 `fontSize:` 形参）、candlestick 轴标 `fontSize:9`、toast 库参数、market 注释死代码、send 金额大字段 `setWidth(70)`（11 链一致，有意保留）。
- **待 Phase 4 截图核对**：`wallet/pages/portfolio/` 用反常小字号（10–18.sp，仅及标准一半），映射到 captionSm(20) 近翻倍、可能撑破紧凑行——延后到双主题/130% QA 阶段连同布局一起判断，不盲迁。
- 全程 `flutter analyze lib` 0 错 0 警；3 个提交（aa+market / dex_swap+tx+widgets / send+add_token+home+browser）。

**Phase 2 · 组件收敛**（2026-06-19）：
- **tips_dialog → AppDialog**：实查发现**已基本达成**——`tipsDialog1/2/6/7` 已委托 `AppDialog`，`tipsDialog3` 是透明通用宿主（`AlertDialog` 包 child），`tips_dialog_4` 已全令牌化，4 个自定义 child（create_two 助记词 / keystore 密码 / device_login / phishing）均令牌合规。**结论**：强塞安全敏感流程进 AppDialog = 高风险零视觉收益，**不做**；仅清 keystore 动态圆角残留。
- **重复徽章**：`live` 的 `_OnlineBadge`（live_top_bar + go_live_page 各一份）抽为共享 `OnlineBadge`（`live/presentation/widgets/online_badge.dart`），**保留固定叠层色**（§2.7：叠层徽章不用随主题 AppBadge）。
- **buttonStyle3 残留（3 处）保留 + 记录理由**：`plans_widget`/`select_plan` 是品牌渐变卡上的白色 CTA 样式标签（卡片本身可点，§2.7 边界不套 AppBadge）；`today_mining` 是 v1（maintenance-only）的 tonal 软按钮，`AppButton` 无 tonal 变体、强转会改视觉身份。
- **⬜ 输入框收敛（2b）建议延后**：`CommInput` / `textFieldStyle2/3`（20+ 调用）已令牌合规、工作正常、用于密码/keystore/发送等安全敏感流程；收敛纯属去重（非红线），需大改 `AppTextField`（缺 prefix/maxLength/message 双轨/多 action），回归风险高、收益不可见。**待产品/用户决策是否投入**。

**Phase 3 · 可用性/交互态**（2026-06-19，swap 核心红线）：
- `swap_ast_form_widgets`：百分比快速填充按钮 + 条款复选框 → 包 `Material(transparent)` 使按压 splash 在透明背景可见 + 触控区抬到 88.w(=44dp)（§2.6）。条款链接为内联文本链接（下划线+品牌色 affordance）保留。
- §5 红线「状态不只靠颜色」：`swap_ast_pay_widget` 余额不足、`swap_ast_miner_fee_widget` 矿工费不足 → 红字旁补 `error_outline` 图标。
- `swap_ast_transaction_detail` 各状态本已有图标（error/info/check_circle）+ 色，§5 已满足，颜色走主题键解析（重映射有视觉变化风险）保留。
- **⬜ 延后**：`_MaxButton`/加号按钮按压态（被 ~20 链 send 表单共享、点击经 textFieldStyle2 `rightOnTap1` 契约，改动风险铺全链、收益小）；AppBar 图标触控区。

**全 app 可用性扫描整改**（2026-06-19，Phase 3 扩展）：Explore 子代理全模块扫描「透明 InkWell / 裸 GestureDetector 卡片 / <44dp 触控」，确认 23 处真问题（已排除 Material 子树内的合规 InkWell）。**已整改 18 处**（统一模式 `Material(transparent)+InkWell`，borderRadius 对齐内部圆角，AnimatedContainer 原样作 child）：home 设置（主题色点/预设卡/导航项/邀请码行）、nft 筛选 chip/重试、staking 卡×3、bridge 路由卡、earn 产品/功能卡、browser 标签卡、mining 计划卡/支付选项、gas 方向卡、token 发现横幅。**有意跳过**：`wallet_coin_item`（InkWell 包 Slidable，加 Material 风险高/收益仅 ripple）；各处 <44dp 小图标关闭/pin 按钮（密集工具栏触控区扩大易破坏布局，单独评估）。3 波并行子代理 + 逐目录 analyze。

**portfolio 模块整模块 2× 放大**（2026-06-19）：发现 portfolio 整模块按 ~半比例编写（AppBar 标题 18sp/9dp、正文 10-14sp、图标 32w/16dp，对照 750 设计基准应翻倍），在屏上过小、与全 app 不一致。**均匀 2×**（字号→AppTypography 角色、`.w/.h/.r` 尺寸字面值翻倍）使比例不变、回到设计基准。新增 `test/screenshots/portfolio_overflow_test.dart`：最坏数据（超长 symbol/大金额）行在 360 窄屏双主题断言无 RenderFlex 溢出（6/6 通过；Expanded/ellipsis 兜底有效）。light 截图确认放大后字阶清晰、比例正常。

## features/live 整改明细（2026-06-01）

**关键设计决策**：直播间叠层组件（top bar / 弹幕 / 侧栏 / 预测卡 / 开播页）永远浮在视频上，是**强制深色语境**——用 `AppColorTokens` 的**固定叠层色**（`overlay` / `onOverlayPrimary` / `brandOnOverlay` 等 static const），不能随 app 主题变（否则亮色主题下叠层文字变黑、视频上不可见）。普通页（直播广场）与模态（下注/开预测/开奖 sheet）用**随主题色**（实例 getter）。

**P0（已修）**：
- `go_live_page._RoomIdChip` 复制按钮：GestureDetector→Material+InkWell 按压态 + 触控区抬至 44dp。
- `live_side_actions._ActionButton` 点赞/礼物/分享：GestureDetector→InkWell 按压态。
- `live_top_bar` 关注按钮：抽 `_FollowButton`，Material+InkWell 按压态。
- `danmu_overlay` 弹幕气泡：叠层 0.35→`overlay`(0.55)，提高视频上对比度。

**P1（已修）**：全模块裸 `Color/Colors.xxx`、硬编码 `fontSize`、`EdgeInsets/SizedBox`、`BorderRadius.circular` → 令牌。`prediction_card` 去越界 `w700`、状态色 `0xFF41C36B/FFB020/8AB4FF`→`success/warning/brandOnOverlay`。`enter_room_banner` 紫色渐变→品牌蓝（单一品牌强调）。三个 sheet `Color(0xFF1C1C22)`→`bgElevated`、`circular(16)`→`brSheetTop`、`redAccent`→`danger`、输入框描边/聚焦→`border`/`brand`。`live_home_page` 空状态结构化（图标+说明）。

**遗留 P2（后续）**：
- `_OnlineBadge` 在 `live_top_bar` 与 `go_live_page` 各一份，可抽公共 `OnlineBadge` 组件（§2.2 禁重复）。
- 三个 sheet / `resolve` 的二次确认 `AlertDialog` 可收敛到统一 `AppDialog`（§2.4）。
- 输入框可进一步收敛为统一 `AppTextField`（§2.3）。
- `prediction_card` 赎回按钮、`_OutcomeRow` 不可交易态可加 loading/降饱和。
- `like_burst` 飘心 1400ms、动画几何魔数：装饰性，豁免。

**验证**：`flutter analyze lib/features/live lib/core/design_system` → No issues；`flutter test test/features/live` → 11/11；`dart format` 已过。**未做**真机/双主题人工验证（需后续）。

## Chat / contacts / account switching — 2026-09-20

The approved three-area UI plan is implemented, including shared search/navigation, full accessible contact index, 48-point composer actions, dynamic text layouts and explicit account cards/errors. See [completion report and light/dark previews](testing/chat-ui-completion-2026-09-20/README.md) for implementation and test evidence. Native feedback-device acceptance remains pending.

## 2026-11-15 HIG 审计批次（钱包首页 / 发送 / 聊天页）

依据 apple-design skill（accessibility / color / layout / typography / entering-data / keyboards）审计三页，只做可达性、对比度、触控、按压态、令牌与标签修复，不改布局密度与业务逻辑。截图工具：`test/screenshots/hig_main_pages_screenshot_test.dart`（钱包首页整页 + 组件组合 + 发送页 + MAX 按压态 + 3 个 sheet，亮/暗 × 100%/130%；按压截图用 InkRipple——Android 默认 InkSparkle 依赖 shader，测试渲染器不画）；n42_chat 侧 `test/goldens/message_item_hig_screenshot_test.dart`（回复/已编辑/地址链接/投票/日程/未接来电，输出 `build/hig-shots/`）。PNG 不入库。

**n42appv2（4 个修复提交 + 截图工具）**：
- **`textFieldStyle2/3` 操作槽**（MAX、地址簿 +、密码显隐等全部调用点）：裸 InkWell 位于输入框不透明底色之下，按压 ink 画在底色下面看不见；可点槽位统一加透明 Material + 44pt 最小命中区（视觉不变），无 onTap 的装饰槽原样渲染。MAX 药丸改 `Ink` 绘制，ripple 显示在药丸之上；地址簿 + 补 Tooltip（同时是读屏标签）。
- **发送页**：「金额」行余额停在卡片中间（Expanded 与 loose Flexible 平分，标签剩余空间被空置）→ 两侧 Flexible + spaceBetween 贴右；矿工费行 130% 下「Max fee per gas」被截断 → 标签占大份额并允许两行；错误横幅红字叠红色底（约 2.6:1）→ 错误图标 + 主文字色。
- **`sheetBottom`**：透明 sheet + 装饰 Container 导致内部所有 InkWell/ListTile 无按压反馈（swap 模式菜单 ListTile 触发 Flutter debug 断言），主题拖拽条悬浮在遮罩上、脱离面板 → sheet 自身 Material 画 `bgBase` + 主题 20pt 顶角，拖拽条回到面板内，22 处调用全部受益。保留 bgBase（内容按此底色设计），未切 `showAppSheet` 的 bgElevated。
- **钱包首页**：资产卡辅助文字 70% 白（约 2.7:1）→ 全白（约 4:1）+ 裸 `Colors.white`→叠层令牌；顶栏二维码菜单读作「Show menu」、WalletConnect 图片按钮无名称 → 补 Tooltip；未置顶 pin 图标 tertiaryLabel（<3:1）→ secondaryLabel；备份提醒红色正文（约 3.5:1）→ 警示图标 + 主文字色。

**n42_chat（`message_item.dart`）**：回复引用发送者名品牌靛蓝在暗色自气泡上 <1.5:1 → 气泡文字色；回复引用/已编辑/地址链接/投票选项/结束投票/添加日程/回拨 由裸 GestureDetector 改共享 `_BubbleTap`（透明 Material + InkWell，独立操作 44pt 命中区，有底色的子元素改 `Ink`）；「已编辑」10pt→11pt + 可读色；未接来电红字（约 3.4:1）→ 红色图标承载状态、文字用气泡文字色；地址链接自气泡用文字色、暗色用浅品牌色；投票计数/参与人数/日程明细 textSecondary→textSupporting。

**验证**：n42appv2 `flutter analyze` 80 info / 0 warning / 0 error（与基线一致），全量 `flutter test` 见提交说明；截图前后对比亮/暗 + 130% 无溢出。

**未做 / 遗留**：
- 品牌蓝底白字（资产卡、AppButton）约 4.0:1（亮）/3.65:1（暗），低于正文 4.5:1——品牌取舍，未改底色。
- 品牌色文字叠 12% 品牌底（网络筛选 chip、投票「Single」标签、回拨/添加日程）约 3.5:1，全 app 共用模式，需统一决策。
- `88.w` 类 ScreenUtil 命中区在 320 宽屏只有 37.5dp——系统性问题，应改逻辑点 44。
- n42_chat：`AppColors.primary` 固定靛蓝未跟随宿主 accent、`isDark ?` 70 处、`message_item` 其余裸色/字号；聊天新提交在 n42_chat main，但宿主 pin 的 ref 不在 main 上（main 落后 190 提交），未升级宿主 ref。
- 真机（VoiceOver/TalkBack、iOS 实际 ripple/高亮、键盘遮挡）未验证。

## 2026-11-16 UI round 2 (deferred items resolved)

- **Brand fill for white text**: `AppContrast.fillForWhiteText` + `AppColorTokens.brandFill` (same hue, lightness lowered until white reaches 4.5:1). Theme filled/elevated buttons (AppButton primary), asset card (also covers the 9% white pills), filled chips/FABs/legacy buttonStyle fills. System blue + white 4.02:1 / 3.65:1 -> #0071ED 4.58:1 / #0073E8 4.55:1; asset card #0068D9 / #0069D3 with pills 4.5:1+.
- **Brand text on brand tint**: `AppColorTokens.brandOnTint` / `brandOnTintAt(alpha)` (4.5:1 on tints up to 15% over bgBase/bgSurface/bgElevated; #005FC7 light / #4AA4FF dark). AppBadge brand tone, network filter chip, fee/slippage/period chips, ENS tags. n42_chat: `AppColors.primaryOnTintOf` (poll tag, BOT tag, call back, tabs, chips); in-bubble accents use the bubble text color on the own bubble.
- **Narrow-screen hit areas**: `AppTouch.target` = max(88 design px, 44pt), `AppTouch.scaled(n)`; all 88-px hit sizes and tappable 70-103 px sizes. 320pt: 37.5 -> 44pt; 375pt and wider unchanged.
- **n42_chat**: `AppColors.primaryOf(context)` follows the host accent (576 sites; fallback to `AppColors.primary` without a host theme); color `isDark ?` ternaries -> `ChatColors` ThemeExtension (129 replaced); message_item font sizes -> `AppFontSize`, media colors -> fixed tokens.

## 2026-11-17 全页 HIG 审计（UI round 3）

范围：n42appv2 与 n42_chat 全部页面。脚本盘点每个可点元素在 375/320 宽下的命中尺寸（n42appv2 819 处、n42_chat 1272 处），再逐文件读代码核对；同时查对比度（文字 4.5:1、图形 3:1，亮/暗）、图标按钮标签、按压态、破坏性操作确认、资金/安全操作的加载与禁用态、键盘避让、130% 字号、l10n。分支 `fix/ui-full-20261117`（两个 repo），未推送。

- **问题数**：n42appv2 461（P0 95 / P1 325 / P2 41），已修 395；n42_chat 869（P0 119 / P1 647 / P2 103），已修 728。其余为负责人决策或延期项（问题清单 TSV 中逐条记录）。
- **共享层（n42appv2）**：新增 `AppTapArea`（44pt 最小命中区 + Tooltip/读屏标签 + ink，视觉不变）；`AppColorTokens.dangerFill`（白字 4.5:1 的危险色底）/`onWarningFill`（警示底深色字）/`textOnTintOf`（语义色文字叠色调底）；`AppDialog.confirm` 默认按钮文案改为 l10n（原硬编码「确定/取消」）；Apple 预设次要文字 secondaryLabel 3.44:1 → #6C6C70（4.6:1+），TextButton 前景色按背景保证对比度；AppBadge 语义色文字。
- **共享层（n42_chat）**：`N42TapArea`；`ChatContrast.fillForWhiteText`、`AppColors.primaryFillOf/errorFill/errorTextOf`；`textSecondary` #8A8A8E → #6C6C70，时间分隔/caption 加深；主题 Elevated/Filled/TextButton 按对比度取色。
- **页面层**：P0 触控（小图标、关闭/复制/清除按钮、底栏操作、列表尾部操作）改 `AppTapArea`/`N42TapArea` 或 IconButton；破坏性操作补确认（优先 `AppDialog.confirm` / `showConfirmDialog`）；资金/安全操作补 loading 与防重复提交；图标按钮补本地化标签；n42appv2 新增 231 个、n42_chat 新增 587 个本地化字符串（全部语种）。
- **截图**：两个 repo 新增全页截图工具（n42appv2 `test/screenshots/hig_full_audit_screenshot_test.dart`，`HIG_FULL_SHOTS=1`；n42_chat `test/goldens/hig_full_audit_screenshot_test.dart`，`N42_CHAT_SHOTS=1`），亮/暗 × 100%/130%，PNG 不入库。
- **验证**：analyze 与基线一致（n42appv2 80 info、n42_chat 373 info，0 warning/0 error）；全量测试无新增失败；`audit_localizations.py --mode all` 通过。
- **负责人决策 / 遗留**：品牌蓝作文字约 4.0:1（iOS tint 惯例）；成功/警示/危险色文字未全 app 替换（`textOnTintOf` 已可用）；Android 自定义命中区按 44pt 而非 48dp；删除钱包对话框按钮为蓝色「确认」；浏览器工具栏 320 宽每钮 40pt；质押无密码/生物识别步骤；n42_chat 聊天顶栏 320 宽标题过窄、定时消息取消无确认、转账/红包卡片配色对比度、游戏棋盘格 <44pt、points/governance/bridge 约 210 处英文硬编码；n42_chat linux/macos golden 基线需在对应 CI 机器重生成。真机（VoiceOver/TalkBack、iOS 高亮、键盘遮挡）未验证。
