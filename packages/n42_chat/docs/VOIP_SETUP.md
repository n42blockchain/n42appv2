# VoIP 音视频通话配置指南

本文档介绍如何配置音视频通话功能所需的服务端参数。

## 一、服务端组件

### 1. TURN/STUN 服务器 (Coturn)

用于 NAT 穿透，确保不同网络环境下的 P2P 连接。

#### 安装 Coturn

```bash
# Ubuntu/Debian
sudo apt install coturn

# 编辑配置
sudo nano /etc/turnserver.conf
```

#### 配置示例

```ini
# /etc/turnserver.conf
listening-port=3478
tls-listening-port=5349
external-ip=<你的公网IP>
realm=m.si46.world
server-name=turn.m.si46.world

# NAT 中继端口范围
min-port=49152
max-port=65535

# 认证方式：使用共享密钥
use-auth-secret
static-auth-secret=<生成一个强密码>

# 安全配置
no-multicast-peers
no-cli
no-tlsv1
no-tlsv1_1

# 日志
log-file=/var/log/turnserver.log
```

#### 启动服务

```bash
sudo systemctl enable coturn
sudo systemctl start coturn
```

### 2. LiveKit 服务器 (多人会议)

用于 SFU 架构的多人视频会议。

#### Docker 部署

```bash
docker run -d \
  --name livekit \
  -p 7880:7880 \
  -p 7881:7881 \
  -p 7882:7882/udp \
  -p 50000-60000:50000-60000/udp \
  -e LIVEKIT_KEYS="APIKey123: SecretKey456" \
  livekit/livekit-server:latest
```

#### 配置文件方式

```yaml
# /etc/livekit.yaml
port: 7880
rtc:
  port_range_start: 50000
  port_range_end: 60000
  use_external_ip: true
keys:
  APIKey123: SecretKey456
logging:
  level: info
```

---

## 二、Tuwunel 服务器配置

在 `tuwunel.toml` 中添加：

```toml
# VoIP TURN 服务器配置
[turn]
turn_uris = [
    "turn:turn.m.si46.world:3478?transport=udp",
    "turn:turn.m.si46.world:3478?transport=tcp",
    "turns:turn.m.si46.world:5349?transport=tcp"
]
turn_secret = "<与 Coturn 的 static-auth-secret 一致>"
turn_ttl = 86400000
turn_allow_guests = false
```

---

## 三、Flutter 客户端配置

### 方式一：代码配置

```dart
import 'package:n42_chat/src/services/voip/voip.dart';

// 初始化 CallManager
final callManager = CallManager();
await callManager.initialize(
  client: matrixClient,
  navigatorKey: navigatorKey,
);

// 配置 TURN 服务器
callManager.configureTurn(
  uris: [
    'turn:turn.m.si46.world:3478?transport=udp',
    'turn:turn.m.si46.world:3478?transport=tcp',
    'turns:turn.m.si46.world:5349?transport=tcp',
  ],
  username: '<从服务端获取>',  // 临时凭证
  password: '<从服务端获取>',  // 临时凭证
  ttl: 86400000,
);

// 配置 LiveKit（如需多人会议）
callManager.configureLiveKit(
  url: 'wss://livekit.m.si46.world',
  apiKey: 'APIKey123',
  apiSecret: 'SecretKey456',  // 仅服务端使用
);
```

### 方式二：从 Matrix 服务器自动获取

如果 Tuwunel 正确配置了 TURN，客户端会自动从 `/voip/turnServer` API 获取配置：

```dart
// VoIPConfig 会自动从 Matrix 服务器获取 TURN 配置
// 见 webrtc_service.dart 中的 _loadTurnServers() 方法
```

---

## 四、发起通话

### 1对1 语音通话

```dart
await callManager.startVoiceCall(
  roomId: roomId,
  peerId: peerId,
  peerName: peerName,
  peerAvatarUrl: peerAvatarUrl,
);
```

### 1对1 视频通话

```dart
await callManager.startVideoCall(
  roomId: roomId,
  peerId: peerId,
  peerName: peerName,
  peerAvatarUrl: peerAvatarUrl,
);
```

### 多人会议

```dart
// 需要从后端获取 LiveKit Token
final token = await getTokenFromBackend(roomName, participantName);

await callManager.joinMeeting(
  roomName: roomName,
  participantName: participantName,
  token: token,
  enableVideo: true,
  enableAudio: true,
);
```

---

## 五、来电推送配置

### iOS (CallKit)

1. 在 Xcode 中启用 **Push Notifications** 和 **Background Modes > Voice over IP**
2. 配置 APNs 证书
3. 配置 `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>remote-notification</string>
</array>
```

### Android (FCM)

1. 在 Firebase Console 创建项目
2. 下载 `google-services.json` 放入 `android/app/`
3. 配置 `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

---

## 六、测试

### 验证 TURN 服务器

```bash
# 使用 turnutils_uclient 测试
turnutils_uclient -u <username> -w <password> turn.m.si46.world
```

### 验证 LiveKit 服务器

```bash
# 使用 livekit-cli 测试
livekit-cli room list --url wss://livekit.m.si46.world --api-key APIKey123 --api-secret SecretKey456
```

---

## 七、待填入参数

请将以下参数填入相应位置：

| 参数 | 描述 | 示例值 |
|------|------|--------|
| `TURN_SERVER_IP` | TURN 服务器公网 IP | `203.0.113.1` |
| `TURN_SECRET` | TURN 共享密钥 | `your-strong-secret` |
| `LIVEKIT_URL` | LiveKit 服务器地址 | `wss://livekit.example.com` |
| `LIVEKIT_API_KEY` | LiveKit API Key | `APIKey123` |
| `LIVEKIT_API_SECRET` | LiveKit API Secret | `SecretKey456` |

---

## 八、文件结构

```
lib/src/services/voip/
├── voip.dart                    # 导出文件
├── voip_config.dart             # 配置类
├── webrtc_service.dart          # WebRTC 1对1 通话
├── livekit_service.dart         # LiveKit 多人会议
├── call_notification_service.dart # 来电推送
└── call_manager.dart            # 统一管理器

lib/src/presentation/pages/call/
├── call_screen.dart             # 1对1 通话 UI
└── group_call_screen.dart       # 多人会议 UI
```

