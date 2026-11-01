# T28 Keystone BC-UR 真机联调 — 2026-08-07

## 执行结论

T28 已认领。当前主机可见 Android 真机和 iPhone，但没有 Keystone 设备或 Keystone 生成的配对/签名二维码，因此 8 项真机互操作均记为 **BLOCKED（未执行）**，不记 PASS/FAIL，也未修改 `crypto/ur_codec.dart` 或 `crypto/ur_fountain.dart`。

## 环境

- Android：设备 ID `38f4f08a`，Flutter 识别为 Android 16 (API 36)
- iOS：iPhone 17 Pro Max，iOS 27.0，CoreDevice ID `1046FC66-1844-5F30-88D0-7140EBF4A41C`
- Keystone：**未连接/不可用**；因此型号与固件版本无法记录
- App 基线：`master@91a2ab743a8d`（本次只做测试与任务认领，未改 App 代码）
- 日期：2026-08-07，America/Toronto

## 软件基线

命令：

```text
flutter test test/features/hardware_wallet/ --no-pub
```

结果：**64 tests passed**。这是当前 checkout 可运行的硬件钱包定向测试基线；由于没有 Keystone，不能替代任务书所述的 206 项真机互操作验证。

## 8 项用例

| # | 用例 | 结果 | 说明 |
|---|---|---|---|
| 1 | 配对·动画 QR | BLOCKED | 无 Keystone，未获得 crypto-account 多帧 QR |
| 2 | 配对·单帧回退 | BLOCKED | 无 Keystone，未获得 xpub/crypto-hdkey QR |
| 3 | 签名请求·单帧 | BLOCKED | 无 Keystone，未执行 eth-sign-request 扫描 |
| 4 | 签名请求·动画多帧 | BLOCKED | 无 Keystone，未执行 fountain 多帧采集/解析 |
| 5 | 签名回读 | BLOCKED | 无 Keystone，未获得 eth-signature QR |
| 6 | personal_sign 中文 | BLOCKED | 无 Keystone，未执行设备端中文显示比对 |
| 7 | 异常·扫错类型 | BLOCKED | 无 Keystone/配对 QR，未执行错误类型恢复 |
| 8 | 异常·中断恢复 | BLOCKED | 无 Keystone，未执行遮挡后续扫与帧补齐 |

## 初步定性与后续

本次没有原始 QR 内容、截图或照片，因为没有 Keystone 输出物。当前唯一阻塞是**硬件设备缺失**，尚不能将问题定性为 fountain 层、CBOR 内层解析或页面交互缺陷。

拿到 Keystone 3 Pro（或兼容 Keystone）并记录固件版本后，应在本报告基础上重新执行 1–8；若用例 1 进度走满但配对字段错误，按任务书记录 payload hex 前 64 字符并定性为 crypto-account CBOR 内层解析短板；不要修改受守护的两个 crypto 文件。
