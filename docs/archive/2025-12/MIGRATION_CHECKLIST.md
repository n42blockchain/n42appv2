# 迁移检查清单 / Migration Checklist

## ✅ 已完成 / Completed

### 1. 文件头注释 / File Header Comments
- [x] 创建标准文件头模板
- [x] 应用到新创建的所有文件
- [x] 格式：Copyright 2021-2026 N42 Inc, Author: Jiang Yiwei, Apache 2.0 & MIT

### 2. 目录结构迁移 / Directory Structure Migration
- [x] 创建 `lib/core/` 层
  - [x] `core/app/app_globals.dart` (原 `application.dart`)
  - [x] `core/config/app_config.dart` (原 `app_config.dart`)
  - [x] `core/network/base_http.dart` (原 `src/https/base_http.dart`)
  - [x] `core/storage/sp_util.dart` (原 `src/utils/sp_util.dart`)
  - [x] `core/storage/app_database.dart` (原 `src/sqlite/app_database.dart`)
  - [x] `core/utils/event_bus.dart` (原 `src/utils/event_bus.dart`)
  - [x] `core/utils/toast_utils.dart` (原 `src/utils/toast_utils.dart`)
  - [x] `core/di/injection.dart` (新)

- [x] 创建 `lib/presentation/` 层
  - [x] `presentation/themes/theme_adapter.dart` (原 `src/utils/theme_adapter.dart`)

- [x] 创建 `lib/data/` 层
  - [x] `data/models/user_info.dart` (原 `src/models/user_info.dart`)

- [x] 创建 `lib/shared/` 层 (新)
  - [x] `shared/domain/entities/wallet_info.dart`
  - [x] `shared/domain/entities/balance_info.dart`
  - [x] `shared/domain/services/wallet_service_interface.dart`
  - [x] `shared/domain/services/mining_service_interface.dart`
  - [x] `shared/contracts/feature_contracts.dart`
  - [x] `shared/events/cross_feature_events.dart`
  - [x] `shared/events/event_manager.dart`
  - [x] `shared/di/service_locator.dart`

- [x] 创建 Feature 服务实现
  - [x] `features/wallet/data/services/wallet_service_impl.dart`
  - [x] `features/mining/data/services/mining_service_impl.dart`

### 3. 依赖更新 / Dependency Updates
- [x] 添加 `get_it: ^7.6.7` (依赖注入)
- [x] 添加 `injectable: ^2.3.2` (DI 代码生成)
- [x] 添加 `go_router: ^14.2.0` (声明式路由)
- [x] 添加 `flutter_secure_storage: ^9.2.2` (安全存储)
- [x] 添加 `dartz: ^0.10.1` (Either 模式)
- [x] 添加 `freezed_annotation: ^2.4.1` (不可变数据类)
- [x] 添加 `internet_connection_checker: ^1.0.0+1` (网络状态)
- [x] 添加 dev_dependencies:
  - [x] `injectable_generator: ^2.4.1`
  - [x] `freezed: ^2.4.7`
  - [x] `mockito: ^5.4.4`
  - [x] `mocktail: ^1.0.3`
  - [x] `golden_toolkit: ^0.15.0`

### 4. Feature 边界违规修复 / Feature Boundary Violation Fixes
- [x] 创建共享层 (`lib/shared/`)
- [x] 定义共享实体 (`SharedWalletInfo`, `SharedBalanceInfo`)
- [x] 定义服务接口 (`IWalletService`, `IMiningService`)
- [x] 创建跨功能事件 (`CrossFeatureEvent` 体系)
- [x] 创建事件管理器 (`EventManager`)
- [x] 实现服务定位器 (`ServiceLocator`)
- [x] 实现 Feature 初始化器 (`FeatureInitializer`)

### 5. Wallet ↔ Mining 双向依赖解耦
- [x] 定义 `IWalletService` 接口
- [x] 定义 `IMiningService` 接口
- [x] 创建 `WalletServiceImpl` 实现
- [x] 创建 `MiningServiceImpl` 实现
- [x] 通过事件总线通信替代直接依赖

