# E2EE / 隐私安全整改真机验证 — 2026-08-16

## 范围与结论

- 测试基线：`master@70fd983790e7e3dc98dea45a4358e3f86257d9d5`
- Android：Redmi `25098RA98C`，Android 16 / API 36，USB
- iOS：iPhone 13 Pro Max（iPhone14,3），iOS 26.6，USB、已解锁
- 执行原则：只验证、诊断和记录；没有修改业务代码，没有提交、没有推送。
- 状态定义：`PASS` / `FAIL` / `PARTIAL` / `STATIC CONFIRMED` / `BLOCKED`

本轮确认两个 P0/P1 真机缺陷：

1. **iOS 归档库未被 SQLCipher 加密。** 老明文库升级后历史归档丢失，重建库仍以 `SQLite format 3` 开头；全新安装的新库同样为明文。Android 的迁移、新库和加密后 FTS 均正常。
2. **iOS 截屏防护关闭路径会产生 CALayer 循环并崩溃。** 开启时设备截图确实被遮黑；切换关闭时抛 `CALayerInvalid`，重新启动后设备截图仍为黑屏。Android `FLAG_SECURE` 开关回归正常。

| 用例 | Android | iOS | 结论 |
|---|---|---|---|
| 1. SQLCipher 老库迁移 | PASS | **FAIL** | Android 保留历史且转密文；iOS 丢失旧归档并重建明文库 |
| 1. SQLCipher 全新库 / FTS | PASS | **FAIL** | Android 新库首建即密文；iOS 新库仍是 SQLite 明文 |
| 2. 自毁/查看一次不归档 | STATIC CONFIRMED | STATIC CONFIRMED | 无可用 Chat 登录态，未完成真实消息流；源码过滤点已确认 |
| 2. redaction 回删 / 普通消息反例 | PASS（DB 真机探针） | PASS（DB 真机探针） | 两端 `deleteByEventId=1`，删除后 FTS 命中为 0；普通消息删除前命中为 1 |
| 3. E2EE 默认 crossVerified | BLOCKED | BLOCKED | 缺少两套可登录测试账号/会话，无法完成 A/B 交叉验证矩阵 |
| 4. 隐藏/加锁搜索与三态通知 | BLOCKED | BLOCKED | 缺登录会话与真实 FCM 对端；仅完成源码路径确认 |
| 5. 自毁消息长按菜单 | PASS（真机测试壳） | BLOCKED | Android 真机断言通过；iOS 测试壳覆盖安装停滞，未冒充双端 PASS |
| 6. 截屏防护 | PASS | **FAIL** | Android 开启黑屏、关闭恢复；iOS 开启遮黑但关闭崩溃且无法恢复 |

## 1. 归档库 SQLCipher 加密与迁移

### Android：PASS

先在整改前父提交 `39986541` 上创建明文归档，写入唯一标记 `N42_SQLCIPHER_MIGRATION_20260816`。旧库头 16 字节为：

```text
53514c69746520666f726d6174203300  # SQLite format 3\0
OLD_PROBE inserted=1 matches=1 plaintextMagic=true backup=false size=49152
```

不清数据覆盖安装 `70fd9837` 后：

```text
CURRENT_PROBE oldMatches=1 inserted=1 currentMatches=1 deleted=1
afterDelete=0 plaintextMagic=false backup=false rejectsNoKey=true
size=49152 screenProtected=false
SQLiteLog: file is not a database in "SELECT count(*) FROM archived_messages"
```

- 旧标记仍被 FTS 命中：迁移数据未丢。
- 新库头为 `128a5c318bcea6be8dd8fe2e630d5ad0`，不含 SQLite 魔数。
- 不带 key 直接查询报 `file is not a database`。
- `.plaintext.bak` 不存在。

随后卸载、全新安装并创建归档：

```text
CURRENT_PROBE oldMatches=0 inserted=1 currentMatches=1 deleted=1
afterDelete=0 plaintextMagic=false backup=false rejectsNoKey=true
size=49152 screenProtected=false
```

