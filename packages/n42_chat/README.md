# N42 Matrix Chat

基于 [Matrix](https://matrix.org/) 协议的微信风格即时通讯模块，专为 N42 钱包设计。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.19.0-blue.svg)](https://flutter.dev)

## ✨ 功能特性

- 🎨 **微信风格UI** - 熟悉的交互体验，中国用户友好
- 🔐 **端对端加密** - 基于 Matrix Olm/Megolm 协议
- 🔌 **插件化设计** - 可独立运行或嵌入主应用
- 💰 **钱包集成** - 支持聊天内加密货币转账
- 🌐 **去中心化** - 支持任意 Matrix 服务器
- 📱 **跨平台** - iOS、Android、Web、Desktop

---

## 📋 功能明细

### 🔐 认证与账号

| 功能 | 说明 | 状态 |
|------|------|------|
| 用户名密码登录 | 标准 Matrix 登录方式 | ✅ |
| 账号注册 | 支持邀请码注册 | ✅ |
| 邮箱绑定 | 注册时绑定邮箱，用于找回密码 | ✅ |
| 生物识别登录 | 支持指纹/Face ID 快速登录 | ✅ |
| Passkey 管理 | 可在安全设置中注册/删除，独立登录入口未开放 | ⏳ |
| 邮箱验证码登录 | 独立登录入口未开放 | ⏳ |
| 第三方登录 | Google（Android）、Apple（iOS/macOS）、SSO | ✅ |
| 密码重置 | 通过绑定邮箱重置密码 | ✅ |
| 密码修改 | 登录后修改密码 | ✅ |
| 会话恢复 | 自动恢复上次登录会话 | ✅ |
| 多账号管理 | 支持多个账号切换 | ✅ |

> 当前 Passkey 仅开放账号内管理；邮箱验证码接口保留，但登录首页未暴露独立入口。
> `Facebook / Twitter / WeChat` 代码链路保留为实验能力，默认登录页不暴露，待宿主完成平台配置后再开启。

### 💬 消息功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 文本消息 | 支持富文本、链接识别 | ✅ |
| 图片消息 | 支持发送/接收图片，缩略图预览 | ✅ |
| 语音消息 | 支持录制和播放语音 | ✅ |
| 视频消息 | 支持发送/接收视频 | ✅ |
| 文件消息 | 支持任意文件发送 | ✅ |
| 表情贴纸 | 内置表情包支持 | ✅ |
| 消息撤回 | 2分钟内可撤回消息 | ✅ |
| 消息回复 | 引用回复特定消息 | ✅ |
| 消息转发 | 转发消息到其他会话 | ✅ |
| 消息搜索 | 全局/会话内消息搜索 | ✅ |
| 已读回执 | 显示消息已读状态 | ✅ |
| 消息编辑 | 编辑已发送的消息 | ✅ |
| @提及 | 群聊中@特定成员 | ✅ |
| 红包消息 | 加密货币红包功能 | ✅ |
| 转账消息 | 聊天内加密货币转账 | ✅ |

### 📝 会话管理

| 功能 | 说明 | 状态 |
|------|------|------|
| 单聊会话 | 一对一私聊 | ✅ |
| 群聊会话 | 多人群组聊天 | ✅ |
| 会话列表 | 按最新消息时间排序 | ✅ |
| 会话置顶 | 重要会话置顶显示 | ✅ |
| 会话免打扰 | 静音特定会话通知 | ✅ |
| 强提醒 | 收到消息时全屏提醒 | ✅ |
| 会话删除 | 删除会话（保留服务端记录） | ✅ |
| 清空聊天记录 | 清空本地聊天记录 | ✅ |
| 未读消息计数 | 显示未读消息数量徽章 | ✅ |
| 草稿保存 | 自动保存未发送的消息 | ✅ |

### 👥 联系人管理

| 功能 | 说明 | 状态 |
|------|------|------|
| 联系人列表 | 按字母索引排序 | ✅ |
| 添加好友 | 通过用户ID/二维码添加 | ✅ |
| 好友备注 | 设置好友备注名称 | ✅ |
| 好友标签 | 给好友添加标签分组 | ✅ |
| 删除好友 | 移除好友关系 | ✅ |
| 黑名单 | 拉黑用户 | ✅ |
| 联系人搜索 | 搜索联系人 | ✅ |
| 好友验证 | 添加好友需验证 | ✅ |

### 👨‍👩‍👧‍👦 群组功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 创建群组 | 创建新群聊 | ✅ |
| 邀请成员 | 邀请好友加入群组 | ✅ |
| 移除成员 | 群主/管理员移除成员 | ✅ |
| 退出群组 | 主动退出群聊 | ✅ |
| 解散群组 | 群主解散群组 | ✅ |
| 群名称修改 | 修改群组名称 | ✅ |
| 群头像修改 | 修改群组头像 | ✅ |
| 群公告 | 发布群公告 | ✅ |
| 群管理员 | 设置群管理员 | ✅ |
| 群成员列表 | 查看群成员 | ✅ |
| 群二维码 | 群组邀请二维码 | ✅ |
| 全员禁言 | 群主开启全员禁言 | ✅ |

### 👤 个人资料

| 功能 | 说明 | 状态 |
|------|------|------|
| 头像修改 | 上传/更换头像 | ✅ |
| 昵称修改 | 设置显示名称 | ✅ |
| 个性签名 | 设置个人签名 | ✅ |
| 性别设置 | 设置性别信息 | ✅ |
| 地区设置 | 设置所在地区 | ✅ |
| 拍一拍文字 | 自定义拍一拍后缀 | ✅ |
| 来电铃声 | 自定义来电铃声 | ✅ |
| 个人二维码 | 生成个人名片二维码 | ✅ |
| 绑定邮箱 | 绑定/修改邮箱地址 | ✅ |

### 🔒 安全与隐私

| 功能 | 说明 | 状态 |
|------|------|------|
| 端对端加密 (E2EE) | 基于 Olm/Megolm 协议加密 | ✅ |
| 设备验证 | 验证新设备登录 | ✅ |
| 密钥备份 | 加密密钥云端备份 | ✅ |
| 生物识别锁定 | 应用锁定保护 | ✅ |
| 密码管理 | 修改/重置密码 | ✅ |
| 登录设备管理 | 查看/移除登录设备 | ✅ |
| 消息加密状态 | 显示消息加密状态 | ✅ |
| 安全存储 | 敏感数据加密存储 | ✅ |

### 🔔 通知功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 推送通知 | FCM/APNs 推送支持 | ✅ |
| 通知设置 | 全局通知开关 | ✅ |
| 会话通知 | 单独设置会话通知 | ✅ |
| 强提醒 | 特定联系人强提醒 | ✅ |
| 免打扰时段 | 设置免打扰时间段 | ✅ |
| 通知预览 | 通知显示消息预览 | ✅ |

### 🎨 外观设置

| 功能 | 说明 | 状态 |
|------|------|------|
| 深色模式 | 支持深色/浅色主题 | ✅ |
| 跟随系统 | 自动跟随系统主题 | ✅ |
| 字体大小 | 调整聊天字体大小 | ✅ |
| 聊天背景 | 自定义聊天背景图 | ✅ |
| 气泡样式 | 微信/iOS/Material 风格 | ✅ |
| 主题色 | 自定义主题颜色 | ✅ |

### 💰 钱包集成

| 功能 | 说明 | 状态 |
|------|------|------|
| 聊天转账 | 在聊天中发起转账 | ✅ |
| 红包功能 | 发送/接收加密货币红包 | ✅ |
| 收款码 | 生成收款二维码 | ✅ |
| 转账记录 | 查看聊天内转账历史 | ✅ |
| 多币种支持 | 支持多种加密货币 | ✅ |

### 🔧 其他功能

| 功能 | 说明 | 状态 |
|------|------|------|
| 消息同步 | 多设备消息同步 | ✅ |
| 离线消息 | 离线时接收消息 | ✅ |
| 网络状态 | 显示连接状态 | ✅ |
| 国际化 | 中文/英文支持 | ✅ |
| 二维码扫描 | 扫描添加好友/群组 | ✅ |
| 分享功能 | 分享聊天内容 | ✅ |
| 数据导出 | 导出聊天记录 | ✅ |
| 缓存管理 | 清理本地缓存 | ✅ |

---

## 🏗️ 架构设计

```
n42_chat/
├── lib/
│   ├── n42_chat.dart              # 主入口
│   └── src/
│       ├── core/                  # 核心层
│       │   ├── di/                # 依赖注入
│       │   ├── router/            # 路由
│       │   ├── theme/             # 主题
│       │   ├── utils/             # 工具
│       │   ├── constants/         # 常量
│       │   ├── services/          # 核心服务
│       │   └── extensions/        # 扩展
│       ├── data/                  # 数据层
│       │   ├── datasources/       # 数据源
│       │   │   ├── local/         # 本地存储
│       │   │   └── matrix/        # Matrix SDK
│       │   ├── models/            # 数据模型
│       │   └── repositories/      # 仓库实现
│       ├── domain/                # 领域层
│       │   ├── entities/          # 实体
│       │   ├── repositories/      # 仓库接口
│       │   └── usecases/          # 用例
│       ├── presentation/          # 表现层
│       │   ├── pages/             # 页面
│       │   │   ├── auth/          # 认证页面
│       │   │   ├── chat/          # 聊天页面
│       │   │   ├── contact/       # 联系人页面
│       │   │   ├── settings/      # 设置页面
│       │   │   └── profile/       # 个人资料页面
│       │   ├── widgets/           # 组件
│       │   └── blocs/             # BLoC 状态管理
│       ├── services/              # 业务服务
│       │   ├── auth/              # 认证服务
│       │   └── notification/      # 通知服务
│       └── integration/           # 集成接口
├── l10n/                          # 国际化资源
├── example/                       # 示例应用
└── test/                          # 测试
```

---

## 🚀 快速开始

### 安装

```yaml
dependencies:
  n42_chat:
    path: ../n42_chat  # 本地路径
    # 或者
    # git:
    #   url: https://github.com/n42/n42_chat.git
```

### 平台配置

#### Android

在 `android/app/src/main/AndroidManifest.xml` 添加：

```xml
<!-- 生物识别权限 -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />

<!-- 相机权限（用于扫码、拍照） -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- 麦克风权限（用于语音消息） -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- 发送扩展栏的最近照片/视频（Android 13+） -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<!-- Android 14+ 的有限照片授权 -->
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
<!-- Android 12 及以下 -->
<uses-permission
    android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

确保 `MainActivity` 继承自 `FlutterFragmentActivity`（生物识别需要）：

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

#### iOS

在 `ios/Runner/Info.plist` 添加：

```xml
<!-- Face ID 权限说明 -->
<key>NSFaceIDUsageDescription</key>
<string>使用 Face ID 快速登录</string>

<!-- 相机权限 -->
<key>NSCameraUsageDescription</key>
<string>用于拍照和扫描二维码</string>

<!-- 麦克风权限 -->
<key>NSMicrophoneUsageDescription</key>
<string>用于发送语音消息</string>

<!-- 相册权限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>用于发送图片</string>

<!-- 可选：由扩展栏中的“设置”按钮主动管理有限照片授权 -->
<key>PHPhotoLibraryPreventAutomaticLimitedAccessAlert</key>
<true/>
```

### 初始化

```dart
import 'package:n42_chat/n42_chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化聊天模块
  await N42Chat.initialize(
    N42ChatConfig(
      defaultHomeserver: 'https://matrix.org',
      enableEncryption: true,
      enablePushNotifications: true,
    ),
  );

  runApp(MyApp());
}
```

### 嵌入到 TabView

```dart
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WalletPage(),
          N42Chat.chatWidget(),  // 聊天Tab
          DiscoverPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        // ...
      ),
    );
  }
}
```

### 监听未读消息

```dart
N42Chat.unreadCountStream.listen((count) {
  // 更新Tab徽章
  setState(() => _unreadCount = count);
});
```

### 路由集成

```dart
GoRouter(
  routes: [
    ...appRoutes,
    ...N42Chat.routes(),  // 聊天相关路由
  ],
);
```

---

## 🎨 主题定制

```dart
// 使用预设主题
N42ChatConfig(
  customTheme: N42ChatTheme.wechatLight(),
  // 或 N42ChatTheme.wechatDark()
);

