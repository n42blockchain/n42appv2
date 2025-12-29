# 性能优化指南

**日期**: 2025-12-29  
**作者**: AI Assistant

---

## 1. 性能问题分析

### 1.1 Widget Rebuild 过度

**发现的问题**:
- 1043 处 `setState()` / `notifyListeners()` 调用
- 部分页面整体重建而非局部更新

**潜在影响**:
- UI 卡顿
- CPU 使用率过高
- 电池消耗增加

**优化建议**:

```dart
// ❌ 不好: 整个页面重建
setState(() {
  _counter++;
  _name = 'new name';
  _list.add(item);
});

// ✅ 好: 使用 ValueNotifier 局部重建
final _counter = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, value, child) => Text('$value'),
)

// ✅ 好: 使用 Riverpod select 精准重建
final count = ref.watch(counterProvider.select((state) => state.count));
```

### 1.2 大列表性能

**发现的问题**:
- 65 处 ListView/GridView 使用
- 部分使用 `ListView()` 而非 `ListView.builder()`

**优化建议**:

```dart
// ❌ 不好: 一次性构建所有子项
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ 好: 按需构建
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
  cacheExtent: 500.0,  // 增加缓存区域
)

// ✅ 好: 使用优化组件
OptimizedListView(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
  addRepaintBoundaries: true,
)
```

### 1.3 图片性能

**发现的问题**:
- 14 处 Image.network 使用
- 未使用图片缓存
- 未限制内存缓存尺寸

**优化建议**:

```dart
// ❌ 不好: 原始尺寸加载
Image.network(url)

// ✅ 好: 限制缓存尺寸
Image.network(
  url,
  cacheWidth: 200,
  cacheHeight: 200,
  filterQuality: FilterQuality.low,
)

// ✅ 好: 使用优化组件
OptimizedNetworkImage(
  imageUrl: url,
  width: 100,
  height: 100,
  memCacheWidth: 200,
)
```

### 1.4 Isolate 使用

**发现的问题**:
- 5 处 Isolate/compute 使用
- 部分重计算未使用 Isolate

**优化建议**:

```dart
// 对于耗时 > 16ms 的操作，使用 compute
final result = await compute(_heavyComputation, data);

// 对于频繁调用的轻量操作，使用 FrameScheduler
FrameScheduler.scheduleTask(() {
  // 分帧执行
});
```

### 1.5 启动耗时

**当前启动流程**:
```
main() 
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── Firebase.initializeApp()          // ~500ms
  ├── notification.init()               // ~100ms
  ├── configureDependencies()           // ~200ms
  └── runApp()
      └── PublicProvider.checkData()    // ~300ms
```

**优化策略**:

1. **延迟初始化**: 非关键服务推迟到首帧后
2. **并行初始化**: Firebase 和 DI 并行执行
3. **预加载**: 关键资源预加载

---

## 2. 优化工具

### 2.1 性能监控

```dart
// 启用性能监控
PerformanceConfig.isEnabled = true;

// 测量异步操作
final result = await PerformanceConfig.measureAsync(
  'wallet_load',
  () => loadWallet(),
);

// 测量同步操作
final data = PerformanceConfig.measureSync(
  'json_parse',
  () => jsonDecode(jsonString),
);

// 获取性能报告
final report = PerformanceConfig.getPerformanceReport();
```

### 2.2 启动优化

```dart
void main() async {
  // 记录启动时间
  StartupOptimizer.recordAppStart();
  
  // 仅初始化关键服务
  WidgetsFlutterBinding.ensureInitialized();
  
  // 延迟非关键初始化
  DeferredInitializer.addTask(() async {
    await notification.init();
  });
  
  runApp(MyApp());
  
  // 首帧后执行延迟任务
  DeferredInitializer.executeAfterFirstFrame();
}
```

### 2.3 优化组件

