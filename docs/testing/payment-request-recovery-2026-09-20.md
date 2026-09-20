# P13b — 按原幂等键恢复本地请求

日期：2026-09-20。状态：实现与窄测试完成，待主代理审查、提交。

## 固定协议

`GET /requests/{percent-encoded-key}`，原 synthetic Bearer 鉴权，禁止 query/body。路径单次严格解码为 1–128 个 ASCII 0x21–0x7e；`/a?b%+#` 等原键需按单独 path segment 编码，非法百分号、非 ASCII、空白与超长拒绝。

当前 actor 无绑定：404 not_found；有绑定无匹配结果：200 `{mode:localSimulation,status:unresolved}`；有匹配已提交结果：200 `{mode:localSimulation,status:completed,receipt:原收据}`。收据含自身 mode，金额等整数保持十进制字符串。

## 正确性边界

- 同一 SQLite 读取事务检查当前 actor 的 http_idempotency，再根据服务端持久化 route/body 查核心记录；没有调用任何资金动作。
- transfer/packet/refund 由 stable_id 与 actor/kind 查询，且核对操作原参数；避免可信 fixture 直接调用 core 时相同 key、不同参数被误认作本 HTTP 请求成功。
- claim 根据保存的 packet ID 与当前 actor 查唯一领取记录，还原原收据。
- 其他账号与未知键统一 404。不读取/回传 token，不接收 sender，不展示数据库错误。
- unresolved 不表示失败或付款成功；绑定与核心资金动作间中断、尚未提交或业务拒绝都可能处于此状态。404 也不能证明一个仍在传输中的原请求不会随后到达。
- 重启恢复基于同一 SQLite；临时启动器退出清除数据库的既有行为不变。仅本地模拟，不涉及链上确认。

## 执行证据

```sh
python3 -m unittest discover -s backend/payment-sandbox -p test_server.py -v
```

**14 tests passed**（原 10 + 新增 4），日志 `/tmp/n42-payment-request-recovery-tests.log`。

新增覆盖：所有四类动作成功收据查询；claim/refund 无结果时 unresolved；未知与跨账号；传输特殊字符 key；无 token；业务失败与绑定后中断；读取不改变资金；重启前后 unresolved 与 completed；非法编码、双解码防护、未知 query/body；直接 core 同键异参碰撞不误报成功。

修改范围仅 `backend/payment-sandbox/server.py`、`test_server.py`、README 与本文。未改核心账本、Flutter 或提交。

建议英文提交标题：`feat: recover local payment requests by idempotency key`。

## Client evidence

recoverRequest returns either unresolved or a validated immutable local receipt, never treats missing results as a failed payment, and does not resubmit. Five new client tests cover reserved-character keys, malformed/foreign nested receipts, unresolved state, claim receipts and account switching. Combined payment data suite: 24 passed; real Dart/Python protocol queried the original key containing `/`, `?`, `%`, `+`, `#` and returned the correct receipt. Logs: `/tmp/n42-payment-recovery-all-client.log`, `/tmp/n42-payment-recovery-analyze.log`.

## URL canonicalization follow-up

Dart normalizes dot-only path segments: keys `.` and `..` were not preserved by the original path-shaped endpoint. The client now uses `GET /requests?key=...`; the server strictly validates its single query key and retains the original path endpoint for compatibility. 15 HTTP tests and 24 client/protocol tests passed, including a real Dart/Python request key of `..`, reserved characters and cross-account rejection. Logs: `/tmp/n42-payment-dot-key-server.log`, `/tmp/n42-payment-dot-key-client.log`.
