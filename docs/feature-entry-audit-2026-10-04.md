# 功能入口审计（2026-10-04）

本报告核对主程序与 Chat 插件的页面入口。静态引用只用于发现候选项。结论以实际导航代码和行为测试为准。旧报告和历史数字保留在原处；当前文件数以新清单为准。

## 当前源码清单

| 仓库 | Dart 源文件 | 测试文件 | 页面/页面组件类 | 最新清单 |
|---|---:|---:|---:|---|
| 主程序 | 1,003 | 469 | 233 | [主程序 UI 入口清单](feature-entry-inventory-2026-10-04.md) |
| Chat 插件 | 698 | 452 | 178 | 统计来自独立 Chat 插件工作区；该清单未随本仓库同步。此处按本仓库中的插件调用点和行为测试核对入口。 |

主程序新增了本报告对应的导航测试，所以现在有 469 个测试文件。Chat 的统计来自正式插件隔离工作区。旧报告中的 989/327、656/343 是旧快照，不应继续当作当前总数。

## 入口审计结果

| 功能 | 审计结果 | 当前入口或处理 |
|---|---|---|
| iOS Earn | 已修复 | iOS 主导航没有 Earn 页。现在可从主页抽屉“其他 → Earn”进入。Android 继续使用主导航，不显示重复抽屉入口。Earn 页内包含 Staking、Bridge、稳定币收益和永续行情入口；具体链上操作仍按各页面状态说明判断。 |
| Keystone 气隙签名 | 尚未接入交易流程 | 配对页可从硬件钱包管理页进入。签名页需要已构造的 EVM RLP 交易、chain ID 和派生路径；provider 只会返回待 QR 签名状态，没有生产调用方把它送入签名页并接回签名结果。因此不增加孤立菜单。后续应从真实 EVM 发送签名流程调用，并测试回传签名和广播结果。 |
| Chat 公开频道发现 | 已修复 | 插件“发现 → Channels”现在打开 Matrix `ChannelDiscoverPage`，不再跳到视频信息流。页面会查询公开房间。未登录或查询失败时显示页面状态提示。 |
| Chat 红包完整历史 | 已修复 | 插件“我 → 订单与卡包 → 活动”页右上角的历史按钮可进入“已发送 / 已收到”列表。活动汇总仍保留在原页。没有 Chat 用户会提示先登录。 |
| Chat 服务入口 | 可达，文档补充 | 转账、红包、收款、钱包和卡包入口位于“我 → 服务”。保留该服务分组，不再把静态构造扫描结果误报为功能缺入口。红包活动历史和完整的收/发历史是两个不同视图。 |

## 入口核对限制

静态清单不证明服务端、网络、资金或设备流程成功。Chat 频道发现依赖 Matrix 登录和公开房间查询。红包历史依赖插件红包服务返回的数据；当前页面还保留本地服务实现的行为边界。Keystone 页面目前只覆盖 QR 请求/响应 UI，不能据此宣称钱包交易签名已经完成。

本次还人工复核了静态清单中的零外部构造引用候选。主程序的 `BatchButtonContent`、`BatchStatusBadge`、`BatchTransferListItem`、`CoinPercentageBadge` 和 `WalletSkeletonCoinRow` 都由同文件或拆分实现中的页面调用；`WalletConnectSheet` 与 ENS 子域 sheet 使用静态 `.show()` 工厂，扫描器不会把工厂调用记作构造引用。`MiningPlans` 与 `SelectMiningPlans` / `MiningPlansV2` 并存，当前流程进入后两者；`WalletPageRiverpod` 是未接主导航的替代钱包页；`ShowImage` 没有生产调用点，现有 NFT/媒体查看器由各自详情或媒体组件处理。本次没有给这些重复或孤立的实现再加菜单。

Chat 插件的零构造引用候选也有同类误报：联系人编辑页在同文件中实例化；传输页由传输对话框同文件创建；旧的 `MessageMenuSheet` 与当前被调用的 `ChatMessageMenuSheet` 是不同类；联系人列表里使用的是私有 `_GroupListPage`。`CallDialog`、`ConfirmReceiveDialog` 和 `SendTransferDialog` 未发现生产入口，且已有通话/收款/转账流程使用其他组件。它们保留在代码里，但本轮不增加新菜单。完整候选仍见插件最新静态清单。

## 复核命令

```sh
python3 scripts/audit_feature_wiring.py --output docs/feature-entry-inventory-2026-10-04.md --check
flutter test test/features/home/home_draw_earn_navigation_test.dart
(cd packages/n42_chat && flutter test test/presentation/pages/discover_page_test.dart test/presentation/pages/profile_services_page_test.dart)
```
