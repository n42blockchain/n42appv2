# Feature 边界违规修复计划

## 一、修复优先级

### P0 - 高优先级 (立即修复)

| 违规 | 文件数 | 修复方案 |
|------|-------|---------|
| `WalletActionProvider` 跨 Feature | 64 | 使用 `IWalletService` 接口 |
| `PublicProvider` 跨 Feature | 10 | 使用 Riverpod Providers |

### P1 - 中优先级 (1-2 周)

| 违规 | 文件数 | 修复方案 |
|------|-------|---------|
| Chat → Wallet 依赖 | 8 | 通过 `EventManager` 通信 |
| Mining → Wallet 依赖 | 8 | 使用 `IWalletService` |

---

## 二、修复步骤

### Step 1: 替换 Provider.of<WalletActionProvider> 调用

#### 1.1 修复模式

```dart
// ❌ 旧代码 (违规)
import 'package:provider/provider.dart';
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';

class SomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletActionProvider>(context);
    final address = walletProvider.getAddress('ETH');
    // ...
  }
}

// ✅ 新代码 (合规) - 方式 1: 使用 Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/presentation/providers/wallet_providers.dart';

class SomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(currentWalletProvider);
    final address = wallet?.coinInfo?['ETH']?['baseInfo']?['address'];
    // ...
  }
}

// ✅ 新代码 (合规) - 方式 2: 使用 Service 接口 (跨 Feature)
import 'package:get_it/get_it.dart';
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';

class SomePage extends StatelessWidget {
  final IWalletService _walletService = getIt<IWalletService>();
  
  @override
  Widget build(BuildContext context) {
    final wallet = _walletService.getCurrentWallet();
    final address = wallet?.address;
    // ...
  }
}
```

#### 1.2 Chat Feature 修复示例

```dart
// lib/src/chat/utils/chat_util.dart
// ❌ 旧代码
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';

String getWalletAddress(BuildContext context) {
  final provider = Provider.of<WalletActionProvider>(context, listen: false);
  return provider.getAddress('ETH') ?? '';
}

// ✅ 新代码
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';
import 'package:get_it/get_it.dart';

String getWalletAddress() {
  final walletService = GetIt.instance<IWalletService>();
  return walletService.getCurrentWallet()?.address ?? '';
}
```

#### 1.3 Mining Feature 修复示例

```dart
// lib/src/miningV2/provider/mining_v2_provider.dart
// ❌ 旧代码
import 'package:n42appv2/src/wallet/provider/wallet_action_provider.dart';

class MiningV2Provider extends ChangeNotifier {
  void startMining(BuildContext context) {
    final walletProvider = Provider.of<WalletActionProvider>(context, listen: false);
    final address = walletProvider.getAddress('ETH');
    // ...
  }
}

// ✅ 新代码
import 'package:n42appv2/shared/domain/services/wallet_service_interface.dart';

class MiningV2Provider extends ChangeNotifier {
  final IWalletService _walletService;
  
  MiningV2Provider(this._walletService);
  
  void startMining() {
    final wallet = _walletService.getCurrentWallet();
    final address = wallet?.address;
    // ...
  }
}
```

---

### Step 2: 注册 Service 到 DI

```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42appv2/features/wallet/data/services/wallet_service_impl.dart';
import 'package:n42appv2/features/auth/data/services/auth_service_impl.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies(Env env) async {
  // Create Riverpod container
  final container = ProviderContainer();
  
  // Register Riverpod container
  getIt.registerSingleton<ProviderContainer>(container);
  
  // Register services
  getIt.registerLazySingleton<IWalletService>(
    () => WalletServiceImpl(container),
  );
  
  getIt.registerLazySingleton<IAuthService>(
    () => AuthServiceImpl(SPUtil(), SecureStorage()),
  );
}
```

---

### Step 3: 使用 EventManager 替代跨 Feature 直接调用

```dart
// 在 Mining Feature 中监听钱包变更
// lib/features/mining/presentation/providers/mining_provider.dart

import 'package:n42appv2/shared/events/event_manager.dart';
import 'package:n42appv2/shared/events/cross_feature_events.dart';

class MiningProvider extends ChangeNotifier with EventListenerMixin {
  String? _currentWalletAddress;
  
  MiningProvider() {
    _initEventListeners();
  }
  
  void _initEventListeners() {
    // 监听钱包选择事件
    subscribeToEvent<WalletSelectedEvent>((event) {
      _currentWalletAddress = event.wallet.address;
      notifyListeners();
    });
    
    // 监听余额更新事件
    subscribeToEvent<WalletBalanceUpdatedEvent>((event) {
      if (event.walletAddress == _currentWalletAddress) {
        // 更新显示
        notifyListeners();
      }
    });
  }
  
  @override
  void dispose() {
    unsubscribeFromAllEvents();
    super.dispose();
  }
}
```

---

## 三、修复文件清单

### 3.1 Chat Feature (8 files)

| 文件 | 修复状态 | 方案 |
|------|---------|------|
| `chat_index_page.dart` | ✅ 已完成 | Riverpod + Service |
| `chat_group_detail_page.dart` | ✅ 已完成 | Service 接口 |
| `add_group_member_page.dart` | ✅ 已完成 | Service 接口 |
| `item_group_chat_view.dart` | ✅ 已完成 | Service 接口 |
| `item_conversation.dart` | ✅ 已完成 | Service 接口 |
| `item_chat_view.dart` | ✅ 已完成 | Service 接口 |
| `item_chat_reply_inner_widget.dart` | ✅ 已完成 | Service 接口 |
| `chat_util.dart` | ✅ 已完成 | Service 接口 |

### 3.2 Mining Feature (8 files)

