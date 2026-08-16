# iOS SQLCipher / 截屏防护修复复验 — 2026-08-16

## 范围与结论

- 任务基线：`master@64823cc04af4950d97c9fd66829a6dcc6d5722e7`
- 最终修复：本报告所在提交（基于 `64823cc0`）
- 设备：iPhone 13 Pro Max（iPhone14,3），iOS 26.6（23G71），USB，已解锁
- App：`ai.n42.www`，Profile 真机探针 + Release 生产入口构建
- 状态定义：`PASS` / `FAIL` / `PARTIAL` / `STATIC CONFIRMED` / `BLOCKED`

`64823cc0` 的两项修复在真机上仍未闭环：SQLCipher 的 archive 虽已进入 Pods，最终 Runner 仍解析到系统 SQLite；截屏防护第一次关闭不立即崩，但第二次开启会破坏 UIWindow 的 Auto Layout engine 并 `EXC_BAD_ACCESS`。经用户授权，本轮直接修复后复验，两个根因均已闭环。

| 用例 | 状态 | 结论 |
|---|---|---|
| A1. 老明文 archive 迁移 | **PASS** | 历史 FTS 标记保留，库头转密文，无明文 `.bak`，无 key 查询被拒绝 |
| A2. 全新 archive 首建 | **PASS** | `cipher_version=4.10.0 community`，首建即密文，FTS 可写可搜 |
| A3. SQLCipher 缺失护栏 | **PASS** | 基线缺链接时响亮抛错，旧明文库 SHA-256 完全不变，不再删除历史 |
| B1. 截屏防护开关 | **PASS** | 连续 3 次开/关无崩溃；开启截图内容区黑屏，关闭恢复正常 |
| B2. 会话临时启用/恢复 | **PASS** | `enableForSession` 遮黑，`restoreDefault` 恢复，无残留遮罩或崩溃 |
| B3. 前后台回归 | **PASS** | 防护开启时切 Safari 10 秒后 Runner 仍存活，返回后完成关闭恢复 |
| B4. 系统录屏/多任务卡片目视 | **PARTIAL** | DVT 系统采集确认遮黑；本轮自动化无法操作控制中心录屏或直接导出多任务卡片 |
| C1. crossVerified 双设备矩阵 | **BLOCKED** | 无两套可登录 Chat 测试账号 |
| C2. 隐藏/加锁三态通知 | **BLOCKED** | 无登录会话、对端及可控 FCM |
| C3. iOS 自毁消息长按菜单 | **PASS** | iPhone 真机测试实际菜单：自毁文本/图片均无指定外泄操作，普通消息反例正常 |

Android 在上一轮 `2026-08-16-e2ee-privacy-security-device.md` 已全 PASS；本轮按任务书只聚焦 iOS，没有冒充重复验证。

## A. iOS 归档 SQLCipher

### 基线失败与护栏：PASS

在 `64823cc0` 构建的 Runner 中：

```text
nm -gU Runner | grep sqlite3_key
# 无输出

nm -m Runner
(undefined) external _sqlite3_key (from libsqlite3)
```

将父提交生成的明文 `archive.db`（含唯一标记 `N42_SQLCIPHER_MIGRATION_20260816`）放入 App 容器后，生产归档初始化按预期响亮失败：

```text
ARCHIVE_ERROR Bad state: SQLCipher unavailable: refusing to open archive.db
as plaintext (check '-framework SQLCipher' linker flag on iOS).
```

失败前后旧库 SHA-256 均为：

```text
0cba10952cfa6e9b750736a435cc0bc6a8e83573e63cffdbcc4a286a78e01cd8
```

库头仍是 `53514c69746520666f726d6174203300`（`SQLite format 3\0`）。这确认 SQLCipher 缺失时不会再静默建明文库，也不会删除旧明文历史；失败只影响独立归档库，没有连累 Matrix 主库或导致 App 崩溃。

### 根因与修复

`SQLCipher.framework` 是静态 archive。原配置同时包含系统 `-lsqlite3`，普通 `-framework SQLCipher` 又不足以强制 archive 对象进入 Runner：SQLite 符号先被系统库满足，`sqlite3_key` 没有进入最终可执行文件。

修复后的 Pod 集成会：

1. 从 Runner 聚合 xcconfig 清理系统 `-lsqlite3` / `-lsqlite3.0`；
2. 清理重复的普通 SQLCipher archive 链接项；
3. 对 SQLCipher framework binary 使用 `-force_load`。

最终 Profile 与 Release Runner 均得到本地定义符号：

```text
00000001005644b4 T _sqlite3_key
00000001005644b4 (__TEXT,__text) external _sqlite3_key
```

### 老库迁移：PASS

在全新安装的修复包启动后 25 秒窗口内放入整改前明文库，生产 `ArchiveDatabase` 结果：

```text
ARCHIVE_RESULT cipherVersion=4.10.0 community oldMatches=1
inserted=1 currentMatches=1 plaintextMagic=false backup=false
rejectsNoKey=true size=49152
```

