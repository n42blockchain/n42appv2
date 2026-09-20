# PAY-SIM-01 — 本地支付模拟核心

日期：2026-09-20。交付状态：代码与测试完成，主代理已审查并按 P04–P08 分步提交。

## 范围与边界

依据只读方案 `docs/plans/payments-red-packets-overseas-2026-09-20.md`，实现 Python 标准库 + SQLite 的本地确定性模拟。所有余额/收据明确 `mode=localSimulation`，production 模式拒绝。没有 HTTP、Nium API 仿冒、外部服务请求、真实凭证、链交易、真实资金或 app 接入。

本轮修改仅 `backend/payment-sandbox/` 与本文。`Sandbox` 是可信本地测试管理员，负责显式 seed、资产白名单及成员夹具；`Account` 是测试主体隔离接口，不声称 Python 对象具有恶意调用者认证能力。未来 API 必须验证身份、采用服务端时间及可信成员来源。

## 分步提交建议

| 步骤 | 英文提交标题建议 | 独占文件 | 验证数量 |
| --- | --- | --- | --- |
| P04 | `feat: add isolated local payment test ledger` | common.py、sandbox.py、account.py、test_support.py、test_ledger.py、.gitignore、README.md | 5 |
| P05 | `feat: simulate idempotent account transfers` | transfers.py、test_transfers.py | 3 |
| P06 | `feat: reserve equal-share test red packets` | packet_reservations.py、test_packet_reservations.py | 3 |
| P07 | `feat: enforce atomic eligible packet claims` | packet_claims.py、test_packet_claims.py | 3 |
| P08 | `feat: refund expired test packet balances` | packet_refunds.py、test_packet_refunds.py、本文 | 2 |

以上源码相对路径均在 `backend/payment-sandbox/` 下。`account.py` 的动作包装采用方法内导入，不在模块导入阶段依赖尚未落盘的后续步骤。已将这些文件按阶段逐个复制到全新临时目录运行对应测试，P04–P08 每阶段均 exit 0；因此不是只有最终整套目录才能运行的提交方案。

## 实现约束

- 仅显式测试 seed 产生资金，seed 也具有主体范围内的幂等性。
- 资产是本地配置的 opaque assetId，显示 symbol 不能隐式兑换或匹配资产。
- 金额只接受 Python int，拒绝 bool/float/string；单次金额和每资产总测试发行量上限均为 9,000,000,000,000,000，小于 SQLite 有符号 64 位上限。
- 每个资金动作在 SQLite `BEGIN IMMEDIATE` 事务内完成，余额、红包预留、唯一领取、幂等记录、成对账本变动共同提交或回滚。
- 转账键按动作与发起账号隔离。同键同参回放原收据，同键异参拒绝；不允许调用者在账户动作中覆盖付款账号。
- 红包等额且必须整除，名额不超过创建时成员快照。发起者也在成员快照中，可以领取一份；这是明确的模拟语义。
- 领取同时验证创建快照与当前成员，账号只领一次；后续成功重试回放收据，不重复入账，即便账号已退出群或红包已过期。
- `now >= expires_at` 禁止新领取。只有原发起账号可以调用显式到期退回，未领金额退回原资产；本轮没有后台定时器。
- 创建幂等回放发生在新请求过期校验之前：相同请求在到期后仍回放原结果，不能创建新红包。主代理审查指出该边界后已修复并补测试。

## 执行证据

```sh
python3 -m unittest discover -s backend/payment-sandbox -p 'test_*.py' -v
```

最终 **16 tests passed**，日志 `/tmp/n42-payment-sandbox-tests.log`。分步验证命令为同样的 discover 命令替换 `-p` 为该步骤测试文件名；另做了从空临时目录逐步落文件的独立可执行检查，P04–P08 全通过。

覆盖：账号/资产隔离、仅模拟模式、非法金额及上限、幂等 seed、重启保留；同键转账并发重试、异参拒绝、资金不足回滚、多请求竞争余额；预留守恒、非法名额、创建到期后幂等回放；成员快照 + 当前资格、重复领取并发、多人竞争名额；精确到期边界、退款权限、剩余退款、重复退款及退款/过期领取并发。每个关键资金路径检查可用 + 预留 = 已 seed 发行量及账本净额为零。

## 后续边界

本地 fixture 的 `now` 是确定性测试参数，不可直接暴露为客户端时间。并发测试使用多线程与每动作独立 SQLite 连接，不证明分布式数据库或公网服务安全。HTTP 鉴权、真实成员证明、供应商适配、资金对账、人工签约及链上测试网由后续独立任务实现；生产没有模拟 fallback。
