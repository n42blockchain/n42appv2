# N42 Wallet Feature 边界违规分析报告

> **生成日期**: 2024-12-29  
> **分析范围**: lib/src/ 目录  
> **分析方法**: 静态 import 依赖分析

---

## 📋 目录

1. [违规概述](#1-违规概述)
2. [跨 Feature 依赖详情](#2-跨-feature-依赖详情)
3. [违规严重性分类](#3-违规严重性分类)
4. [修复建议](#4-修复建议)
5. [目标架构依赖规则](#5-目标架构依赖规则)

---

## 1. 违规概述

### 当前 Feature 模块边界状态

```
┌─────────────────────────────────────────────────────────────┐
│                    Feature 依赖关系图                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐              │
│   │  Chat   │────▶│ Wallet  │◀────│ Mining  │              │
│   └────┬────┘     └────┬────┘     └────┬────┘              │
│        │               │               │                    │
│        │               ▼               │                    │
│        │         ┌─────────┐          │                    │
│        └────────▶│ Browser │◀─────────┘                    │
│                  └─────────┘                                │
│                                                             │
│   ────▶ 表示违规依赖                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 统计摘要

| Feature 模块 | 被依赖次数 | 依赖其他 Feature | 违规数 |
|-------------|-----------|-----------------|-------|
| **Wallet** | 39 | 1 (Browser) | 🔴 高 |
| **Chat** | 0 | 1 (Wallet: 12处) | 🟡 中 |
| **Mining** | 1 | 1 (Wallet: 18处) | 🟡 中 |
| **Browser** | 6 | 0 | 🟢 低 |
| **Home** | - | 2 (Wallet: 8处) | 🟡 中 |
| **Auth** | 0 | 0 | 🟢 无 |

---

## 2. 跨 Feature 依赖详情

### 2.1 Chat → Wallet 违规 (12处)

| 文件 | 依赖的 Wallet 组件 | 违规类型 |
|------|-------------------|---------|
| `chat/widgets/item_group_chat_view.dart` | `WalletActionProvider` | 状态访问 |
| `chat/widgets/item_conversation.dart` | `WalletActionProvider` | 状态访问 |
| `chat/widgets/item_chat_view.dart` | `WalletActionProvider` | 状态访问 |
| `chat/widgets/item_chat_reply_inner_widget.dart` | `WalletActionProvider` | 状态访问 |
| `chat/utils/chat_util.dart` | `WalletInfo`, `TrustDart`, `WalletActionProvider`, `ChainUtil` | 多重依赖 |
| `chat/pages/chat_group_detail_page.dart` | `WalletActionProvider`, `BrowserTxhash` | 状态+工具 |
| `chat/pages/chat_index_page.dart` | `WalletActionProvider` | 状态访问 |
| `chat/pages/add_group_member_page.dart` | `WalletActionProvider` | 状态访问 |

**违规原因分析**:
- Chat 模块需要获取当前钱包地址用于消息加密
- 红包功能需要访问钱包余额和交易能力
- 区块浏览器链接生成依赖 Wallet 工具类

### 2.2 Mining → Wallet 违规 (18处)

| 文件 | 依赖的 Wallet 组件 | 违规类型 |
|------|-------------------|---------|
| `miningV2/provider/mining_v2_provider.dart` | `WalletInfo`, `TrustDart`, `WalletActionProvider`, `ChainUtil` | 核心依赖 |
| `miningV2/widgets/mining_board_widget.dart` | `ChainUtil` | 工具依赖 |
| `miningV2/pages/mining_today_v2.dart` | `WalletInfo`, `WalletActionProvider` | 状态访问 |
| `miningV2/pages/mining_background.dart` | `TrustDart` | 钱包库 |
| `miningV2/pages/mining_full_node_v2.dart` | `TokenViewApi`, `WalletInfo`, `SwapAstHome`, `BackupOne`, `TrustDart`, `WalletActionProvider`, `ChainUtil` | 严重耦合 |
| `miningV2/pages/keyManagement/mining_output_pk.dart` | `WalletActionProvider` | 状态访问 |
| `miningV2/api/mining_web3.dart` | `EthApi` | API 依赖 |
| `miningV2/api/mining_api.dart` | `TrustDart` | 钱包库 |

**违规原因分析**:
- 挖矿需要选择钱包地址作为奖励接收地址
- 挖矿交易签名需要访问钱包私钥
- 全节点购买需要 AST 代币交换功能

### 2.3 Wallet → Browser 违规 (6处)

| 文件 | 依赖原因 |
|------|---------|
| `wallet/pages/wallet_chain_info.dart` | 打开区块浏览器 |
| `wallet/pages/wallet_chain_info_xrp.dart` | 打开区块浏览器 |
| `wallet/pages/market/market_coin_info.dart` | 打开项目官网 |
| `wallet/pages/payment_code/payment_history.dart` | 查看交易详情 |
| `wallet/pages/ast_swap/swap_ast_home.dart` | 打开 DApp |
| `wallet/pages/Staking_btc/wallet_chain_info_btc.dart` | 打开区块浏览器 |

**违规原因分析**:
- 需要在应用内打开区块链浏览器查看交易
- 这是一个合理的导航需求，但应通过路由解耦

### 2.4 Wallet ↔ Mining 双向违规

```dart
// wallet_action_provider.dart 依赖 Mining
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
```

**这是最严重的违规** - 创建了循环依赖风险。

### 2.5 Home → Wallet 违规 (8处)

| 文件 | 依赖的 Wallet 组件 |
|------|-------------------|
| `home/setting/security/security_google_vedification.dart` | `WalletInfo`, `WalletActionProvider` |
| `home/setting/account_logout_page.dart` | `ExchangeApi`, `MarketApi` |
| `home/setting/feedback.dart` | `WalletActionProvider` |
| `home/home_page.dart` | `WalletPage` |
| `home/home_draw_page.dart` | `AddressBookList`, `WalletList` |

---

## 3. 违规严重性分类

### 🔴 严重违规 (需立即修复)

| 违规 | 影响 | 修复优先级 |
|------|------|-----------|
| Wallet ↔ Mining 双向依赖 | 循环依赖风险 | P0 |
| `mining_full_node_v2.dart` 导入 7 个 Wallet 组件 | 极度耦合 | P0 |
| `chat_util.dart` 导入 4 个 Wallet 组件 | 核心工具污染 | P1 |

### 🟡 中度违规 (计划修复)

| 违规 | 影响 | 修复优先级 |
|------|------|-----------|
| Chat widgets 访问 WalletActionProvider | 状态耦合 | P2 |
| Mining 访问 ChainUtil | 工具层未抽取 | P2 |
| Home 设置页访问 Wallet API | 业务边界模糊 | P2 |

### 🟢 轻微违规 (可接受)

| 违规 | 说明 |
|------|------|
| Wallet → Browser 导航 | 通过路由系统可解耦 |
| Home → Wallet 页面引用 | 作为容器模块可接受 |

---

## 4. 修复建议

### 4.1 创建共享 Domain 层

**问题**: 多个 Feature 需要访问钱包地址、余额等信息

**解决方案**: 将共享概念提取到 Domain 层

```dart
// lib/domain/entities/wallet_address.dart
class WalletAddress {
  final String address;
  final String chainType;
  // ...
}

// lib/domain/repositories/current_wallet_repository.dart
abstract class CurrentWalletRepository {
  WalletAddress? getCurrentWallet();
  Stream<WalletAddress?> watchCurrentWallet();
}
```

### 4.2 创建共享服务层

**问题**: `ChainUtil`, `TrustDart`, `BrowserTxhash` 被多个 Feature 使用

**解决方案**: 移到 Core 层

```
lib/core/
├── blockchain/
│   ├── chain_util.dart        # 链工具
│   ├── address_formatter.dart # 地址格式化
│   └── tx_hash_builder.dart   # 交易哈希构建器
├── crypto/
│   ├── wallet_core.dart       # TrustWallet 封装
│   └── signing_service.dart   # 签名服务
```

### 4.3 使用事件总线解耦

**问题**: Chat/Mining 需要响应钱包变化

**解决方案**: 使用事件驱动

```dart
// lib/core/events/wallet_events.dart
class WalletChangedEvent {
  final String address;
  final String chainType;
}

class WalletBalanceUpdatedEvent {
  final String address;
  final Map<String, BigInt> balances;
}

// 在 Chat 中监听
eventBus.on<WalletChangedEvent>().listen((event) {
  // 更新聊天加密密钥
});
```

### 4.4 路由导航解耦

**问题**: Wallet 直接 import BrowserPage

**解决方案**: 使用命名路由

```dart
// 旧代码
Navigator.push(context, MaterialPageRoute(builder: (_) => BrowserPage(url: url)));

// 新代码
context.go('/browser?url=${Uri.encodeComponent(url)}');
```

### 4.5 重构 mining_full_node_v2.dart

这个文件违规最严重，需要拆分：

```dart
// 当前 (违规)
import 'package:n42appv2/src/wallet/pages/ast_swap/swap_ast_home.dart';
import 'package:n42appv2/src/wallet/pages/wallet_backup/backup_one.dart';

// 修复方案 1: 使用路由
context.push('/wallet/swap');
context.push('/wallet/backup');

// 修复方案 2: 使用回调
class MiningFullNodePage extends StatelessWidget {
  final VoidCallback? onNeedSwap;
  final VoidCallback? onNeedBackup;
}
```

---

## 5. 目标架构依赖规则

### 合法依赖方向

```
┌───────────────────────────────────────────────────────────┐
│                       Features                             │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐         │
│  │ Wallet  │ │  Chat   │ │ Mining  │ │ Browser │         │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘         │
│       │           │           │           │               │
│       └───────────┴─────┬─────┴───────────┘               │
│                         ▼                                  │
├───────────────────────────────────────────────────────────┤
│                    Presentation                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Shared Providers / Themes / Widgets                │  │
│  └──────────────────────┬──────────────────────────────┘  │
│                         ▼                                  │
├───────────────────────────────────────────────────────────┤
│                      Domain                                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Shared Entities / Repository Interfaces / UseCases │  │
│  └──────────────────────┬──────────────────────────────┘  │
│                         ▼                                  │
├───────────────────────────────────────────────────────────┤
│                       Core                                 │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Network / Storage / Platform / Utils / DI          │  │
│  └─────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### Feature 间通信规则

| 通信类型 | 允许的方式 | 禁止的方式 |
|---------|-----------|-----------|
| 数据共享 | 通过 Domain 层共享实体 | 直接 import 其他 Feature 的 model |
| 状态同步 | 事件总线 / Stream | 直接访问其他 Feature 的 Provider |
| 页面导航 | 路由系统 (go_router) | 直接 import 其他 Feature 的 Page |
| 功能调用 | 通过 Domain UseCase | 直接调用其他 Feature 的方法 |

### 依赖注入原则

```dart
// ✅ 正确: 依赖注入接口
@injectable
class ChatMessageProvider {
  final CurrentWalletRepository _walletRepo; // 依赖接口
  
  ChatMessageProvider(this._walletRepo);
  
  String get currentAddress => _walletRepo.getCurrentWallet()?.address ?? '';
}

// ❌ 错误: 直接依赖具体实现
class ChatMessageProvider {
  String get currentAddress {
    return Provider.of<WalletActionProvider>(context).walletInfo.address;
  }
}
```

---

## 附录: 修复检查清单

### Phase 1: 核心解耦

- [ ] 将 `ChainUtil` 移至 `core/blockchain/`
- [ ] 创建 `CurrentWalletRepository` 接口
- [ ] 将 `TrustDart` 封装为 `core/crypto/wallet_core.dart`

### Phase 2: Feature 隔离

- [ ] 重构 `mining_full_node_v2.dart`，移除直接页面引用
- [ ] 重构 Chat widgets，使用事件订阅替代 Provider 访问
- [ ] 重构 `chat_util.dart`，使用依赖注入

### Phase 3: 路由统一

- [ ] 替换所有 `Navigator.push(BrowserPage)` 为路由调用
- [ ] 替换所有跨 Feature 的页面导航

### Phase 4: 验证

- [ ] 运行 `dart analyze` 无跨 Feature import 警告
- [ ] 每个 Feature 可独立编译
- [ ] 单元测试无跨 Feature mock

---

*报告生成完成，请按优先级逐步修复*