- `oldMatches=1`：整改前历史仍被加密后的 FTS 命中；
- 迁移后头 16 字节：`5a4fbb5a53bd2e8efa887479705d59a1`；
- `.plaintext.bak` 不存在；
- 不带 key 查询报 `file is not a database`；
- 迁移后库 SHA-256：`6792691838196fcffe8185c8e7fb48ad56a1573c32b202882ab21a8b0da9c741`。

### 全新安装：PASS

卸载后重新安装、不注入旧库，结果：

```text
ARCHIVE_RESULT cipherVersion=4.10.0 community oldMatches=0
inserted=1 currentMatches=1 plaintextMagic=false backup=false
rejectsNoKey=true size=49152
```

新库头 16 字节为 `3cd30ce8fe70863a0417529db3d24893`，确认 archive 从首建开始就是密文；插入和 FTS 搜索均成功。

## B. iOS 截屏防护

### 基线复现：FAIL

`64823cc0` 第一次 `on → off` 后，第二次 `applySecure()` 稳定崩溃：

```text
Exception: EXC_BAD_ACCESS / SIGSEGV
Frame: ScreenProtectionHandler.applySecure()
UIKit: UIWindow(UIConstraintBasedLayout) _layoutEngineCreateIfNecessary
Crash: Runner-2026-08-16-041628.ips
```

根因是实现反复移动 `UIWindow.layer` 并拆建带约束的 `UITextField`，破坏了 UIWindow 自身的布局引擎；此前仅修复拆卸顺序，没有消除这一根因。

### 修复后：PASS

新实现不再移动 `UIWindow.layer`。secure `UITextField` canvas 只装配一次，开关仅在原父层与安全 canvas 之间移动 Flutter 根内容 layer；关闭时同时清理录屏 blur。iPhone 真机自动执行：

```text
SCREEN_PHASE=off_initial
SCREEN_PHASE=on_1
SCREEN_PHASE=off_1
SCREEN_PHASE=on_2
SCREEN_PHASE=off_2
SCREEN_PHASE=on_3
SCREEN_PHASE=off_3
SCREEN_PHASE=session_on
SCREEN_PHASE=session_restored
SCREEN_PHASE=background_on
SCREEN_PHASE=complete
```

结果：

- 3 次永久开关全部完成，Runner 未终止，未生成新的崩溃报告；
- `session_on` 的 DVT 设备截图只保留系统状态栏，App 敏感内容区全黑；
- 最终 `setEnabled(false)` 后，敏感测试文字完整恢复；
- `background_on` 时启动 Safari、停留 10 秒，Runner PID 仍存在，返回 App 后继续运行到 `complete`；
- 没有整屏永久黑、残留遮罩或关闭崩溃。

本轮没有自动化控制系统控制中心，因此“持续系统录屏”和“多任务卡片肉眼检查”保持 PARTIAL；DVT 截图采集与前后台存活已经覆盖核心安全渲染和生命周期路径。

## C. 有条件补测

### 自毁消息长按菜单：PASS

iPhone 真机运行实际 `WeChatMessageMenu` 设备测试，普通消息与自毁消息同场反例：

- 普通文本有 `Copy / Forward / Fav / Quote`；自毁文本全部没有；
- 普通图片有 `Save / Extract text / Translate image`；自毁图片全部没有。

补测时发现图片 OCR 项此前只依赖调用方不传回调。为防止未来新入口误传回调，本轮同时在菜单组件内增加 `!message.isSelfDestructing` 防御，并强化单测。

```text
flutter test integration_test/e2ee_privacy_menu_probe_test.dart \
  -d 00008110-001C11A12692801E --no-pub

00:00 +0: iOS self-destruct menus do not expose content
00:04 +1: All tests passed!
```

临时 integration test 已删除，没有进入提交。

### 仍阻塞项

- crossVerified：缺两套真实 Chat 登录账号，无法执行未验证设备 B → SAS 验证 → 新消息解密矩阵；
- 隐藏/加锁搜索与通知：缺登录会话、对端以及可控 FCM，无法执行前台 / 后台 sync / 杀进程 isolate 三态通知。

## 截图证据

- [防护开启：App 内容区遮黑](evidence/2026-08-16-ios-sqlcipher-screen-retest-protection-on.png)
- [防护关闭：内容恢复且完整跑到 complete](evidence/2026-08-16-ios-sqlcipher-screen-retest-protection-off.png)

截图 SHA-256：

```text
on  7ba3536461561a1a72780f2b12e0d38985f6a08311db10363a40811f314958c3
off b002aa4fd4ac67f8c9f841814f28fe4c150366f02f9c4bdd2aab053f36a6ae9a
```

## 构建与回归

```text
flutter pub get
cd packages/n42_chat && flutter pub get
cd ios && pod install

flutter test test/unit/widgets/image_message_menu_test.dart \
  test/unit/entities/notification_filter_rules_test.dart \
  test/unit/entities/message_metadata_encryption_test.dart
# 16 tests passed

flutter build ios --release
# Built build/ios/iphoneos/Runner.app (350.1MB)
```

所有数据库探针与临时测试入口均已删除；原始数据库、完整崩溃报告和探针日志仅保留在本机 `/tmp/n42-e2ee-privacy-20260816/`，未提交任何归档数据或密钥。