新库头为 `9bab9f892f68c6cc714c60a15de0c484`，确认首建即密文，FTS 插入/搜索/删除均工作。

### iOS：FAIL

整改前版本的老库基线正常为明文：

```text
53514c69746520666f726d6174203300
OLD_PROBE inserted=1 matches=1 plaintextMagic=true backup=false size=49152
```

覆盖升级到 `70fd9837` 后：

```text
CURRENT_PROBE oldMatches=0 inserted=1 currentMatches=1 deleted=1
afterDelete=0 plaintextMagic=true backup=false rejectsNoKey=false
size=49152 screenProtected=false
```

- `oldMatches=0`：迁移前历史标记未保留，符合“迁移失败后删旧库并重建”的 fallback。
- 重建后的库头仍为 `SQLite format 3`；不带 key 可以直接读取。
- `.plaintext.bak` 不残留，迁移失败没有导致进程崩溃，但归档历史丢失。

全新卸载安装后结果仍相同：

```text
CURRENT_PROBE oldMatches=0 inserted=1 currentMatches=1 deleted=1
afterDelete=0 plaintextMagic=true backup=false rejectsNoKey=false
size=49152 screenProtected=false
```

新库头仍为 `53514c69746520666f726d6174203300`，因此不是仅迁移逻辑失败，而是 iOS 当前 SQLite FFI 实际没有落到 SQLCipher。

初步定性证据：Pods 已安装 `SQLCipher 4.10.0` 与 `sqlcipher_flutter_libs`，但最终 Runner 可执行文件仍显示：

```text
/usr/lib/libsqlite3.dylib (compatibility version 9.0.0, current version 382.0.0)
```

`nm` 未找到 `sqlite3_key` / `sqlcipher_export` 符号。推断 iOS 所依赖的“链接期覆盖”没有生效，FFI 实际解析到系统 SQLite。此项必须修复后重新验证老库 `sqlcipher_export` 与新库首建。

## 2. 自毁、查看一次与 redaction

### 真机已确认部分：PASS

Android 与 iOS 的真实归档数据库探针均完成以下序列：

1. 插入普通消息，FTS 命中数为 1；
2. 调用生产 `deleteByEventId`（redaction 使用的数据库回删层），返回删除 1 行；
3. 再次全文搜索，命中数为 0。

这确认 redaction 的归档回删和 FTS 清理在两端数据库层有效；iOS 此处只代表功能链路，数据库仍是明文，不能抵消用例 1 的 FAIL。

### 未闭环部分：STATIC CONFIRMED

本轮设备上没有可用 Chat 登录态，无法真实发/收自毁和查看一次事件。源码中 `_isArchivableEvent` 会在 `n42.self_destruct` 字段存在时直接排除，覆盖 `after == 1` 的查看一次特例；但没有把源码结论写成真机 PASS。

## 3. E2EE 密钥共享默认 crossVerified：BLOCKED

两台设备均无可用 Chat 测试凭据，环境变量 `N42_E2E_CHAT_USERNAME` / `N42_E2E_CHAT_PASSWORD` 为空，无法建立“未验证设备 B → SAS 验证 → 新消息解密”的真实矩阵。

源码确认默认配置为 `shareE2eeKeysWithAllDevices=false`，Matrix client 映射为 `ShareKeysWith.crossVerified`；该项记为 `STATIC CONFIRMED`，不替代双设备真机验证。

## 4. 隐藏/加锁会话搜索与通知：BLOCKED

缺少登录会话、第二个发信端与可控 FCM 推送，以下真实链路无法执行：前台、后台 sync、杀进程后台 isolate，以及普通会话 Z 的反例。

源码静态确认：

- 全局搜索会合并隐藏与加锁 roomId，并过滤会话项、在线消息与归档命中；
- 前台 FCM、后台 FCM 与 sync 通知路径均调用同一隐藏/加锁判断；
- 后台 isolate 直接读取 SharedPreferences，未依赖 DI。

