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
| `home` | 🔵 进行中 | 2026-06-01 | 9/26 | 已整改：`feature_entry_card`、widgets/（`nav_setting_item`/`nav_select_image`/`share_list`/`check_version_alert`）、setting/（`about_app`/`setting_sys_language`/`setting_share`/`setting_theme`）。模式：字号→AppTypography、间距/圆角→AppSpacing/AppRadius、GestureDetector→InkWell（列表项用 Ink+InkWell 保 splash）、裸状态色→语义色、accent 选中色随主题；颜色已用 getColorByKey 的保留（合规）。剩余 UI 文件 ~9：`personal_setting`/`personal_setting_fields`/`setting_home_page`/`change_email_ui_helpers`/`home_page`/`home_draw_page`(+widgets)/`home_page_navigation`/`face_recognition_public`（同模式，待逐个 /ui-review）|
| `wallet`（首页/收发/资产） | 🔵 进行中 | 2026-06-03 | 12 文件 | 已整改：首页**资产卡 `wallet_board`**（前景白→固定叠层色、保留品牌渐变）、**币种列表项 `wallet_coin_item`**（裸灰→textTertiary、涨跌徽章）、**账户项 `item_wallet`**、**收款页 `wallet_receive_qr`(+content)**（链选择 chip 按压态、QR 卡/按钮/金额框、裸边框 0xFFE4E4E4→border、越界 w700→w600）。**发送页核心 3 文件**（`wallet_chain_send_form`/`wallet_chain_send`/`wallet_chain_send_gas`）：颜色本已走 `getColorByKey` 合规，整改字号→AppTypography、间距→AppSpacing（30→space8/20→space4/10→space2）、圆角→AppRadius（16→brMd/8→brSm/60→brPill），删金额框 2 处 alpha0 无效阴影裸色值。**币详情页核心 4 文件**（`wallet_chain_info` 主页 + `wallet_chain_info_board` 资产/操作卡 + `wallet_chain_info_transactions_item` 交易项 + `wallet_chain_info_title`）：颜色多数合规，整改字号/间距/圆角；**消红线裸色值**——交易项风险标签 `0xFFF44336/FF9800/4CAF50`→`AppColorTokens.danger/warning/success`、mempool 卡 `Colors.orange`→`warning`；去 `FontWeight.bold`(w700)→`bodyStrong`(w600)。覆盖钱包首页 + 收发 + 币详情全链路最高可见组件。**遗留**：发送页 MAX 按钮/加号按钮嵌 `textFieldStyle2` 内缺按压态（改造受限，标 P1）；触控 60.w(~30dp)<44dp 同因；币详情 `buttonWidgetV2` 自造按钮可收敛到 `AppButton`；`wallet_chain_info_actions/sync/xrp` 逻辑/特殊链未审。剩余同模式：`wallet_page` 骨架/各链 `*_widgets`/swap/market 等数十文件（逐个 /ui-review）|
| `swap`（ast_swap） | 🔵 进行中 | 2026-06-05 | 11 文件 | **ast_swap 兑换全链路令牌化完成**：核心交互链（`swap_ast_pay/get_widget`、`swap_ast_form_widgets`、`swap_ast_home(_build)`）+ 次级页（`summary`/`select_chain`/`transactions`/`miner_fee`/`transaction_detail`）。字号→AppTypography、间距→AppSpacing(8pt 网格)、圆角→AppRadius；颜色本已走 `getColorByKey` 合规、**零裸色值**；保留图标尺寸/布局高/1px 分割线/4px 微距。`price_utils` 无 UI 跳过。**复审优化**：费用数值 body→`bodyStrong`（金额强调 §1.3）、错误卡圆角 `brSm`→`brMd`（二级卡片 §1.5）、消残留裸间距 36→`space12`。**遗留（可用性专项，宜跨页统一阈值后整改，不逐页突击以免密度不一致）**：① 触控 <44dp——AppBar 双图标(~22dp)、订单项(40dp)、复选框/百分比/条款链接；② 透明背景 InkWell 按压态不可见、条款链接 `GestureDetector` 无反馈；③ `miner_fee` 余额/费用不足仅靠 `errorTextColor` 传达（§5 红线，需配图标/文字）；④ 金额关键数字跨页统一 `bodyStrong`（本页 pair+amount 共用 style 处未拆分）；⑤ 固定高 80(40dp) 双行区（`transactions`/`transaction_detail` 顶部）需 130% 字号 + 双主题真机验证裁切。`market` 待办 |
| `mining_v2`（令牌整改） | 🔵 进行中 | 2026-06-06 | §5 红线状态色 + 字重完成 | **按钮收敛后接令牌整改**。已完成两个违规类：① **越界字重全清**（13 处 w700/bold→w600，9 文件）；② **§5 红线状态色**——`risk_card` 风险三档、`status_widget` 活跃/暂停/在线、`node_detail` 在线/离线/同步+正常率+到期、`today_v2` banner 状态球，裸 hex `#32D74B/#EB5851/#FF9500/#4CAF50/#F44336`→`AppColorTokens success/danger/warning`（`_statusColor`/`_uptimeColor`/`_getRiskColor` 改为带 context 的类型化访问）。**剩余（后续批次）**：装饰性渐变/icon-tint（`full_node_v2_widgets` 粉/橙渐变、`board_widget`/`n_level` 青蓝渐变、`plans_widget` 品牌渐变、`share_mining` 背景渐变——非 §5 状态误用，属品牌装饰，需谨慎；`background_mining` 禁用态色→textTertiary/bgSurface）、32 处裸 `BorderRadius.circular`→`AppRadius`、83 处 `getColorByKey`→`AppColorTokens.of(ctx)` 类型化。盘点见会话 Explore 报告。|
| `mining_v1` / `mining_v2`（按钮收敛） | ✅ 完成 | 2026-06-05 | v1:4 文件 + v2:11 文件 | **按钮收敛子线**：所有品牌填充/带 loading 的 CTA（`buttonStyle2`/`buttonStyle6` + 两处裸 `ElevatedButton(mainBlueColor)`）→ `AppButton`（primary，loading 透传）。v2 覆盖：`mining_plans_v2`/`mining_setting`/`mining_full_node_v2(_widgets)`/`mining_node_detail(_widgets)`/`mining_today_v2(_widgets)`/`mining_output_pk`/`mining_import`/`mining_output_tip`/`share_mining`。**显式 defer（非 AppButton 可表达，留待组件库扩展）**：① `plans_widget` buttonStyle3 **显示态状态药丸**（`onTap:null` + 全圆角 + 自定义色）——是状态指示器不是按钮，应归入未来 `AppStatusPill`/`AppBadge`（同 v1 `today_mining`/`select_plan` 药丸、live `_OnlineBadge`）；② `mining_full_node_v2_widgets:337` **白底橙字「导出私钥」**（`0xFFFF6B35` 警示色）——AppButton 无 warning 变体，宜先加 `AppButtonVariant.warning` 再收敛。**令牌整改（色/字阶/间距/圆角 + InkWell 按压态）仍 ⬜ 待办**，与按钮收敛是两条线。AlertDialog actions 的 TextButton 归 AppDialog 线，本批未动。|
| `profile` / 设置 | ⬜ 待办 | | | |
| `n42_chat`（独立 repo） | ⬜ 待办 | | | **须在 n42_chat repo 改并发版**；对齐品牌色、消 `isDark?:` 三元、补间距/圆角常量 |

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
