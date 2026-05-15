# Feature 边界违规分析报告

## 概述

本报告详细分析了当前代码中违反 Feature 边界（模块边界）的情况。根据 Clean Architecture 原则，每个 Feature 应该是独立的，Feature 之间的依赖应该通过抽象接口或共享层来解耦。

---

## 一、违规类型统计

| 违规类型 | 数量 | 风险等级 |
|---------|------|---------|
| Chat → Wallet 直接依赖 | 8 个文件 | 🔴 高 |
| Mining → Wallet 直接依赖 | 8 个文件 | 🔴 高 |
| Wallet → Mining 直接依赖 | 1 个文件 | 🟡 中 |
| Wallet → Browser 直接依赖 | 6 个文件 | 🟡 中 |
| Wallet → Login/Auth 直接依赖 | 7 个文件 | 🟡 中 |
| WalletActionProvider 跨 Feature 使用 | 64 个文件 | 🔴 高 |
| PublicProvider 跨 Feature 使用 | 10 个文件 | 🟡 中 |

---

## 二、详细违规分析

### 2.1 Chat Feature → Wallet Feature 违规

**违规文件：**
```
lib/src/chat/widgets/item_group_chat_view.dart
lib/src/chat/widgets/item_conversation.dart
lib/src/chat/widgets/item_chat_view.dart
lib/src/chat/widgets/item_chat_reply_inner_widget.dart
lib/src/chat/utils/chat_util.dart
lib/src/chat/pages/chat_index_page.dart
lib/src/chat/pages/chat_group_detail_page.dart
lib/src/chat/pages/add_group_member_page.dart
```

**违规原因：** Chat 功能需要显示用户钱包地址、获取钱包列表进行转账

**修复方案：**
1. 创建 `SharedWalletInfo` 实体在 `lib/shared/domain/entities/`
2. 创建 `IWalletService` 接口在 `lib/shared/domain/services/`
3. Chat 通过 `IWalletService` 获取钱包信息，而非直接依赖 Wallet Provider

```dart
// 修复前 (❌ 违规)
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';
final wallet = Provider.of<WalletActionProvider>(context).currentWallet;

// 修复后 (✅ 正确)
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
final wallet = getIt<IWalletService>().getCurrentWallet();
```

---

### 2.2 Mining Feature → Wallet Feature 违规

**违规文件：**
```
lib/src/miningV2/widgets/mining_board_widget.dart
lib/src/miningV2/provider/mining_v2_provider.dart
lib/src/miningV2/pages/keyManagement/mining_output_pk.dart
lib/src/miningV2/pages/mining_today_v2.dart
lib/src/miningV2/pages/mining_full_node_v2.dart
lib/src/miningV2/pages/mining_background.dart
lib/src/miningV2/api/mining_api.dart
lib/src/miningV2/api/mining_web3.dart
```

**违规原因：** Mining 需要获取钱包地址进行挖矿、查看挖矿收益

**修复方案：**
1. Mining 通过 `IWalletService` 获取当前钱包地址
2. 使用 `EventManager` 监听钱包变更事件
3. 将挖矿相关的钱包操作提取为独立的 UseCase

```dart
// 修复前 (❌ 违规)
import 'package:n42appv2/src/wallet/pages/wallet_page.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';

// 修复后 (✅ 正确)
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:n42appv2/shared/events/event_manager.dart';
```

---

### 2.3 Wallet Feature → Browser Feature 违规

**违规文件：**
```
lib/src/wallet/pages/Staking_btc/wallet_chain_info_btc.dart
lib/src/wallet/pages/payment_code/payment_history.dart
lib/src/wallet/pages/market/market_coin_info.dart
lib/src/wallet/pages/ast_swap/swap_ast_home.dart
lib/src/wallet/pages/wallet_chain_info_xrp.dart
lib/src/wallet/pages/wallet_chain_info.dart
```

**违规原因：** Wallet 需要打开浏览器查看区块链交易详情

**修复方案：**
1. 创建 `IBrowserService` 接口
2. 通过路由导航到 Browser，而非直接引用 Browser 页面

