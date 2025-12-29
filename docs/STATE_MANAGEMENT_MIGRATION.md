# 状态管理迁移指南

## 一、当前状态管理问题分析

### 1.1 PublicProvider 问题 (385 行)

| 职责 | 问题 |
|------|------|
| 用户信息 `_userInfo` | 业务状态，应在 Auth Feature |
| 语言设置 `_locale` | UI 配置，应独立 |
| 主题设置 `_themeMode` | UI 配置，应独立 |
| 锁屏状态 `lockScreenMap` | 安全状态，应在 Security Service |
| Tab 索引 `homeCurrentIndex` | UI 状态，应本地化 |
| 消息计数 `messageNotReadCount` | 业务状态，应在 Chat Feature |
| 加载状态 `load` | UI 状态，无类型安全 |

**问题总结：**
- ❌ 单一 Provider 承载 7+ 不同职责
- ❌ UI 状态与业务状态混合
- ❌ 没有 loading/error/data 状态建模
- ❌ 直接依赖 `SPUtil` 等基础设施类

### 1.2 WalletActionProvider 问题 (1200+ 行)

| 职责 | 问题 |
|------|------|
| 钱包列表 `_walletInfoLsit` | 业务状态 |
| 当前索引 `walletIndex` | UI 状态 |
| 币种模型 `_coinModels` | 业务状态 |
| 余额 `_balanceTotal` | 业务状态 |
| 地址映射 `_addrsss` | 业务状态 |
| 市场信息 `_coinMarketInfo` | 业务状态 |
| 刷新状态 `coinRefreshMap` | UI 状态 |

**严重问题：**
```dart
// ❌ 跨 Provider 直接调用
Provider.of<TransactionRecordItemProvider>(AppGlobals.appContext, listen: false).selectUndoneTr();

// ❌ 跨 Feature 依赖
import 'package:n42appv2/src/miningV2/provider/mining_v2_provider.dart';
```

### 1.3 状态类型混乱

```dart
// ❌ 当前：简单枚举，无错误信息
enum Load { loading, finish }

// ❌ 使用方式：无法表达错误状态
Load _load = Load.loading;
```

---

## 二、目标架构：Riverpod + Clean Architecture

### 2.1 状态分类

| 类型 | 定义 | 示例 | 管理方式 |
|------|------|------|---------|
| **UI 状态** | 界面呈现相关 | 加载中、Tab 索引、弹窗显示 | `StateProvider` / 本地 `useState` |
| **业务状态** | 核心数据 | 钱包列表、余额、交易记录 | `AsyncNotifierProvider` |
| **配置状态** | 用户偏好 | 语言、主题、安全设置 | `NotifierProvider` |
| **临时状态** | 表单数据 | 输入框内容、选择项 | `StateProvider` / 本地状态 |

### 2.2 异步状态建模

```dart
// ✅ Riverpod 内置 AsyncValue
sealed class AsyncValue<T> {
  const factory AsyncValue.data(T value) = AsyncData<T>;
  const factory AsyncValue.error(Object error, StackTrace stackTrace) = AsyncError<T>;
  const factory AsyncValue.loading() = AsyncLoading<T>;
}

// 使用示例
ref.watch(walletsProvider).when(
  data: (wallets) => WalletList(wallets: wallets),
  loading: () => const LoadingIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
);
```

### 2.3 跨页面状态共享规则

| 场景 | 推荐方案 |
|------|---------|
| Feature 内部共享 | `ref.watch(featureInternalProvider)` |
| 跨 Feature 只读 | 通过 Shared Interface 暴露 |
| 跨 Feature 修改 | 通过 Event 或 Service 方法 |
| 临时传递 | 路由参数 |

---

## 三、迁移步骤（渐进式）

### Phase 1: 添加 Riverpod 基础设施 (1 天)

#### Step 1.1: 更新 pubspec.yaml

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.0
  riverpod_lint: ^2.3.10
```

#### Step 1.2: 包装 App 为 ProviderScope

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(Env.prod);
  
  runApp(
    ProviderScope(
      child: MultiProvider(  // 暂时保留 Provider
        providers: [...],
        child: n42appv2(),
      ),
    ),
  );
}
```