仍需带真实账号和 FCM 的三态真机复测，当前不记 PASS。

## 5. 自毁消息长按菜单

Android 真机运行实际 `WeChatMessageMenu` 的设备测试壳，结果 `All tests passed`：

- 普通文本：`Copy / Forward / Fav / Quote` 均存在；
- 自毁文本：上述四项均不存在；
- 普通图片：`Save / Extract text / Translate image` 均存在；
- 自毁图片：上述三项均不存在。

图片 OCR 的生产调用侧同时检查 `!message.isSelfDestructing` 后才传回调。本轮 iOS 测试壳构建成功，但 CoreDevice 覆盖安装长时间停在 install 阶段，因此 iOS 保持 BLOCKED。

执行命令与结果：

```text
flutter test integration_test/e2ee_privacy_menu_probe_test.dart \
  -d 38f4f08a --no-pub

00:02 +1: All tests passed!
```

## 6. 截屏防护

### Android：PASS

同一 Profile 探针开启后日志为 `SCREEN_PROTECTION_APPLIED=true`，`adb screencap` 中应用内容全部为黑色；关闭版本覆盖安装后日志为 `SCREEN_PROTECTION_APPLIED=false`，同一敏感测试字符串重新出现在截图中。`FLAG_SECURE` 开启与恢复均符合预期。

### iOS：FAIL

开启后 `SCREEN_PROTECTION_APPLIED=true`，DVT 设备截图中 App 内容被完全遮黑，仅系统状态栏可见，说明保护效果本身生效。

切换关闭时原生侧返回 `SCREEN_PROTECTION_APPLIED=false` 后进程立即终止：

```text
Exception Type:  NSException / CALayerInvalid
Reason: layer <CALayer: ...> is a part of cycle in its layer tree
Termination: SIGABRT
```

终止后重新启动，Runner 进程存在且设备已解锁，但 DVT 截图仍只有黑色 App 区域，未恢复正常显示。该故障与任务书关注的 secure-field 图层寄生失败模式一致。

由于关闭动作已经稳定触发 native crash，本轮没有继续反复执行物理按键截图、系统录屏、多任务快照或 E2E 会话临时启用，避免无意义地重复崩溃。这些子项在修复图层拆卸/恢复之前为 BLOCKED。

## 截图证据

- [Android 整改前明文归档](evidence/2026-08-16-e2ee-android-old-plaintext.png)
- [Android 老库迁移后密文](evidence/2026-08-16-e2ee-android-migrated-encrypted.png)
- [Android 全新密文库](evidence/2026-08-16-e2ee-android-fresh-encrypted.png)
- [iOS 整改前明文归档](evidence/2026-08-16-e2ee-ios-old-plaintext.png)
- [iOS 老库迁移失败、重建仍明文](evidence/2026-08-16-e2ee-ios-migration-failed.png)
- [iOS 全新安装仍为明文库](evidence/2026-08-16-e2ee-ios-fresh-plaintext.png)
- [Android 防护开启：截图黑屏](evidence/2026-08-16-e2ee-android-protection-on.png)
- [Android 防护关闭：敏感内容恢复](evidence/2026-08-16-e2ee-android-protection-off.png)
- [iOS 防护开启：截图黑屏](evidence/2026-08-16-e2ee-ios-protection-on.png)
- [iOS 关闭崩溃后重启：截图仍黑](evidence/2026-08-16-e2ee-ios-protection-off-relaunch-black.png)

## 环境与仓库说明

- 根目录与 `packages/n42_chat/` 均已执行 `flutter pub get`。
- iOS 已执行 `pod install`，确认 SQLCipher 4.10.0 pod 被解析。
- 所有数据库探针、临时入口与真机菜单测试壳在报告完成后删除。
- 原始数据库副本与完整探针日志仅保留在本机 `/tmp/n42-e2ee-privacy-20260816/`，未加入仓库。
- 按任务要求，本报告及截图证据保持未提交状态，没有 commit，没有 push。