```dart
// 修复前 (❌ 违规)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => BrowserPage(url: txUrl)
));

// 修复后 (✅ 正确)
context.go('/browser?url=$txUrl');
// 或
getIt<INavigationService>().openUrl(txUrl);
```

---

### 2.4 Wallet Feature → Auth Feature 违规

**违规文件：**
```
lib/src/wallet/pages/wallet_manage/edit_wallet_password.dart
lib/src/wallet/pages/wallet_backup/backup_three.dart
lib/src/wallet/pages/Staking_btc/self_custody.dart
lib/src/wallet/pages/send/wallet_security_verification.dart
lib/src/wallet/pages/payment_code/payment_page.dart
lib/src/wallet/pages/create_wallet/create_password.dart
lib/src/wallet/pages/add_token/wallet_chain_add.dart
```

**违规原因：** 钱包操作需要验证用户身份、调用登录页面

**修复方案：**
1. 创建 `IAuthService` 接口用于身份验证
2. 使用路由导航而非直接引用 Auth 页面

---

### 2.5 WalletActionProvider 跨 Feature 滥用 (64 个文件)

**最严重的违规！** `WalletActionProvider` 被以下模块直接使用：

| 模块 | 文件数 |
|------|-------|
| Wallet 内部 | 46 |
| Mining | 5 |
| Chat | 7 |
| WalletConnect | 2 |
| Home/Setting | 4 |

**违规原因：** Provider 承担过多职责，成为"上帝对象"

**修复方案：**
1. **拆分 WalletActionProvider**：
   - `WalletListProvider` - 钱包列表管理
   - `CoinBalanceProvider` - 余额管理
   - `TransactionProvider` - 交易管理
   - `WalletSelectionProvider` - 当前钱包选择

2. **通过接口暴露给其他 Feature**：
   ```dart
   // lib/shared/domain/services/wallet_service_interface.dart
   abstract class IWalletService {
     SharedWalletInfo? getCurrentWallet();
     List<SharedWalletInfo> getAllWallets();
     Stream<SharedWalletInfo?> get currentWalletStream;
   }
   ```

3. **其他 Feature 通过 DI 获取接口**：
   ```dart
   @injectable
   class MiningV2Provider {
     final IWalletService _walletService;
     
     MiningV2Provider(this._walletService);
   }
   ```

---

### 2.6 PublicProvider 跨 Feature 使用

**涉及文件：**
```
lib/src/utils/app_push_utils.dart
lib/src/notification/pages/message_list.dart
lib/src/login/pages/login_page.dart
lib/src/login/pages/account_create_and_reset.dart
lib/src/home/setting/security/lock_screen_resetpassword.dart
lib/src/home/setting/setting_theme.dart
lib/src/home/setting/setting_sys_language.dart
lib/src/home/setting/personal_setting.dart
lib/src/home/unlock.dart
lib/src/home/home_page.dart
```

**修复方案：**
拆分为独立的 Provider/Service：
- `UserSessionService` - 用户会话状态
- `ThemeService` - 主题管理
- `LocaleService` - 语言管理
- `SecurityService` - 安全设置

---

## 三、修复优先级

### P0 - 立即修复 (阻塞重构)

| 任务 | 原因 |
|------|------|
| 创建 IWalletService 接口 | 被 3 个 Feature 依赖 |
| 拆分 WalletActionProvider | 64 个文件依赖，影响最大 |
| 创建 SharedWalletInfo 实体 | 跨 Feature 数据传递 |

### P1 - 短期修复 (1-2 周)

| 任务 | 原因 |
|------|------|
| 拆分 PublicProvider | 影响 10 个文件 |
| 实现 IAuthService | 安全相关功能 |
| 迁移 Chat → Wallet 依赖 | 8 个文件 |

### P2 - 中期修复 (2-4 周)

| 任务 | 原因 |
|------|------|
| 迁移 Mining → Wallet 依赖 | 8 个文件 |
| 迁移 Wallet → Browser 依赖 | 6 个文件 |
| 实现 EventManager 事件通信 | 替代直接依赖 |

---