### Phase 2: 创建核心 Providers (3-5 天)

#### Step 2.1: 定义 AsyncState 基类

```dart
// lib/core/state/async_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 统一的异步状态基类
typedef AsyncState<T> = AsyncValue<T>;

/// 状态扩展方法
extension AsyncStateX<T> on AsyncValue<T> {
  /// 是否正在刷新（有旧数据但在加载新数据）
  bool get isRefreshing => isLoading && hasValue;
  
  /// 获取数据或默认值
  T dataOr(T defaultValue) => valueOrNull ?? defaultValue;
}
```

#### Step 2.2: 创建配置 Providers

```dart
// lib/core/providers/config_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_providers.g.dart';

/// 主题模式 Provider
@riverpod
class ThemeModeSetting extends _$ThemeModeSetting {
  @override
  ThemeMode build() {
    _loadFromStorage();
    return ThemeMode.system;
  }
  
  void _loadFromStorage() async {
    final mode = await ref.read(spUtilProvider).getThemeMode();
    state = _intToThemeMode(mode ?? 0);
  }
  
  void setTheme(ThemeMode mode) {
    state = mode;
    ref.read(spUtilProvider).setThemeMode(_themeModeToInt(mode));
  }
}

/// 语言设置 Provider
@riverpod
class LocaleSetting extends _$LocaleSetting {
  @override
  Locale build() {
    _loadFromStorage();
    return const Locale('en');
  }
  
  void setLocale(String code) {
    state = _codeToLocale(code);
    ref.read(spUtilProvider).setSysLang(code);
  }
}
```

### Phase 3: 迁移业务状态 (1-2 周)

#### Step 3.1: 创建 Wallet Providers

```dart
// lib/features/wallet/presentation/providers/wallet_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_providers.g.dart';

/// 钱包列表 Provider (异步)
@riverpod
class WalletList extends _$WalletList {
  @override
  Future<List<WalletEntity>> build() async {
    final repository = ref.watch(walletRepositoryProvider);
    final result = await repository.getWallets();
    return result.fold(
      (failure) => throw failure,
      (wallets) => wallets,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(walletRepositoryProvider);
      final result = await repository.getWallets();
      return result.fold(
        (failure) => throw failure,
        (wallets) => wallets,
      );
    });
  }
  
  Future<void> createWallet(CreateWalletParams params) async {
    final repository = ref.read(walletRepositoryProvider);
    final result = await repository.createWallet(
      name: params.name,
      password: params.password,
      chainType: params.chainType,
    );
    result.fold(
      (failure) => throw failure,
      (wallet) {
        final current = state.valueOrNull ?? [];
        state = AsyncValue.data([...current, wallet]);
      },
    );
  }
}

/// 当前选中钱包索引
@riverpod
class SelectedWalletIndex extends _$SelectedWalletIndex {
  @override
  int build() => 0;
  
  void select(int index) {
    state = index;
    ref.read(spUtilProvider).setCurrentWalletIndex(index);
  }
}

/// 当前选中钱包 (派生状态)
@riverpod
WalletEntity? currentWallet(CurrentWalletRef ref) {
  final wallets = ref.watch(walletListProvider);
  final index = ref.watch(selectedWalletIndexProvider);
  
  return wallets.whenOrNull(
    data: (list) => index < list.length ? list[index] : null,
  );
}

/// 钱包总余额 Provider
@riverpod
class WalletBalance extends _$WalletBalance {
  @override
  Future<double> build() async {
    final wallet = ref.watch(currentWalletProvider);
    if (wallet == null) return 0.0;
    
    final repository = ref.watch(walletRepositoryProvider);
    final result = await repository.getAssets(address: wallet.address);
    
    return result.fold(
      (failure) => throw failure,
      (assets) => assets.fold(0.0, (sum, asset) => sum + asset.valueUsd),
    );
  }
}

/// 币种列表 Provider
@riverpod
class CoinList extends _$CoinList {
  @override
  Future<List<AssetEntity>> build() async {
    final wallet = ref.watch(currentWalletProvider);
    if (wallet == null) return [];
    
    final repository = ref.watch(walletRepositoryProvider);
    final result = await repository.getAssets(address: wallet.address);
    
    return result.fold(
      (failure) => throw failure,
      (assets) => assets,
    );
  }
  
  Future<void> refreshBalance(String tokenAddress) async {
    // 刷新特定 token 余额
  }
}
```