| 文件 | 修复状态 | 方案 |
|------|---------|------|
| `mining_v2_provider.dart` | 🟡 90% | DI + Service (钱包创建待迁移) |
| `mining_today_v2.dart` | ✅ 已完成 | MiningV2Provider |
| `mining_full_node_v2.dart` | ✅ 已完成 | IWalletService |
| `mining_background.dart` | ✅ 已完成 | Service 接口 |
| `mining_board_widget.dart` | ✅ 已完成 | Riverpod |
| `mining_output_pk.dart` | ✅ 已完成 | IWalletService |
| `mining_api.dart` | ✅ 已完成 | Service 接口 |
| `mining_web3.dart` | ✅ 已完成 | Service 接口 |

### 3.3 WalletConnect Feature (2 files)

| 文件 | 修复状态 | 方案 |
|------|---------|------|
| `wallet_connect_provider.dart` | ⬜ 待修复 | Riverpod |
| `wallet_connect_page.dart` | ⬜ 待修复 | Riverpod |

### 3.4 Home/Setting Feature (8 files)

| 文件 | 修复状态 | 方案 |
|------|---------|------|
| `home_page.dart` | ✅ 已完成 | Riverpod |
| `unlock.dart` | ✅ 已完成 | Riverpod |
| `home_draw_page.dart` | ✅ 已完成 | Riverpod |
| `setting_home_page.dart` | ✅ 已完成 | Riverpod |
| `security_google_vedification.dart` | ⬜ 待修复 | Riverpod |
| `feedback.dart` | ⬜ 待修复 | Riverpod |
| `setting_theme.dart` | ✅ 已完成 | Riverpod |
| `setting_sys_language.dart` | ✅ 已完成 | Riverpod |

### 3.5 公共组件 (1 file)

| 文件 | 修复状态 | 方案 |
|------|---------|------|
| `app_home_top_bar.dart` | ✅ 已完成 | Riverpod |

---

## 四、自动化修复脚本

### 4.1 查找违规文件

```powershell
# scripts/find_violations.ps1
$violations = @()

# 查找 WalletActionProvider 违规
$files = Get-ChildItem -Path "lib/src" -Filter "*.dart" -Recurse
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "Provider\.of<WalletActionProvider>" -or 
        $content -match "context\.read<WalletActionProvider>") {
        $violations += @{
            File = $file.FullName
            Type = "WalletActionProvider"
        }
    }
}

# 输出报告
$violations | ForEach-Object {
    Write-Host "$($_.Type): $($_.File)"
}
```

### 4.2 半自动修复

```powershell
# scripts/fix_wallet_provider.ps1
param(
    [string]$FilePath
)

$content = Get-Content $FilePath -Raw

# 添加新 import
if ($content -notmatch "flutter_riverpod") {
    $content = "import 'package:flutter_riverpod/flutter_riverpod.dart';`n" + $content
}

# 提示手动修复点
Write-Host "File: $FilePath"
Write-Host "Manual fixes needed:"
Select-String -Path $FilePath -Pattern "Provider\.of<WalletActionProvider>" | ForEach-Object {
    Write-Host "  Line $($_.LineNumber): $($_.Line.Trim())"
}
```

---

## 五、验证检查

### 修复后运行

```bash
# 1. 静态分析
flutter analyze

# 2. 检查是否还有违规
grep -r "Provider.of<WalletActionProvider>" lib/src/chat/
grep -r "Provider.of<WalletActionProvider>" lib/src/miningV2/

# 3. 运行测试
flutter test

# 4. 功能测试
flutter run
```

---

## 六、进度追踪

| 阶段 | 完成度 | 备注 |
|------|--------|------|
| 基础设施准备 | ✅ 100% | Riverpod, Services, Events |
| Settings Feature 迁移 | ✅ 100% | Theme, Language, Feedback, Security |
| Chat Feature 修复 | ✅ 100% | 8 files - 使用 Services |
| Mining Feature 修复 | 🟡 90% | 7/8 files - 1 file 待创建钱包迁移 |
| Home Feature 迁移 | ✅ 100% | HomePage, UnlockPage, HomeDrawPage |
| 公共组件迁移 | ✅ 100% | AppHomeTopBar |
| WalletConnect Feature | ✅ 100% | Provider + Page 迁移完成 |
| Login Feature | ✅ 100% | LoginPage, AccountCreateAndReset |
| Notification Feature | ✅ 100% | MessageList, app_push_utils |
| Wallet Feature 内部 | 🟡 5% | 187处通过 LegacyAdapter 工作 |

### 最新更新 (2025-01-xx)

**已完成:**
- ✅ WalletConnectProvider 使用 IWalletService 获取钱包信息
- ✅ WalletConnectPage 转换为 ConsumerStatefulWidget
- ✅ MessageList 使用 Riverpod
- ✅ LoginPage/AccountCreateAndReset 使用 currentUserProvider
- ✅ app_push_utils 使用 globalProviderContainer

**剩余工作:**
- lock_screen_resetpassword.dart - 通过 LegacyAdapter 工作
- personal_setting.dart - editUserInfo 通过 LegacyAdapter 工作
- security_setting.dart - 通过 LegacyAdapter 工作
- gesture_password_setting.dart - 通过 LegacyAdapter 工作
- application.dart - 已迁移，但保留部分 Legacy 调用
- wallet_connect_provider.dart - coinModels 通过 LegacyAdapter 工作
- Wallet 模块内部 176 处 - 通过 LegacyAdapter 正常工作

**统计摘要:**
- 总边界违规: 188 处 (55 文件)
- Wallet 模块内部: 176 处 (已在模块内，非跨模块违规)
- 需通过 LegacyAdapter 工作: 12 处 (已验证正常)

---

**文档版本**: 1.0
**最后更新**: 2025-01

