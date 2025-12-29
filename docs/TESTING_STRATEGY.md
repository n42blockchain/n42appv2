# 测试策略文档

**日期**: 2025-12-29  
**作者**: AI Assistant

---

## 1. 测试金字塔

```
                    ┌────────────────┐
                    │  E2E / Manual  │  <- 最少
                    │     Tests      │
                    └───────┬────────┘
                  ┌─────────┴─────────┐
                  │  Integration Tests │  <- 中等
                  │   Widget Tests     │
                  └─────────┬─────────┘
        ┌───────────────────┴───────────────────┐
        │           Unit Tests                   │  <- 最多
        │  Domain / UseCase / State / Utils      │
        └────────────────────────────────────────┘
```

---

## 2. 单元测试策略

### 2.1 Domain 层 (100% 覆盖)

| 组件 | 测试内容 | 覆盖目标 |
|------|---------|---------|
| Entities | 属性、工厂方法、相等性 | 100% |
| UseCases | 业务逻辑、验证、边界条件 | 100% |
| Repositories (Interface) | 接口契约 | N/A (Mock) |

**测试重点**:
- 所有验证逻辑
- 所有业务规则
- 边界条件
- 错误处理

### 2.2 State 层 (高覆盖)

| 组件 | 测试内容 | 覆盖目标 |
|------|---------|---------|
| Riverpod Providers | 状态变化、副作用 | > 90% |
| StateNotifiers | 状态转换、方法调用 | > 90% |
| AsyncNotifiers | 加载/成功/错误状态 | > 90% |

**测试重点**:
- 初始状态
- 状态转换
- 异步操作
- 错误处理

### 2.3 UI 层 (最小必要覆盖)

| 组件 | 测试内容 | 覆盖目标 |
|------|---------|---------|
| 关键 Widgets | 渲染、交互 | > 50% |
| 表单验证 | 输入验证 | > 80% |
| 导航 | 路由跳转 | > 60% |

---

## 3. Widget Test 策略

### 3.1 测试范围

```dart
// 测试类型
- 单组件渲染测试
- 交互测试 (tap, swipe, input)
- 状态变化测试
- 主题切换测试 (Light/Dark)
- 国际化测试
```

### 3.2 平台一致性

```dart
// 测试不同平台行为
testWidgets('should behave consistently on iOS', (tester) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  // ...
});

testWidgets('should behave consistently on Android', (tester) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  // ...
});
```

### 3.3 主题覆盖

```dart
// Light Theme 测试
testWidgets('should render correctly in light theme', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      home: MyWidget(),
    ),
  );
});

// Dark Theme 测试
testWidgets('should render correctly in dark theme', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark(),
      home: MyWidget(),
    ),
  );
});
```

---

## 4. Integration Test 策略

### 4.1 核心流程

| 流程 | 描述 | 优先级 |
|------|------|--------|
| 钱包创建 | 创建新钱包完整流程 | P0 |
| 发送交易 | 从选择到确认完整流程 | P0 |
| 登录认证 | 用户登录完整流程 | P0 |
| 聊天发送 | 发送消息完整流程 | P1 |
| 挖矿操作 | 挖矿相关操作 | P1 |

### 4.2 测试配置

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Core Flows', () {
    testWidgets('complete wallet creation flow', (tester) async {
      // ...
    });
  });
}
```

---

## 5. 测试工具

### 5.1 Mock 工具

```yaml
# pubspec.yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
  mocktail: ^1.0.0
```

### 5.2 测试辅助

```dart
// test/helpers/test_helpers.dart
- createMockProviderContainer()
- createTestApp()
- pumpAndSettle()
```

---

## 6. CI 集成

### 6.1 测试命令

```bash
# 单元测试
flutter test test/

# Widget 测试
flutter test test/ --tags widget

# Integration 测试
flutter test integration_test/

# 覆盖率报告
flutter test --coverage
```

### 6.2 覆盖率阈值

| 层 | 最低覆盖率 |
|----|----------|
| Domain | 100% |
| State | 90% |
| UI | 50% |
| 整体 | 70% |

---

## 7. 测试文件结构

```
test/
├── helpers/
│   ├── test_helpers.dart
│   ├── mock_providers.dart
│   └── fake_repositories.dart
├── features/
│   ├── wallet/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── create_wallet_test.dart
│   │   │   │   ├── get_balance_test.dart
│   │   │   │   └── send_transaction_test.dart
│   │   │   └── entities/
│   │   │       └── wallet_entity_test.dart
│   │   ├── providers/
│   │   │   └── wallet_providers_test.dart
│   │   └── widgets/
│   │       └── wallet_card_test.dart
│   ├── chat/
│   │   └── ...
│   └── mining/
│       └── ...
├── core/
│   ├── providers/
│   │   └── core_providers_test.dart
│   └── ...
└── widget/
    ├── theme_test.dart
    └── platform_test.dart

integration_test/
├── flows/
│   ├── wallet_flow_test.dart
│   ├── transaction_flow_test.dart
│   └── auth_flow_test.dart
└── app_test.dart
```