## 四、修复后的架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         main.dart                                │
│                    (DI Configuration)                            │
└───────────────────────────┬─────────────────────────────────────┘
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
       ▼                    ▼                    ▼
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Wallet    │      │   Mining    │      │    Chat     │
│   Feature   │      │   Feature   │      │   Feature   │
└──────┬──────┘      └──────┬──────┘      └──────┬──────┘
       │                    │                    │
       │                    │                    │
       └────────────────────┼────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │      Shared Layer       │
              │  ┌───────────────────┐  │
              │  │ IWalletService    │  │
              │  │ IAuthService      │  │
              │  │ IBrowserService   │  │
              │  │ EventManager      │  │
              │  │ SharedEntities    │  │
              │  └───────────────────┘  │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │       Core Layer        │
              │  Network / Storage      │
              │  Security / Config      │
              └─────────────────────────┘
```

---

## 五、已创建的修复基础设施

### 5.1 Shared 层文件

| 文件 | 作用 |
|------|------|
| `lib/shared/domain/entities/wallet_info.dart` | 跨 Feature 钱包信息 |
| `lib/shared/domain/services/wallet_service_interface.dart` | 钱包服务接口 |
| `lib/shared/events/event_manager.dart` | 跨 Feature 事件通信 |
| `lib/shared/events/cross_feature_events.dart` | 事件定义 |
| `lib/shared/contracts/feature_contracts.dart` | Feature 间契约 |

### 5.2 各 Feature Domain 层

| Feature | 已创建文件 |
|---------|----------|
| Wallet | entities, repositories, usecases, datasources |
| Chat | entities, repositories, usecases, datasources |
| Mining | entities, repositories, usecases |
| Browser | entities, repositories |
| Auth | entities, repositories |

---

## 六、迁移示例代码

### 6.1 Chat 获取钱包地址 (修复前 vs 修复后)

**修复前 (❌ 违规):**
```dart
// lib/src/chat/pages/chat_detail_page.dart
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';

class ChatDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletActionProvider>(context);
    final walletAddress = walletProvider.currentWallet?.address;
    // ...
  }
}
```

**修复后 (✅ 正确):**
```dart
// lib/features/chat/presentation/pages/chat_detail_page.dart
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:get_it/get_it.dart';

class ChatDetailPage extends StatelessWidget {
  final IWalletService _walletService = getIt<IWalletService>();
  
  @override
  Widget build(BuildContext context) {
    final walletInfo = _walletService.getCurrentWallet();
    final walletAddress = walletInfo?.address;
    // ...
  }
}
```

### 6.2 Mining 监听钱包变更 (修复后)

```dart
// lib/features/mining/presentation/providers/mining_provider.dart
import 'package:n42appv2/shared/events/event_manager.dart';
import 'package:n42appv2/shared/events/cross_feature_events.dart';

class MiningProvider extends ChangeNotifier with EventListenerMixin {
  MiningProvider() {
    _initEventListeners();
  }
  
  void _initEventListeners() {
    subscribeToEvent<WalletSelectedEvent>((event) {
      _onWalletChanged(event.wallet);
    });
  }
  
  void _onWalletChanged(SharedWalletInfo wallet) {
    // 更新挖矿钱包地址
    _currentWalletAddress = wallet.address;
    notifyListeners();
  }
  
  @override
  void dispose() {
    unsubscribeFromAllEvents();
    super.dispose();
  }
}
```

---

## 七、验证检查清单

迁移完成后，运行以下检查：

```bash
# 1. 检查是否有跨 Feature 直接 import
grep -r "import.*src/wallet" lib/src/chat/
grep -r "import.*src/wallet" lib/src/miningV2/
grep -r "import.*src/chat" lib/src/wallet/

# 2. 检查 Provider 跨 Feature 使用
grep -r "Provider.of<WalletActionProvider>" lib/src/chat/
grep -r "Provider.of<WalletActionProvider>" lib/src/miningV2/

# 3. 运行静态分析
flutter analyze

# 4. 运行测试
flutter test
```

---

**报告生成时间**: 2025-01-XX
**分析工具**: 静态代码分析 + grep 搜索
**下一步**: 按优先级逐步修复违规