| 组件 | 功能 |
|------|------|
| `OptimizedListView` | 自动添加 RepaintBoundary，增加缓存 |
| `OptimizedGridView` | 优化网格渲染 |
| `OptimizedNetworkImage` | 图片缓存优化 |
| `LazyLoadWidget` | 延迟加载组件 |
| `DebouncedButton` | 防抖按钮 |
| `SelectiveBuilder` | 选择性重建 |

---

## 3. 性能 Benchmark

### 3.1 启动性能基准

| 指标 | 目标值 | 说明 |
|------|--------|------|
| Cold Start | < 3000ms | 冷启动到首帧 |
| Warm Start | < 1000ms | 热启动到首帧 |
| First Frame | < 500ms | 首帧渲染时间 |
| DI Init | < 200ms | 依赖注入初始化 |
| Firebase Init | < 500ms | Firebase 初始化 |

### 3.2 页面切换基准

| 指标 | 目标值 | 说明 |
|------|--------|------|
| Page Navigation | < 300ms | 页面跳转 |
| Tab Switch | < 50ms | Tab 切换 |
| Back Navigation | < 100ms | 返回操作 |

### 3.3 核心业务基准

| 指标 | 目标值 | 说明 |
|------|--------|------|
| Wallet Balance | < 2000ms | 余额获取 |
| Transaction List | < 3000ms | 交易列表加载 |
| Message Send | < 500ms | 消息发送 |
| Mining Status | < 2000ms | 挖矿状态检查 |

---

## 4. CI 集成

### 4.1 运行 Benchmark

```bash
# 运行所有 Benchmark
flutter test test/benchmark/

# 运行特定 Benchmark
flutter test test/benchmark/startup_benchmark_test.dart

# 生成报告
flutter test test/benchmark/ --reporter expanded
```

### 4.2 GitHub Actions

`.github/workflows/benchmark.yml` 配置:
- 每次 PR 自动运行
- 每日定时运行
- 生成性能报告
- 与基线比较

### 4.3 查看结果

结果输出到:
- `benchmark_results/startup_results.json`
- `benchmark_results/navigation_results.json`
- `benchmark_results/core_business_results.json`

---

## 5. 最佳实践

### 5.1 Widget 优化

1. **使用 const 构造函数**
```dart
const MyWidget({super.key});  // ✅
```

2. **提取静态子树**
```dart
// 将不变的部分提取为 const
Widget build(BuildContext context) {
  return Column(
    children: [
      const Header(),  // 不会重建
      DynamicContent(data: data),  // 会重建
    ],
  );
}
```

3. **使用 RepaintBoundary**
```dart
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)
```

### 5.2 列表优化

1. 使用 `ListView.builder` / `GridView.builder`
2. 设置合理的 `cacheExtent`
3. 固定 `itemExtent` 提升滚动性能
4. 对复杂项使用 `RepaintBoundary`

### 5.3 图片优化

1. 指定 `cacheWidth` / `cacheHeight`
2. 使用低质量过滤 `FilterQuality.low`
3. 使用图片缓存库 (CachedNetworkImage)
4. 实现占位符和错误处理

### 5.4 状态管理优化

1. 使用 Riverpod `select` 精准订阅
2. 避免在 `build` 中创建对象
3. 使用 `const` 静态值
4. 防抖频繁更新

---

## 6. 性能文件清单

| 文件路径 | 功能 |
|---------|------|
| `lib/core/performance/performance_config.dart` | 性能监控配置 |
| `lib/core/performance/startup_optimizer.dart` | 启动优化 |
| `lib/core/performance/optimized_widgets.dart` | 优化组件 |
| `test/benchmark/startup_benchmark_test.dart` | 启动 Benchmark |
| `test/benchmark/navigation_benchmark_test.dart` | 导航 Benchmark |
| `test/benchmark/core_business_benchmark_test.dart` | 业务 Benchmark |
| `.github/workflows/benchmark.yml` | CI 配置 |