---

## 📋 后续步骤 / Next Steps

### 高优先级 / High Priority
1. 运行 `flutter pub get` 安装新依赖
2. 运行 `flutter pub run build_runner build` 生成代码
3. 更新现有 import 路径指向新位置
4. 在 `main.dart` 中初始化依赖注入

### 中优先级 / Medium Priority
1. 迁移剩余的 Provider 到新架构
2. 实现完整的 `WalletServiceImpl` 连接到现有 Provider
3. 实现完整的 `MiningServiceImpl` 连接到现有 Provider
4. 添加单元测试

### 低优先级 / Low Priority
1. 迁移路由到 go_router
2. 添加集成测试
3. 完善 CI/CD 流程

---

## 📁 新目录结构 / New Directory Structure

```
lib/
├── main.dart
├── core/                          # 核心基础设施
│   ├── core.dart                  # Barrel file
│   ├── app/
│   │   └── app_globals.dart       # 全局状态 (deprecated)
│   ├── config/
│   │   └── app_config.dart        # 应用配置
│   ├── di/
│   │   └── injection.dart         # 依赖注入
│   ├── network/
│   │   └── base_http.dart         # HTTP 客户端
│   ├── storage/
│   │   ├── sp_util.dart           # SharedPreferences
│   │   └── app_database.dart      # SQLite
│   └── utils/
│       ├── event_bus.dart         # 事件总线
│       └── toast_utils.dart       # Toast 工具
├── shared/                        # 跨功能共享层
│   ├── shared.dart                # Barrel file
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── wallet_info.dart
│   │   │   └── balance_info.dart
│   │   └── services/
│   │       ├── wallet_service_interface.dart
│   │       └── mining_service_interface.dart
│   ├── contracts/
│   │   └── feature_contracts.dart
│   ├── events/
│   │   ├── cross_feature_events.dart
│   │   └── event_manager.dart
│   └── di/
│       └── service_locator.dart
├── data/                          # 数据层
│   └── models/
│       └── user_info.dart
├── presentation/                  # 表现层
│   └── themes/
│       └── theme_adapter.dart
└── features/                      # 功能模块
    ├── feature_initializer.dart
    ├── wallet/
    │   └── data/services/
    │       └── wallet_service_impl.dart
    └── mining/
        └── data/services/
            └── mining_service_impl.dart
```

---

## 🔄 Import 路径更新指南 / Import Path Update Guide

| 旧路径 | 新路径 |
|-------|-------|
| `package:n42appv2/application.dart` | `package:n42appv2/core/app/app_globals.dart` |
| `package:n42appv2/app_config.dart` | `package:n42appv2/core/config/app_config.dart` |
| `package:n42appv2/src/utils/sp_util.dart` | `package:n42appv2/core/storage/sp_util.dart` |
| `package:n42appv2/src/utils/theme_adapter.dart` | `package:n42appv2/presentation/themes/theme_adapter.dart` |
| `package:n42appv2/src/utils/event_bus.dart` | `package:n42appv2/core/utils/event_bus.dart` |
| `package:n42appv2/src/utils/toast_utils.dart` | `package:n42appv2/core/utils/toast_utils.dart` |
| `package:n42appv2/src/https/base_http.dart` | `package:n42appv2/core/network/base_http.dart` |
| `package:n42appv2/src/sqlite/app_database.dart` | `package:n42appv2/core/storage/app_database.dart` |
| `package:n42appv2/src/models/user_info.dart` | `package:n42appv2/data/models/user_info.dart` |

---

## ⚠️ 注意事项 / Important Notes

1. **保持旧文件**: 旧文件暂时保留，使用别名导出保持兼容
2. **渐进式迁移**: 逐步更新 import，不要一次性修改所有文件
3. **测试验证**: 每次迁移后运行测试确保功能正常
4. **回滚方案**: 如遇问题，可恢复旧的 import 路径