#### Step 3.2: 创建适配层（兼容旧代码）

```dart
// lib/core/providers/legacy_adapter.dart
/// 适配层：让旧 Provider 代码能访问新 Riverpod 状态

class WalletProviderAdapter extends ChangeNotifier {
  final Ref _ref;
  
  WalletProviderAdapter(this._ref) {
    // 监听 Riverpod 状态变化，通知 ChangeNotifier
    _ref.listen(walletListProvider, (_, __) => notifyListeners());
    _ref.listen(selectedWalletIndexProvider, (_, __) => notifyListeners());
  }
  
  List<WalletEntity> get walletInfoLsit {
    return _ref.read(walletListProvider).valueOrNull ?? [];
  }
  
  int get walletIndex => _ref.read(selectedWalletIndexProvider);
  
  WalletEntity? get walletInfo {
    return _ref.read(currentWalletProvider);
  }
  
  // ... 其他旧接口适配
}
```

### Phase 4: 迁移 UI 代码 (持续)

#### Step 4.1: 新页面使用 Riverpod

```dart
// lib/features/wallet/presentation/pages/wallet_page.dart
class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    final balance = ref.watch(walletBalanceProvider);
    
    return Scaffold(
      body: walletsAsync.when(
        data: (wallets) => _buildContent(context, ref, wallets, balance),
        loading: () => const WalletSkeleton(),
        error: (error, stack) => WalletErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(walletListProvider),
        ),
      ),
    );
  }
  
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<WalletEntity> wallets,
    AsyncValue<double> balance,
  ) {
    return Column(
      children: [
        // 余额卡片
        balance.when(
          data: (value) => BalanceCard(balance: value),
          loading: () => const BalanceCardSkeleton(),
          error: (_, __) => BalanceCard(balance: 0),
        ),
        
        // 币种列表
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final coins = ref.watch(coinListProvider);
              return coins.when(
                data: (list) => CoinListView(coins: list),
                loading: () => const CoinListSkeleton(),
                error: (e, _) => CoinListError(error: e),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

#### Step 4.2: 旧页面渐进迁移

```dart
// 旧页面：保持 Provider，但内部逐步使用 Riverpod
class OldWalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 旧代码仍然可用
    final oldProvider = Provider.of<WalletActionProvider>(context);
    
    // 新部分使用 Consumer
    return Consumer(
      builder: (context, ref, _) {
        // 新状态
        final balance = ref.watch(walletBalanceProvider);
        
        return Column(
          children: [
            // 新组件
            balance.when(...),
            
            // 旧组件 (逐步替换)
            OldCoinList(provider: oldProvider),
          ],
        );
      },
    );
  }
}
```

### Phase 5: 移除旧 Provider (最后阶段)

```dart
// 当所有页面迁移完成后，移除旧 Provider
// main.dart
void main() async {
  runApp(
    ProviderScope(
      child: n42appv2(), // 不再需要 MultiProvider
    ),
  );
}
```

---

## 四、实现 Service 接口

### 4.1 IWalletService 实现

```dart
// lib/features/wallet/data/services/wallet_service_impl.dart
@LazySingleton(as: IWalletService)
class WalletServiceImpl implements IWalletService {
  final Ref _ref;
  
  WalletServiceImpl(this._ref);
  
  @override
  SharedWalletInfo? getCurrentWallet() {
    final wallet = _ref.read(currentWalletProvider);
    if (wallet == null) return null;
    
    return SharedWalletInfo(
      address: wallet.address,
      name: wallet.name,
      chainType: wallet.chainType.name,
    );
  }
  
  @override
  SharedWalletInfo? getWalletByAddress(String address) {
    final wallets = _ref.read(walletListProvider).valueOrNull ?? [];
    final wallet = wallets.firstWhereOrNull((w) => w.address == address);
    if (wallet == null) return null;
    
    return SharedWalletInfo(
      address: wallet.address,
      name: wallet.name,
      chainType: wallet.chainType.name,
    );
  }
  
