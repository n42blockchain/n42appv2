# N42Wallet 企业级工程化重构方案

> **版本**: 1.0.0  
> **日期**: 2024-12-29  
> **目标**: Android / iOS 行为一致、架构清晰、安全合规、性能可量化、测试完整、CI友好

---

## 📋 目录

1. [现状分析与问题清单](#1-现状分析与问题清单)
2. [目标架构设计](#2-目标架构设计)
3. [重构路线图](#3-重构路线图)
4. [详细实施方案](#4-详细实施方案)
5. [迁移策略](#5-迁移策略)
6. [验证与回滚机制](#6-验证与回滚机制)

---

## 1. 现状分析与问题清单

### 1.1 架构层面

| 问题 | 当前状态 | 风险等级 |
|------|----------|----------|
| 分层不清晰 | UI层直接调用API，无Repository/UseCase抽象 | 🔴 高 |
| 全局状态管理 | `Application` 类存储全局状态，单例模式滥用 | 🔴 高 |
| 依赖注入缺失 | 手动在 `main.dart` 创建 Provider，紧耦合 | 🟡 中 |
| 路由分散 | 部分在 `main.dart`，部分使用 `Navigator.push` | 🟡 中 |

### 1.2 代码质量

| 问题 | 当前状态 | 风险等级 |
|------|----------|----------|
| 测试覆盖率 | 仅有模板测试文件，无实际测试 | 🔴 高 |
| CI/CD 缺失 | 无自动化构建和发布流程 | 🔴 高 |
| Linter 配置 | 使用默认 `flutter_lints`，规则宽松 | 🟡 中 |
| 代码命名 | 存在拼音命名、下划线命名不一致 | 🟢 低 |

### 1.3 安全性

| 问题 | 当前状态 | 风险等级 |
|------|----------|----------|
| SSL 验证 | `BadCertificateCallback` 返回 `true`，绕过验证 | 🔴 高 |
| 敏感数据存储 | 钱包信息存储在明文 `SharedPreferences` | 🔴 高 |
| 代码混淆 | `isMinifyEnabled = false`，未启用混淆 | 🟡 中 |
| API 密钥 | 硬编码在 `AppConfig` | 🟡 中 |

### 1.4 平台一致性

| 问题 | 当前状态 | 风险等级 |
|------|----------|----------|
| Deep Link | iOS/Android 配置分散，scheme 不完全一致 | 🟡 中 |
| 推送通知 | FCM 集成，但错误处理不完善 | 🟡 中 |
| 生物识别 | `local_auth` 使用，但无统一封装 | 🟢 低 |

---

## 2. 目标架构设计

### 2.1 Clean Architecture 分层

```
lib/
├── core/                          # 核心基础设施
│   ├── di/                        # 依赖注入
│   │   ├── injection.dart         # 注入容器
│   │   └── injection.config.dart  # 自动生成
│   ├── error/                     # 错误处理
│   │   ├── exceptions.dart        # 异常定义
│   │   └── failures.dart          # 失败类型
│   ├── network/                   # 网络层
│   │   ├── api_client.dart        # HTTP 客户端
│   │   ├── interceptors/          # 拦截器
│   │   └── network_info.dart      # 网络状态
│   ├── security/                  # 安全模块
│   │   ├── secure_storage.dart    # 加密存储
│   │   ├── ssl_pinning.dart       # SSL 固定
│   │   └── obfuscation.dart       # 混淆配置
│   ├── router/                    # 路由系统
│   │   ├── app_router.dart        # 路由定义
│   │   └── route_guards.dart      # 路由守卫
│   └── platform/                  # 平台通道
│       ├── biometric_service.dart
│       └── deep_link_service.dart
│
├── domain/                        # 领域层（纯 Dart）
│   ├── entities/                  # 实体
│   │   ├── user.dart
│   │   ├── wallet.dart
│   │   └── transaction.dart
│   ├── repositories/              # 仓库接口
│   │   ├── auth_repository.dart
│   │   └── wallet_repository.dart
│   └── usecases/                  # 用例
│       ├── auth/
│       └── wallet/
│
├── data/                          # 数据层
│   ├── datasources/               # 数据源
│   │   ├── remote/                # 远程 API
│   │   └── local/                 # 本地存储
│   ├── models/                    # 数据模型
│   │   └── *.g.dart               # JSON 序列化
│   └── repositories/              # 仓库实现
│
├── presentation/                  # 表现层
│   ├── blocs/                     # 状态管理 (或 providers/)
│   ├── pages/                     # 页面
│   ├── widgets/                   # 组件
│   └── themes/                    # 主题
│
└── main.dart                      # 入口
```

### 2.2 依赖流向

```
┌─────────────────────────────────────────────────┐
│                  Presentation                    │
│         (Pages, Widgets, Providers/Blocs)       │
└────────────────────┬────────────────────────────┘
                     │ 依赖
                     ▼
┌─────────────────────────────────────────────────┐
│                    Domain                        │
│         (Entities, UseCases, Repository接口)    │
└────────────────────┬────────────────────────────┘
                     │ 实现
                     ▼
┌─────────────────────────────────────────────────┐
│                     Data                         │
│   (Repository实现, DataSources, Models)          │
└────────────────────┬────────────────────────────┘
                     │ 依赖
                     ▼
┌─────────────────────────────────────────────────┐
│                     Core                         │
│   (DI, Network, Security, Platform)             │
└─────────────────────────────────────────────────┘
```

---

## 3. 重构路线图

### Phase 1: 基础设施建设 (Week 1-2)

- [ ] 建立新目录结构（与现有代码并行）
- [ ] 引入依赖注入 (get_it + injectable)
- [ ] 重构网络层（安全 HTTP 客户端）
- [ ] 实现安全存储（flutter_secure_storage）
- [ ] 配置严格的 Linter 规则

### Phase 2: 核心模块迁移 (Week 3-4)

- [ ] 迁移用户认证模块
- [ ] 迁移钱包核心功能
- [ ] 实现统一路由系统
- [ ] 建立平台通道层

### Phase 3: 业务模块迁移 (Week 5-6)

- [ ] 迁移挖矿模块
- [ ] 迁移聊天模块
- [ ] 迁移浏览器模块
- [ ] 迁移交易模块

### Phase 4: 质量保障 (Week 7-8)

- [ ] 编写单元测试（目标覆盖率 70%）
- [ ] 编写 Widget 测试
- [ ] 配置 CI/CD 流程
- [ ] 性能基准测试

---

## 4. 详细实施方案

### 4.1 依赖注入配置

**新增依赖 (pubspec.yaml)**:

```yaml
dependencies:
  get_it: ^8.0.3
  injectable: ^2.5.0
  flutter_secure_storage: ^9.2.4
  go_router: ^14.6.2
  freezed_annotation: ^2.4.4
  dartz: ^0.10.1  # 函数式错误处理

dev_dependencies:
  injectable_generator: ^2.6.3
  freezed: ^2.5.7
  build_runner: ^2.4.13
  mockito: ^5.4.4
  mocktail: ^1.0.4
```

**注入容器实现**:

```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(String environment) async {
  await getIt.init(environment: environment);
}

abstract class Env {
  static const dev = 'dev';
  static const prod = 'prod';
  static const test = 'test';
}
```

### 4.2 安全网络层

```dart
// lib/core/network/api_client.dart
@singleton
class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;
  
  ApiClient(this._secureStorage) : _dio = Dio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
    
    _dio.interceptors.addAll([
      AuthInterceptor(_secureStorage),
      LoggingInterceptor(),
      RetryInterceptor(),
      ErrorInterceptor(),
    ]);
    
    // SSL Pinning (生产环境)
    if (kReleaseMode) {
      _dio.httpClientAdapter = IOHttpClientAdapter()
        ..createHttpClient = () {
          final client = HttpClient(context: SecurityContext());
          client.badCertificateCallback = (cert, host, port) {
            // 验证证书指纹
            return _verifyCertificate(cert, host);
          };
          return client;
        };
    }
  }
  
  bool _verifyCertificate(X509Certificate cert, String host) {
    final sha256 = sha256.convert(cert.der).toString();
    return allowedCertFingerprints.contains(sha256);
  }
}
```

### 4.3 安全存储

```dart
// lib/core/security/secure_storage.dart
@singleton
class SecureStorage {
  final FlutterSecureStorage _storage;
  
  SecureStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'n42_secure_prefs',
      preferencesKeyPrefix: 'n42_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      accountName: 'n42wallet',
    ),
  );
  
  Future<void> saveWalletCredentials(WalletCredentials creds) async {
    await _storage.write(
      key: 'wallet_${creds.address}',
      value: jsonEncode(creds.toJson()),
    );
  }
  
  Future<WalletCredentials?> getWalletCredentials(String address) async {
    final value = await _storage.read(key: 'wallet_$address');
    if (value == null) return null;
    return WalletCredentials.fromJson(jsonDecode(value));
  }
}
```

### 4.4 类型安全路由

```dart
// lib/core/router/app_router.dart
part 'app_router.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<WalletDetailRoute>(path: '/wallet/:address')
class WalletDetailRoute extends GoRouteData {
  final String address;
  WalletDetailRoute({required this.address});
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WalletDetailPage(address: address);
  }
}

final appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: _authRedirect,
  routes: $appRoutes,
  observers: [AppRouteObserver()],
);

String? _authRedirect(BuildContext context, GoRouterState state) {
  final authState = getIt<AuthBloc>().state;
  final isLoggedIn = authState is Authenticated;
  final isAuthRoute = state.matchedLocation == '/login';
  
  if (!isLoggedIn && !isAuthRoute) return '/login';
  if (isLoggedIn && isAuthRoute) return '/';
  return null;
}
```

### 4.5 Repository 模式

```dart
// lib/domain/repositories/wallet_repository.dart
abstract class WalletRepository {
  Future<Either<Failure, List<Wallet>>> getWallets();
  Future<Either<Failure, Wallet>> createWallet(CreateWalletParams params);
  Future<Either<Failure, TransactionResult>> sendTransaction(TransactionParams params);
}

// lib/data/repositories/wallet_repository_impl.dart
@LazySingleton(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remote;
  final WalletLocalDataSource _local;
  final NetworkInfo _networkInfo;
  
  WalletRepositoryImpl(this._remote, this._local, this._networkInfo);
  
  @override
  Future<Either<Failure, List<Wallet>>> getWallets() async {
    try {
      if (await _networkInfo.isConnected) {
        final wallets = await _remote.getWallets();
        await _local.cacheWallets(wallets);
        return Right(wallets.map((m) => m.toEntity()).toList());
      } else {
        final cached = await _local.getCachedWallets();
        return Right(cached.map((m) => m.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

### 4.6 Use Case 模式

```dart
// lib/domain/usecases/wallet/send_transaction.dart
@injectable
class SendTransaction implements UseCase<TransactionResult, TransactionParams> {
  final WalletRepository _repository;
  final BiometricService _biometric;
  
  SendTransaction(this._repository, this._biometric);
  
  @override
  Future<Either<Failure, TransactionResult>> call(TransactionParams params) async {
    // 1. 生物验证
    final authResult = await _biometric.authenticate(
      reason: 'Confirm transaction',
    );
    if (authResult.isLeft()) {
      return Left(BiometricFailure());
    }
    
    // 2. 执行交易
    return _repository.sendTransaction(params);
  }
}
```

---

## 5. 迁移策略

### 5.1 渐进式迁移原则

1. **并行开发**: 新旧代码共存，通过 Feature Flag 控制
2. **模块隔离**: 每个模块独立迁移，不影响其他模块
3. **API 兼容**: 保持对外接口不变，内部实现渐进替换

### 5.2 模块迁移顺序

```
┌──────────────────────────────────────────────────────┐
│  1. Core 层 (基础设施)                                │
│     - DI Container                                    │
│     - Network Client                                  │
│     - Secure Storage                                  │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  2. Domain 层 (业务核心)                              │
│     - Entities                                        │
│     - Repository Interfaces                           │
│     - UseCases                                        │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  3. Data 层 (数据实现)                                │
│     - 迁移现有 API 类到 DataSource                    │
│     - 实现 Repository                                 │
│     - 添加缓存层                                      │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  4. Presentation 层                                   │
│     - 逐页面迁移到新 Provider/Bloc                    │
│     - 统一使用 go_router                              │
└──────────────────────────────────────────────────────┘
```

### 5.3 Feature Flag 配置

```dart
// lib/core/config/feature_flags.dart
abstract class FeatureFlags {
  static bool get useNewNetworkLayer => 
      const bool.fromEnvironment('USE_NEW_NETWORK', defaultValue: false);
  
  static bool get useSecureStorage =>
      const bool.fromEnvironment('USE_SECURE_STORAGE', defaultValue: false);
  
  static bool get useGoRouter =>
      const bool.fromEnvironment('USE_GO_ROUTER', defaultValue: false);
}

// 使用方式
if (FeatureFlags.useNewNetworkLayer) {
  return getIt<NewApiClient>();
} else {
  return LegacyBaseHttp(...);
}
```

---

## 6. 验证与回滚机制

### 6.1 验证清单

#### 功能验证
- [ ] 所有现有功能正常工作
- [ ] 钱包创建/导入/恢复
- [ ] 交易发送/接收
- [ ] 挖矿功能
- [ ] 聊天功能
- [ ] Deep Link 处理

#### 性能验证
- [ ] 冷启动时间 < 3s
- [ ] 页面切换无卡顿 (60fps)
- [ ] 网络请求响应 < 2s
- [ ] 内存占用合理 (< 200MB)

#### 安全验证
- [ ] SSL 证书验证正常
- [ ] 敏感数据加密存储
- [ ] 代码混淆有效
- [ ] 无敏感信息日志泄露

### 6.2 回滚策略

```yaml
# .github/workflows/rollback.yml
name: Rollback Deployment

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to rollback to'
        required: true

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout specific version
        uses: actions/checkout@v4
        with:
          ref: ${{ github.event.inputs.version }}
      
      - name: Build and deploy
        run: |
          flutter build apk --release
          flutter build ios --release
```

### 6.3 监控与告警

```dart
// lib/core/monitoring/app_monitor.dart
@singleton
class AppMonitor {
  void trackPerformance(String name, Duration duration) {
    FirebaseAnalytics.instance.logEvent(
      name: 'performance_metric',
      parameters: {
        'metric_name': name,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
  
  void trackError(Object error, StackTrace stack, {bool fatal = false}) {
    FirebaseCrashlytics.instance.recordError(
      error, 
      stack, 
      fatal: fatal,
      reason: 'Unhandled exception',
    );
  }
}
```

---

## 附录 A: 新增依赖完整列表

```yaml
dependencies:
  # 依赖注入
  get_it: ^8.0.3
  injectable: ^2.5.0
  
  # 安全存储
  flutter_secure_storage: ^9.2.4
  
  # 路由
  go_router: ^14.6.2
  
  # 函数式编程
  dartz: ^0.10.1
  freezed_annotation: ^2.4.4
  
  # 状态管理增强 (可选)
  flutter_bloc: ^8.1.6
  
  # 网络增强
  pretty_dio_logger: ^1.4.0
  dio_smart_retry: ^6.0.0
  
  # 性能监控
  firebase_performance: ^0.10.0+9

dev_dependencies:
  injectable_generator: ^2.6.3
  freezed: ^2.5.7
  build_runner: ^2.4.13
  mockito: ^5.4.4
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.2
  very_good_analysis: ^6.0.0
```

---

## 附录 B: 严格 Linter 配置

```yaml
# analysis_options.yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/generated/**"
  errors:
    invalid_annotation_target: ignore
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    flutter_style_todos: true
    avoid_dynamic_calls: true
    avoid_type_to_string: true
    cancel_subscriptions: true
    close_sinks: true
    literal_only_boolean_expressions: true
    no_adjacent_strings_in_list: true
    throw_in_finally: true
    unnecessary_statements: true
    use_build_context_synchronously: true
```

---

## 附录 C: CI/CD 配置

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze --fatal-infos
      
      - name: Format check
        run: dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info

  build-android:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: [analyze, test]
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
```

---

*本文档将随重构进度持续更新*

