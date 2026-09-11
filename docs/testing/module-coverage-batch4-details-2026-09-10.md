# 第 4 批：真机准备发现的 Solana 发送缺口

本批新增 73 项自动化测试，覆盖发送器、RPC 解码及 UI 确认参数传递。
模块统计明确只包括 Solana sender、message parser、SolApi 和 UI request adapter 四个文件；不把这个百分比称作整个钱包或完整发送页面覆盖率。

## 修复对应的行为

| 范围 | 原问题 | 回归证据 |
|---|---|---|
| 网络选择 | 测试网余额/费用请求混入默认主网 | 对主网/测试网分别断言余额、blockhash、fee、send 的目标；SPL 额外断言 ATA/rent/native balance 的目标 |
| 原生余额与费用 | RPC int 被调用方当成 BigInt；fee 查询空 message；null fee 未拒绝 | 精确大整数、负数、小数、缺失值和过期/null fee；base58 transaction → base64 message |
| SPL 发送 | 未确认可花费的 ATA 余额，建户未保留租金 | 指定 ATA 查询、缺失 recipient account、165-byte rent、只有 fee 而不够 rent 时不广播 |
| 金额 | NaN/Infinity/非正值、u64 越界及 double 精度损失 | 原生 lamports 和 token units 使用精确覆盖值，边界值在 RPC 前失败 |
| MAX | 没有可靠地按当前费用重新构造签名 | 扣费后二次签名，确认第二份 payload 的精确数值；费用耗尽余额时不广播 |
| 重复发送与失败 | 同实例并发、坏签名、空 hash、服务异常 | 同实例只发送一次；广播失败不自动重试；失败后允许重新发起新调用 |
| UI 对接 | 确认页把 BigInt 降级为 double 传给 sender | `solSendRequest` 从确认记录传递精确值；使用确认地址、mint 和网络；账户/网络改变时拒绝继续 |
| 多账户 | 不能让 parent chain 的路径索引或私钥替代 token 所属账户 | parent 只提供路径模板，继续采用发起账户的 index/privateKey |

测试文件：

- `test/features/wallet/api/sender/sol_sender_test.dart`：41 项。
- `test/features/wallet/api/chain_api/sol_api_test.dart`：25 项。
- `test/features/wallet/pages/send/sol_send_request_test.dart`：7 项。

运行方式：

```bash
python3 scripts/module_coverage.py test solana \
  --baseline docs/testing/coverage-baseline-batch4-2026-09-10.json
```

模块 LCOV 写入 `coverage/modules/solana.info`，保留全项目 `coverage/lcov.info`。
本批基线由上一轮完整 3,814 项通过的 LCOV 保存；没有修改 CI 的 70% 门槛、剔除生成代码或使用模块结果代替全项目覆盖率。

## 完整检查

- 完整 Flutter 主测试集：**3,887 项通过**（上一轮 3,814，新增 73），耗时 5 分 59 秒。
- `flutter analyze --no-pub --no-fatal-infos`：139 条已有 info，0 error、0 warning。
- 覆盖率统计脚本：4 项 Python 测试通过。
- 真机脚本：shell 语法通过，缺设备/非测试目标/额外覆盖参数 3 项拒绝检查通过。
- UI 功能入口清单已重新生成，`--check` 通过；`git diff --check` 通过。
- 全项目 LCOV 统计见 [完整报告](module-coverage-batch4-2026-09-10.md)。

## 验证边界与下一批

73 项使用可控 RPC 和签名替身验证应用逻辑；不代表真实 Wallet Core 输出、实际设备认证和最终节点接受均通过。
真实设备部署与 Sui Devnet 链上记录见 [验收报告](../device-test-reports/2026-09-10-device-testnet-acceptance.md)。

后续仍需处理：

- Sui 从旧 JSON-RPC 迁移至 gRPC/GraphQL，同时统一 Dart 与两端原生的签名契约。
- Solana 发送页的旧预模拟使用固定金额，并且没有把模拟返回值完整用于阻断；页面的手续费展示仍是估算值。上述本批 sender 的实际 RPC 校验不能替代 UI 预览精度验收。
- Solana 页面的异步数据库写入失败/页面退出后广播结果落库，以及跨 sender 实例去重。
- Token-2022 支持及完整 Solana 真机付款闭环。
- 真机部署权限恢复后，用 `scripts/test_device.sh` 复验，绝不再依赖 Flutter 的默认卸载行为。
