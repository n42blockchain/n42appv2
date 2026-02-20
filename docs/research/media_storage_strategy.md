# 媒体存储策略研究

记录日期：2026-02-19  
优先级：Medium（当前有可运行的 workaround，不紧急）

## 背景

iOS 视频播放修复（2026-02-19）采用 temp file 方案作为 workaround：
- iOS AVFoundation 在 HTTP 重定向时丢弃 Authorization header
- 临时修复：下载到临时目录 → 播放 → dispose 时删除
- 问题：每次打开视频都重新下载，无离线能力

## 微信存储策略对比

### 策略清单

| 策略 | 微信 | n42_chat 现状 | 借鉴优先级 |
|------|------|--------------|----------|
| 消息本地持久化 | SQLite ✅ | Matrix SDK SQLite ✅ | 已具备 |
| 渐进式加载（缩略图先行） | ✅ | 图片部分有，视频无 | **高** |
| 网络感知自动下载 | ✅ | ❌ | **高** |
| 本地媒体持久化副本 | ✅ 本地为主 | ❌ 依赖服务端 | **高** |
| 存储配额 UI + 分类清理 | ✅ | ❌ | 中 |
| 下载意图分层（缓存 vs 保存到相册） | ✅ | 部分 | 中 |
| 文件/媒体过期预警 | ✅ | ❌ | 中 |
| 去重存储（hash dedup） | ✅ | ❌ | 低 |
| 本地 DB / 缓存加密 | SQLCipher | E2E 加密媒体，缓存未加密 | 中 |

### 微信核心策略详解

**1. 渐进式加载（Progressive Loading）**  
收到消息自动下载缩略图，原图/视频按需点击下载。  
n42_chat：图片已有缩略图，视频无"先缩略图、点击再下载"的分离策略。

**2. 网络感知自动下载（Network-aware Auto-download）**  
- WiFi：图片自动下载原图、小视频自动下载  
- 移动网络：仅缩略图，视频/文件手动点击  
- 用户可配置阈值（"超过 X MB 不自动下载"）  
n42_chat：无此逻辑，一律按需。

**3. 服务端过期 + 本地副本为主**  
文件服务端保留有限时间（普通 3 天，企业版更长），过期提示用户。  
消息文字/缩略图永久本地 SQLite。  
策略本质：**服务端只负责传输，本地是存储责任方**。

**4. 存储配额 UI + 分类清理**  
设置 → 存储空间：按会话/类型展示占用，可分类清理。

**5. 下载意图分层**  
"应用内缓存"（临时，可清理）vs"保存到相册/文件"（持久，用户主动）。  
路径分离，清缓存不影响用户主动保存的内容。

**6. 文件过期预警**  
服务端文件快过期时，气泡显示"X 天后失效"，引导用户下载/转存。

**7. 去重存储（Deduplication）**  
相同文件（同 hash）在多个会话中转发，本地只存一份。

---

## n42_chat 理想架构

### 分层存储模型

```
内存缓存 (LRU, ~50MB)
    ↓ miss
磁盘临时缓存 (~500MB, 30天TTL, 可清理)
    ↓ 用户主动保存 / 自动预取
本地持久存储 (Documents/Library, 无TTL, 随备份)
    ↓ 超配额
LRU 淘汰（临时缓存层）
```

### 各类型策略

**图片**
- 收到时自动下载缩略图存临时缓存
- 点击查看时下载原图存临时缓存（或持久，根据设置）
- 使用 `flutter_cache_manager` 自定义 CacheManager，路径 `~/Library/Application Support/n42/media/images/`
- 缓存 key = Matrix media ID hash

**视频**
- 缩略图（poster frame）自动下载
- 视频本体按需下载，完成后存持久目录
- SQLite 记录 `eventId → localPath` 映射
- 再次播放优先读本地 → `VideoPlayerController.file()`（iOS 同时解决 auth 问题）
- WiFi 下可后台预取队列中下一条视频

**文件/文档**
- 服务端设置 retention 策略（如 90 天）
- 客户端提示"X 天后服务端将清理，请下载"
- 下载后存 `Documents/n42/files/`

### 存储配额管理

```dart
class StorageQuota {
  static const imagesCacheLimit = 500 * 1024 * 1024;  // 500MB
  static const videosCacheLimit = 2 * 1024 * 1024 * 1024; // 2GB
  // LRU 淘汰：按 lastAccessed 排序，超限时删除最旧的
}
```

### 网络感知下载策略

```dart
enum AutoDownloadPolicy { always, wifiOnly, never }

class MediaDownloadSettings {
  AutoDownloadPolicy images;      // 默认 wifiOnly
  AutoDownloadPolicy videos;      // 默认 wifiOnly，可设阈值
  int videoAutoDownloadMaxMB;     // 默认 50MB
}
```

---

## 实现路径

### Phase 1（高优先级）
- [ ] 视频本地持久化：下载完成后存持久目录，SQLite 记录 eventId→localPath
- [ ] 图片使用 flutter_cache_manager 自定义 CacheManager，路径改为持久目录
- [ ] 新增 `MediaCacheManager` 服务（core/services/）统一管理

### Phase 2（中优先级）
- [ ] 网络感知自动下载设置（WiFi / 移动网络 / 阈值）
- [ ] 存储设置页：按类型展示占用，分类清理
- [ ] 下载意图分层：临时缓存 vs 保存到相册

### Phase 3（低优先级）
- [ ] 服务端 retention 配合：Matrix media_retention 配置 + 客户端过期提示
- [ ] 去重存储（hash dedup）
- [ ] 本地缓存文件加密

---

## 相关文件

```
当前实现（需改造）：
  n42_chat/lib/src/presentation/pages/chat/viewers/video_player_page.dart
  n42_chat/lib/src/presentation/pages/media/media_preview_page.dart

未来实现位置（建议）：
  n42_chat/lib/src/core/services/media_cache_manager.dart      ← 新建
  n42_chat/lib/src/data/datasources/local/media_local_datasource.dart ← 新建
  n42_chat/lib/src/domain/repositories/media_repository.dart   ← 扩展
```

## 依赖评估

| 包 | 用途 | 状态 |
|----|------|------|
| `flutter_cache_manager` | 自定义持久化缓存管理 | 需要添加 |
| `http` | 已有 `^1.2.0` | ✅ |
| `path_provider` | 已有 `^2.1.0` | ✅ |
| `connectivity_plus` | 检测网络类型（WiFi/移动） | 需确认是否已有 |
| `sqflite` | 本地媒体路径映射 | 需确认是否已有 |
