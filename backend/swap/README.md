# N42 Swap 后端（Go / gin / PostgreSQL）

App `exchangeHost`（`api.n42.ai/swap`）背后的服务。接口需求与请求/响应格式见
`../../docs/BACKEND_REQUIREMENTS.md`（§三 DEX Swap、§五 价格预警）。

## 模块

- **DEX 聚合**：`/v1/dex/tokens|quote|commit|history` — 1inch / Jupiter / Uniswap 聚合报价，兑换提交与历史
- **限价单**：`/v1/dex/limit`（POST/GET/DELETE）— 存取 + 价格监控（30s 轮询聚合器报价）。
  ⚠️ 非托管架构下后端无用户私钥，**不能代签成交**；触发后仅更新状态，成交由客户端完成
- **价格预警**（2026-07-03 新增，补 BACKEND_REQUIREMENTS §五 的 ❌）：
  - `POST /v1/l/alert/price/set` 创建/更新（按 `alert_id` 幂等，更新即重新武装）
  - `GET /v1/l/alert/price/list?uuid=` 列表（含监控缓存的 `current_price`）
  - `DELETE /v1/l/alert/price/remove` 删除（校验归属）
  - `GET /v1/l/alert/price/triggered?uuid=&since=` App 前台轮询兜底（无推送设施也可用）
  - 监控循环：60s 批量查 CoinGecko `simple/price`（USD），达标即标记触发 + 通知
- **交易确认监视**：`monitor/` — 已提交兑换的链上确认状态

## 环境变量

| 变量 | 必填 | 说明 |
|---|---|---|
| `PORT` | 否 | 默认 8080 |
| `DB_DSN` | ✅ | PostgreSQL DSN（启动自动建表，幂等）|
| `INCH_API_KEY` | ✅ | 1inch API key |
| `ETH_RPC` `BSC_RPC` `POLYGON_RPC` `ARB_RPC` `OP_RPC` | ✅ | 各链 RPC |
| `CORS_ORIGINS` | 否 | 逗号分隔的允许来源 |
| `COINGECKO_BASE` | 否 | CoinGecko base URL（默认官方免费端点；可指向代理）|
| `COINGECKO_API_KEY` | 否 | CoinGecko demo key（`x-cg-demo-api-key`，免费额度更高）|
| `PUSH_WEBHOOK_URL` | 否 | 价格预警触发事件的 webhook（POST JSON，负载见 BACKEND_REQUIREMENTS §5.4 + `user_uuid`/`alert_id`）。由运维桥接到 FCM/APNs；未配置仅记日志，App 轮询兜底 |

## 构建 / 测试 / 部署

```bash
go build ./...
go test ./...
docker build -t n42-swap .   # 仓库根 backend/swap/Dockerfile
```

## 鉴权说明（诚实标注）

当前所有接口按 `uuid` 归属校验、**无 token 鉴权**（与既有 dex 接口一致）。文档 §五
请求里的 `token` 字段暂未校验——生产部署应在网关层（api.n42.ai 反代）统一鉴权，
或后续在本服务加中间件对接 `userInfoHost` 的 token 校验。