// 自定义主题
N42ChatConfig(
  customTheme: N42ChatTheme(
    primaryColor: Color(0xFF07C160),
    backgroundColor: Color(0xFFEDEDED),
    // ...
  ),
);

// 从 Material 主题生成
N42ChatConfig(
  customTheme: N42ChatTheme.fromMaterialTheme(Theme.of(context)),
);
```

---

## 💰 钱包集成

实现 `IWalletBridge` 接口以启用转账功能：

```dart
class MyWalletBridge implements IWalletBridge {
  @override
  bool get isWalletConnected => _wallet.isConnected;

  @override
  Future<TransferResult> requestTransfer({
    required String toAddress,
    required String amount,
    required String token,
    String? memo,
  }) async {
    // 实现转账逻辑
    final tx = await _wallet.transfer(toAddress, amount, token);
    return TransferResult.success(tx.hash);
  }

  // ... 其他方法
}

// 配置时传入
N42Chat.initialize(N42ChatConfig(
  walletBridge: MyWalletBridge(),
));
```

---

## 📚 API 参考

### N42Chat

| 方法 | 说明 |
|------|------|
| `initialize(config)` | 初始化模块 |
| `chatWidget()` | 获取聊天Widget |
| `routes()` | 获取路由配置 |
| `login(...)` | 用户名密码登录 |
| `loginWithToken(...)` | Token登录 |
| `logout()` | 登出 |
| `purgeLocalData()` | 清理本地会话与缓存 |
| `isLoggedIn` | 登录状态 |
| `currentUser` | 当前用户 |
| `authStatusStream` | 认证状态流 |
| `unreadCountStream` | 未读消息流 |
| `openConversation(roomId)` | 打开会话 |
| `openUserProfile(userId)` | 打开用户资料 |
| `createDirectMessage(userId)` | 创建私聊 |
| `registerPushNotifications()` | 注册推送通知 |
| `dispose()` | 释放资源 |

### N42ChatConfig

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `defaultHomeserver` | `matrix.org` | 默认服务器 |
| `enableEncryption` | `true` | 启用E2EE |
| `enablePushNotifications` | `true` | 启用推送 |
| `syncTimeout` | `30s` | 同步超时 |
| `customTheme` | `null` | 自定义主题 |
| `walletBridge` | `null` | 钱包桥接 |
| `onMessageTap` | `null` | 消息点击回调 |

---

## 📦 依赖项

所有依赖均使用商业友好的开源许可证：

| 包名 | 许可证 | 用途 |
|------|--------|------|
| matrix | Apache 2.0 | Matrix SDK |
| flutter_olm | BSD-3 | E2EE 加密库 |
| flutter_bloc | MIT | 状态管理 |
| get_it | MIT | 依赖注入 |
| go_router | BSD-3 | 路由 |
| drift | MIT | 本地数据库 |
| dio | MIT | HTTP客户端 |
| cached_network_image | MIT | 图片缓存 |
| flutter_secure_storage | BSD-3 | 安全存储 |
| local_auth | BSD-3 | 生物识别 |
| google_sign_in | BSD-3 | Google 登录 |
| sign_in_with_apple | MIT | Apple 登录 |

---

## 🧪 开发

```bash
# 获取依赖
flutter pub get

# 生成国际化文件
flutter gen-l10n

# 运行示例应用
cd example && flutter run

# 运行测试
flutter test

# 代码分析
flutter analyze

# 生成代码（如果使用build_runner）
flutter pub run build_runner build
```

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系

- GitHub: [https://github.com/n42/n42_chat](https://github.com/n42/n42_chat)
- Email: dev@n42.io
