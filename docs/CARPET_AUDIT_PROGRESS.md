# N42 地毯式代码审计进度

> **总规模**: 880 dart 文件 / 378K 行代码
> **开始日期**: 2026-02-xx
> **最后更新**: 2026-02-12

---

## 已完成阶段 (Git 已提交)

### Phase 1 ✅ 小模块清理
`commit 20aea9f` | 11 files | -114 lines
- models, state, sqlite, splash, profile, news, pay

### Phase 2 ✅ 基础设施层清理
`commit 40f4506` | 11 files | -537 lines
- utils, component, https

### Phase 3 ✅ 中型业务模块清理
`commit af4f311` | 30 files | -871 lines
- airdrop, bridge, browser, earn, hardware_wallet, login, loyalty, notification, wallet_connect

### Phase 4 ✅ 大型业务模块清理
`commit 74adc90` | 33 files | -521 lines
- staking, miningV2, home

### Phase 5 ✅ 钱包模块深度清理
`commit 56aaa5a` | 77 files | -7107 lines
- wallet 模块 237 files 中的 77 个关键文件

### Phase 6 ✅ 组件与Proto审查
`commit 85ca80a` | 15 files | -1276 lines
- widgets, proto review, plugin review

---

### Phase 7 ✅ 主入口 + Core + Features + lib/src残留 + wallet残留 + n42_chat全量
`本次提交` | 主项目 ~15 files 修改 + n42_chat 40 files 空catch修复

**主项目修复：**
- main.dart: 删除注释死代码(onGenerateRoute 17行, EasyLoading 3行)
- auth_service_impl.dart: 空catch加日志, 修复TODO密码验证
- wallet_service_impl.dart: 删除冗余try-catch-rethrow
- home_draw_page.dart: 修复Stream subscription泄漏(添加dispose)
- mining_api.dart/mining_web3.dart: 硬编码IP迁移到fromEnvironment
- chain_util.dart: 硬编码IP迁移到fromEnvironment
- wallet_page.dart: 删除注释死代码(8行)
- transaction_detail_trx.dart: 删除注释死代码(17行)
- wallet_action_provider.dart: 删除注释死代码(15行)
- text_field_widget.dart: 删除注释死代码(withOpacity块)

**n42_chat插件修复：**
- 73处空catch块添加debugPrint日志 (40个文件)
- 6个文件补充缺失的foundation.dart导入

---

## 已全部完成的阶段

~~## 未完成阶段 (Phase 7-16，上下文溢出后需重做)~~

### ~~Phase 7~~ ✅ 主应用入口与 Core 层审计
**约 39 文件 | 预计上下文: 中**
- [ ] `lib/main.dart`, `lib/main_riverpod.dart`
- [ ] `lib/app_config.dart`, `lib/application.dart`
- [ ] `lib/core/app/` (1 file)
- [ ] `lib/core/config/` (3 files)
- [ ] `lib/core/constants/` (2 files)
- [ ] `lib/core/di/` (2 files)
- [ ] `lib/core/error/` (2 files)
- [ ] `lib/core/network/` (1 file)
- [ ] `lib/core/platform/` (1 file)
- [ ] `lib/core/providers/` (3 files)
- [ ] `lib/core/routing/` (1 file)
- [ ] `lib/core/security/` (4 files)
- [ ] `lib/core/state/` (1 file)
- [ ] `lib/core/storage/` (3 files)
- [ ] `lib/core/usecase/` (1 file)
- [ ] `lib/core/utils/` (6 files)

### ~~Phase 8~~ ✅ Features 层审计
**约 38 文件 | 预计上下文: 中**
- [ ] `lib/features/auth/` (4 files)
- [ ] `lib/features/browser/` (3 files)
- [ ] `lib/features/chat/` (8 files)
- [ ] `lib/features/mining/` (5 files)
- [ ] `lib/features/settings/` (3 files)
- [ ] `lib/features/wallet/` (12 files)
- [ ] `lib/features/wallet_connect/` (1 file)
- [ ] `lib/features/feature_initializer.dart`
- [ ] `lib/features/features.dart`

### ~~Phase 9~~ ✅ lib/src 残留文件审计 - 非wallet模块
**约 89 文件 (Phase 1-6 未触及)**
- [ ] home (15 files 未触及)
- [ ] login (8 files)
- [ ] widgets (22 files)
- [ ] miningV2 (16 files)
- [ ] loyalty (5 files)
- [ ] browser (4 files)
- [ ] wallet_connect (3 files)
- [ ] staking (2 files)
- [ ] hardware_wallet (2 files)
- [ ] bridge (2 files)
- [ ] component (2 files)
- [ ] utils (5 files)
- [ ] https (1 file)
- [ ] earn (1 file)
- [ ] airdrop (1 file)

### ~~Phase 10~~ ✅ lib/src/wallet 残留文件审计 (Part 1)
**约 80 文件 (Phase 5 未触及的 wallet 前半)**
- [ ] wallet/api/ 残留
- [ ] wallet/models/ 残留
- [ ] wallet/pages/ 残留 (A-L)

### ~~Phase 11~~ ✅ lib/src/wallet 残留文件审计 (Part 2)
**约 79 文件 (Phase 5 未触及的 wallet 后半)**
- [ ] wallet/pages/ 残留 (M-Z)
- [ ] wallet/provider/ 残留
- [ ] wallet/utils/ 残留
- [ ] wallet/widgets/ 残留

### ~~Phase 12~~ ✅ n42_chat 插件 - Core + Domain + Data 层
**约 119 文件**
- [ ] core/ (43 files)
- [ ] domain/ (38 files)
- [ ] data/ (28 files)
- [ ] services/ (9 files)
- [ ] integration/ (6 files)

### ~~Phase 13~~ ✅ n42_chat 插件 - Blocs
**约 51 文件**
- [ ] presentation/blocs/ (51 files)

### ~~Phase 14~~ ✅ n42_chat 插件 - Widgets
**约 53 文件**
- [ ] presentation/widgets/ (53 files)

### ~~Phase 15~~ ✅ n42_chat 插件 - Pages (Part 1)
**约 64 文件**
- [ ] presentation/pages/ (前半, A-L)

### ~~Phase 16~~ ✅ n42_chat 插件 - Pages (Part 2)
**约 63 文件**
- [ ] presentation/pages/ (后半, M-Z)

### Phase 17 ⬜ Proto 文件 + 测试文件 (可选，低优先级)
**约 36 + N 文件**
- [ ] lib/src/proto/ (36 files)
- [ ] test/ 目录

---

## 审计标准 (每个文件检查项)

1. **死代码**: 未使用的 import、变量、方法、类
2. **空 catch**: 吞掉异常的空 catch 块
3. **TODO/FIXME**: 未完成的标记
4. **类型安全**: 避免 dynamic、添加缺失类型注解
5. **命名规范**: camelCase/PascalCase 一致性
6. **代码重复**: 可合并的重复逻辑
7. **安全隐患**: 敏感信息泄露、硬编码凭证
8. **性能**: 不必要的 rebuild、重复计算
9. **国际化**: 硬编码字符串
10. **资源释放**: dispose/cancel 正确调用

---

## 上下文管理策略

- 每个 Phase 独立完成后立即 **git commit**
- 每个 Phase 内用 **子 Agent** 并行扫描不同目录
- 单次读取文件不超过 **15-20 个**
- 完成一个 Phase 后 **/clear** 清理上下文再继续下一个
- 进度实时更新到本文件