  @override
  List<SharedWalletInfo> getAllWallets() {
    final wallets = _ref.read(walletListProvider).valueOrNull ?? [];
    return wallets.map((w) => SharedWalletInfo(
      address: w.address,
      name: w.name,
      chainType: w.chainType.name,
    )).toList();
  }
  
  @override
  bool walletExists(String address) {
    return getWalletByAddress(address) != null;
  }
  
  @override
  Stream<SharedWalletInfo?> get currentWalletStream {
    return _ref.watch(currentWalletProvider.stream).map((wallet) {
      if (wallet == null) return null;
      return SharedWalletInfo(
        address: wallet.address,
        name: wallet.name,
        chainType: wallet.chainType.name,
      );
    });
  }
}
```

---

## 五、Provider 拆分规划

### 5.1 PublicProvider 拆分

| 原职责 | 新 Provider | 类型 |
|--------|------------|------|
| `_userInfo` | `currentUserProvider` | `AsyncNotifierProvider` |
| `_locale` | `localeSettingProvider` | `NotifierProvider` |
| `_themeMode` | `themeModeSettingProvider` | `NotifierProvider` |
| `lockScreenMap` | `securitySettingsProvider` | `NotifierProvider` |
| `homeCurrentIndex` | `homeTabIndexProvider` | `StateProvider` |
| `messageNotReadCount` | `unreadCountProvider` | `AsyncNotifierProvider` |

### 5.2 WalletActionProvider 拆分

| 原职责 | 新 Provider | 类型 |
|--------|------------|------|
| `_walletInfoLsit` | `walletListProvider` | `AsyncNotifierProvider` |
| `walletIndex` | `selectedWalletIndexProvider` | `NotifierProvider` |
| `_coinModels` | `coinListProvider` | `AsyncNotifierProvider` |
| `_balanceTotal` | `walletBalanceProvider` | `AsyncNotifierProvider` |
| `_addrsss` | `addressMapProvider` | `NotifierProvider` |
| `_coinMarketInfo` | `marketInfoProvider` | `AsyncNotifierProvider` |

---

## 六、迁移检查清单

### Phase 1 检查

- [ ] Riverpod 依赖已添加
- [ ] ProviderScope 已包装 App
- [ ] 基础 Provider 生成代码正常

### Phase 2 检查

- [ ] 配置 Providers 已创建
- [ ] 主题/语言切换正常工作
- [ ] 旧 Provider 仍然可用

### Phase 3 检查

- [ ] Wallet Providers 已创建
- [ ] 适配层已实现
- [ ] IWalletService 已实现
- [ ] 跨 Feature 调用通过接口

### Phase 4 检查

- [ ] 新页面使用 ConsumerWidget
- [ ] 异步状态有 loading/error 处理
- [ ] 旧页面逐步迁移

### Phase 5 检查

- [ ] 所有页面已迁移
- [ ] MultiProvider 已移除
- [ ] 旧 Provider 文件已删除
- [ ] 测试全部通过

---

## 七、常见问题

### Q1: 如何处理 context 访问？

```dart
// ❌ 旧方式
Provider.of<WalletActionProvider>(AppGlobals.appContext, listen: false)

// ✅ 新方式 - 在 Widget 中
ref.read(walletListProvider)

// ✅ 新方式 - 在其他 Provider 中
ref.watch(otherProvider)

// ✅ 新方式 - 在 Service 中（通过 DI 传入 Ref）
class MyService {
  final Ref _ref;
  MyService(this._ref);
}
```

### Q2: 如何处理 notifyListeners？

```dart
// ❌ 旧方式
state = newValue;
notifyListeners();

// ✅ Riverpod 自动通知
state = newValue; // 自动触发重建
```

### Q3: 如何处理初始化？

```dart
// ❌ 旧方式 - 在构造函数
PublicProvider() {
  _getSysLangType();
}

// ✅ 新方式 - 在 build 方法
@override
Locale build() {
  _loadFromStorage(); // 异步加载
  return const Locale('en'); // 同步返回默认值
}
```

---

**文档版本**: 1.0
**最后更新**: 2025-01

