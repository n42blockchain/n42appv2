# P09a — 本地支付模拟 HTTP 适配

日期：2026-09-20。状态：实现与窄测试完成，待主代理审查/提交。

## 修改边界

本子任务仅新增 `backend/payment-sandbox/server.py`、`test_server.py`，追加该目录 README 的 P09a 节及本文。复用现有 SQLite 核心，没有改 Flutter、AI 后端或其他资金核心文件，没有提交。

主代理已收到固定协议，可并行开发显式关闭默认入口的 Flutter 本地客户端。实现只允许 `mode=localSimulation` 与字面地址 `127.0.0.1`；启动显式 synthetic token → 测试账号映射。禁止其他绑定地址、真实凭证格式、浏览器 Origin、非预期 Host。HTTPServer 原有反向 DNS 被数值 loopback 绑定覆盖，避免附带网络查询。

## 接口验收

- GET `/balances?asset=...`；POST `/transfers`、`/packets`、`/packets/{id}/claims`、`/packets/{id}/refunds`。
- 成功 JSON 直接返回对象，统一含 `mode=localSimulation`，所有整数是规范十进制字符串。精确字段见 README 的固定协议表。
- Bearer 令牌决定主体；不能覆盖 sender/account/now；服务端时钟注入当前时间。seed 与成员管理无 HTTP 写入口。
- POST 强制幂等键，SQLite 持久化 `(actor,key) → route + canonical body`。同账号同键异路由/异参拒绝，重启后保留。核心动作继续承担事务性资金幂等。
- HTTP 幂等绑定与核心资金动作是两个事务，不声称一个跨层事务。崩溃后同请求重试已有核心唯一动作，不会双扣；业务失败后的 key 保留绑定，允许条件满足后同请求重试。
- 64 KiB 限制，重复 JSON key/错误类型/未知字段拒绝；错误返回稳定 code + 通用 message，不输出内部异常、账户状态或 token。

## 测试结果

```sh
python3 -m unittest discover -s backend/payment-sandbox -p test_server.py -v
```

**7 项真实 loopback HTTP 测试全部通过**。最终日志 `/tmp/n42-payment-http-tests-v2.log`，执行约 0.27 秒。

覆盖：仅本地/仅模拟/仅 synthetic token 配置；无 token、错误 token；两个账号余额隔离；无 seed/member endpoint；Origin/Host 拒绝；整数字符串、未知 sender/now/account、缺幂等键；转账重放与同键异参，服务重启后幂等保留；红包资格、服务端过期时钟、一次领取、精确退款、跨路由键冲突；过大/畸形 JSON 与通用错误；真实 HTTP 并发重复转账守恒。

## 限制与后续

- 这是单机本地 fixture，不是 Nium 沙盒、生产支付 API 或链上测试网。
- 本轮不提供网络认证生产方案、TLS、公开部署、充值接口、成员认证、真实供应商调用或 app 入口。
- Python harness 仍是可信测试管理员；后续真实服务需要独立鉴权、成员来源与生产资金状态设计，不能把本地模拟自动作为 production fallback。
- 建议独立提交标题：`feat: expose opt-in loopback payment simulation API`。
