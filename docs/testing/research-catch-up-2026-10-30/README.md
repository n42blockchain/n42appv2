# 公链与钱包追赶：2026-10-30

## 范围与版本

钱包：`n42appv2`，起点 `966959745` / `2.5.3+73044`。公链按用户选择使用 `N42-rs`，起点 `d2e05062b0`，隔离分支 `feat/research-catch-up-20261030`。网站为 `n42-world` 的 `v3`。不修改 n42-26、正在运行的节点数据或他人结果文件。按用户要求跳过真机验收。

本地源码版本不能映射成 App Store 1.0.18 的实际二进制。未取得商店版本与 Git SHA 的发布映射之前，平台/商店验收字段保留 null。下面的完成仅指各项明确列出的代码或本地实验，不代表生产准入。

## 追赶计划与实施

| 优先级 | 工作 | 本轮交付 | 下一道验收门槛 |
| --- | --- | --- | --- |
| P0 | 功能与版本证据 | `feature-evidence.json`、`chain-capabilities.json`、密码清单；所有证据层分开 | 商店二进制来源、iOS/Android 真机及主网证据 |
| P0 | 独立签名策略 | SQLite 持久额度、收款人/网络/资产/账户/费用限制、到期、人工批准、延时修改、冻结恢复；真实离线 EIP-155 签名适配器 | 独立 Agent/OEM 宿主接入及密钥隔离审计；未改已有 EOA/硬件/AA 签名入口 |
| P0 | PQ 登记 | 10,000 validator 状态机；登记权限、算法版本、轮换延迟、重放、原子回滚、双 signer、独立 fence 和缓存签名字节 | 实际 PQ 签名器/HSM、恢复权限治理、链级编码和共识接线 |
| P0 | 聚合 mempool | 32 个逻辑节点/100,000 交易，三种策略，冲突/过期/恶意 dependency 输入；显式逐交易本地接纳策略 | 真正 STARK 电路、网络节点、手机资源和缓存失效基准 |
| P0 | 文案一致性 | 网站 24 语言、旧页面、FAQ、白皮书摘要、法律概览中的链数量描述、SEO/机器可读输出修正 | 官网已部署新目录，逐页核验记录见网站仓库；App Store 元数据仍需发布渠道 |
| P1 | 商户支付 | 现有本地沙盒新增 authorize/capture/void/refund/expiry、赞助费预留、持久 outbox、订单查询、幂等、重启恢复、finality/reorg fixture | 实际合约、RPC canonicality、回调验签和资金/供应商沙盒接入 |
| P1 | 金额一致性 | 10,000 组精确金额/decimals/跨链资产/ABI 属性测试；离线签名后独立解码检查 | 真实确认页、硬件与 AA 签名 payload 端到端 |
| P1 | KZG 批验证 | 固定参考实现 SHA，三种形态 n=1…100 的 Foundry gas 复现、错误输入测试 | N42 当前 EVM 的 CPU/参数一致性与失败定位成本；旧本机节点二进制不作为新源码证据 |
| P2 | CALLSTATUS | 草案 58 场景编号清单、两套 frame 模型、并行与丢弃重执行一致性 | 真实 EVM/Block-STM bytecode/gas adapter；保持生产 opcode 不变 |

## 钱包实现边界

`lib/features/wallet/policy/` 是可供独立 Agent 账户使用的受限 signer facade。可信宿主持有数据库、`SigningPolicyAdmin`、私钥及人工审批 callback；Agent 仅取得 facade。它不能传入“已批准”布尔值、原始 calldata、任意 selector 或修改策略。只支持原生转账和 ERC20 `transfer`；token 地址同时是唯一允许的合约，函数为 `0xa9059cbb`。approve、批量代理调用、签消息和未知函数没有编码入口。

同一不可变 `RestrictedTransfer` 同时用于人工预览、策略检查和签名。金额为 BigInt，EVM 地址校验 checksum。单笔/滚动周期额度及最大网络费在持久事务内检查。签名之前提交 request/nonce 预留；未知结果、空签名和超时保留额度，不自动重签。策略修改和恢复均经 timelock；独立 owner 可立即冻结并取消待生效修改。该库不代表链上 Safe Guard，宿主不得把未受限签名器或数据库暴露给 Agent。数据库被恢复/篡改、宿主进程被攻破和系统时间被控制不在本轮本地策略防护范围内；生产需硬件/服务端可信计量与隔离。

商户模块只使用 `localSimulation` 资金。所有资金和 outbox 更新在同一 SQLite 事务内。outbox 是至少一次投递，消费端必须按 event ID 去重。finality adapter 的 canonicality 来自可信测试宿主，不能把任意 HTTP 回调当链上证据。finality 前重组不捕获资金；finality 后移除事件会冻结该订单的新资金操作，要求对账，不自动重扣或退款。首次只允许全额 capture/refund。

## 自动化证据

- 钱包定向回归最终 131 passed；结果见 `wallet-tests.log.gz`。
- 10,000 组金额属性断言通过；离线签名检查最终链 ID、token 目标和 calldata，未广播。
- 商户 1,000 订单故障注入：事务中故障回滚、提交后响应丢失、重启、重复 capture/refund；同时包含并发 capture/void 和浅/深重组测试。
- 全量静态分析最初 65 info，无 error/warning；本次新增的 12 info 已修正，变更目录定向分析 No issues found。剩余 53 条为既有 info。
- 公链实验及 KZG 原始日志保存在 N42-rs `docs/research/2026-10-30/`。模拟 CPU 是 Python CPU，延迟是模型值，均不是 STARK 或真实入块性能。
- 系统通知的 10,000 事件零漏报/零重复、实际手机、应用商店、生产资金安全指标尚未验收。现有 PushDedupStore 只保留 300 项且跨 isolate 不是原子事务，不能把现有小样本通知测试写成该指标已达标。

## 资料校正与后续顺序

实时复核发现 [EIP-8450](https://eips.ethereum.org/EIPS/eip-8450) 已继续变化：builder 仅登记 XMSS key，不带 VRF；当前文本重新包含 recovery anchor 论证。其仍是 Draft。实验保留算法可替换和权限边界，不选择 leanXMSS 作为生产路线。[EIP-8288](https://eips.ethereum.org/EIPS/eip-8288) 也仍是 Draft，电路上限不能由 2 MiB 传输上限推导。

[NIST IR 8547](https://csrc.nist.gov/pubs/ir/8547/final) 是迁移指导，不是钱包或区块链性能认证。ML-DSA/SLH-DSA 和未来 FN-DSA 的标准状态分开；SHA-384 不是交易签名算法。Safe/Turnkey 的资料只用于设计策略边界，不作为 N42 验收证据。

下一步依次是：独立 signer 宿主隔离审计与恢复设计 → 真实密码实现/电路/客户端适配 → 供应商与公共测试网 → 真机及商店版本映射 → 生产准入。任何步骤不得用模型通过数替代后一步证据。
