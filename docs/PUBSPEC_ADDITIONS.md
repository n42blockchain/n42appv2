# pubspec.yaml 新增依赖

将以下依赖添加到您的 `pubspec.yaml` 文件中：

## Dependencies 部分

```yaml
dependencies:
  # ==================== 新增依赖 ====================
  
  # 依赖注入
  get_it: ^8.0.3
  injectable: ^2.5.0
  
  # 安全存储 (替代 SharedPreferences 存储敏感信息)
  flutter_secure_storage: ^9.2.4
  
  # 类型安全路由
  go_router: ^14.6.2
  
  # 函数式编程 (Either 类型用于错误处理)
  dartz: ^0.10.1
  
  # 不可变数据类和 Union types
  freezed_annotation: ^2.4.4
  
  # 值相等比较
  equatable: ^2.0.7
  
  # 状态管理增强 (可选，如果想迁移到 Bloc)
  # flutter_bloc: ^8.1.6
  
  # 性能监控 (可选)
  # firebase_performance: ^0.10.0+9
```

## Dev Dependencies 部分

```yaml
dev_dependencies:
  # ==================== 新增开发依赖 ====================
  
  # 代码生成
  injectable_generator: ^2.6.3
  freezed: ^2.5.7
  go_router_builder: ^2.7.1
  
  # 构建运行器
  build_runner: ^2.4.13
  
  # 测试 Mock
  mockito: ^5.4.4
  mocktail: ^1.0.4
  
  # 更严格的 Lint 规则
  very_good_analysis: ^6.0.0
  
  # 集成测试
  integration_test:
    sdk: flutter
```

## 完整的 dependencies 部分参考

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  cupertino_icons: ^1.0.8
  intl: 0.20.2
  provider: ^6.1.4
  sqflite: ^2.4.1
  path: ^1.9.0
  path_provider: ^2.1.5
  shared_preferences: ^2.5.3
  flutter_screenutil: ^5.9.3
  easy_refresh: ^3.4.0
  dio: ^5.7.0
  bitcoin_base: ^5.3.0
  connectivity_plus: 6.1.1
  cached_network_image: ^3.4.1
  validators: ^3.0.0
  webview_flutter: ^4.13.0
  event_bus: ^2.0.1
  fluttertoast: ^8.2.12
  reown_walletkit: ^1.0.3
  decimal: ^2.3.3
  flustars_flutter3: ^3.0.0
  eth_sig_util: ^0.0.9
  web3dart: ^2.7.3
  fast_base58: ^0.2.1
  bech32: ^0.2.2
  crypto: ^3.0.6
  protobuf: ^3.1.0
  protoc_plugin: ^21.1.2
  qr_code_scanner_plus: ^2.0.6
  permission_handler: ^11.3.1
  flutter_slidable: ^3.1.2
  qr_flutter: ^4.1.0
  share_plus: ^10.1.3
  date_format: ^2.0.9
  simple_html_css: ^5.0.0
  roundcheckbox: ^2.0.5
  image_picker: ^1.1.2
  file_picker: ^8.1.6
  pro_image_editor: ^7.1.0
  local_auth: ^2.3.0
  rate_us_on_store: ^0.0.4
  device_info_plus: ^11.2.0
  package_info_plus: ^8.1.2
  video_compress: ^3.1.4
  video_player: ^2.9.2
  chewie: ^1.8.5
  flutter_face_api: ^7.2.407
  flutter_face_core_basic: ^7.2.235
  custom_pop_up_menu: ^1.2.4
  flutter_local_notifications: ^19.4.2
  fl_chart: ^0.70.0
  encrypt: ^5.0.3
  aes_crypt_null_safe: ^3.0.0
  file_icon: ^1.0.0
  extended_image: ^9.0.9
  open_filex: ^4.6.0
  gesture_password_widget: ^2.0.1
  app_links: ^6.1.1
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  firebase_crashlytics: ^4.2.0
  firebase_analytics: ^11.3.6
  flutter_new_badger: ^1.1.0
  archive: ^4.0.2
  
  # ==================== 新增依赖 ====================
  get_it: ^8.0.3
  injectable: ^2.5.0
  flutter_secure_storage: ^9.2.4
  go_router: ^14.6.2
  dartz: ^0.10.1
  freezed_annotation: ^2.4.4
  equatable: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.1.7
  json_serializable: ^6.1.5
  
  # ==================== 新增开发依赖 ====================
  injectable_generator: ^2.6.3
  freezed: ^2.5.7
  go_router_builder: ^2.7.1
  mockito: ^5.4.4
  mocktail: ^1.0.4
  very_good_analysis: ^6.0.0
  integration_test:
    sdk: flutter
```

## 安装步骤

```bash
# 1. 更新依赖
flutter pub get

# 2. 生成代码
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 验证安装
flutter analyze
```

## 注意事项

1. **flutter_secure_storage** 需要 Android minSdk >= 18，iOS >= 12.0
2. **go_router** 需要 Flutter 3.16 或更高版本
3. **very_good_analysis** 会引入更严格的 lint 规则，可能需要修复一些现有代码
4. 首次运行 `build_runner` 前需要创建 `injection.config.dart` 配置文件

