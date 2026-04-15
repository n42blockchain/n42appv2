# N42 App — 后端接口需求文档

> 本文档由 Flutter 端代码反向整理，记录 App 实际调用的所有接口及其期望的请求/响应格式。
> 每个模块标注了当前状态：✅ 已实现 / ⚠️ 部分实现 / ❌ 未实现 / 🔧 需确认格式。

---

## 一、接口 Base URL 汇总

| 服务名 | Base URL (生产) | 用途 |
|--------|----------------|------|
| `userInfoHost` | `https://api.n42.ai/user` | 用户中心（登录/注册/邀请/账户） |
| `exchangeHost` | `https://api.n42.ai/swap` | DEX Swap 兑换 |
| `nftHost` | `https://api.n42.ai/nft-market` | NFT/AST 市场 |
| `tokenViewUri` | `https://api.n42.ai/wallet/` | 钱包资产/交易记录 |
| `marketHost` | `https://api.n42.ai/market/v1` | 行情数据（补充接口） |
| `activiteHost` | `https://api.n42.ai/activity/v1` | 活动/积分 |
| `groupMiningHost` | `https://api.n42.ai/activity` | 挖矿相关 |

---

## 二、邀请码 / Referral 模块

**Base URL**: `userInfoHost` = `https://api.n42.ai/user`

### 2.1 获取设备上的邀请人码 ✅

```
GET /v1/r/user/inviter/code
Query: mobile_model, mobile_name, os
Response: { code: 200, data: "XXXXX" }
```

说明：用于注册前，根据设备指纹查找本机已被哪个邀请码绑定（通过 deep link 安装场景）。

---

### 2.2 邀请好友统计 — 已注册人数 ⚠️

```
GET /v1/r/user/invitee/list
Query: uuid (邀请者的 UUID)
Response:
{
  "code": 200,
  "data": {
    "total": 5,
    "list": [                   // ← App 目前只读 total，list 未使用，建议补充
      {
        "uuid": "xxx",
        "name": "用户昵称",
        "email": "xx@xx.com",
        "created_at": "2024-01-01T00:00:00Z",
        "status": "active"      // active | pending
      }
    ]
  }
}
```

**当前状态**: App 仅读取 `data.total`，list 结构待确认但建议提供，供后续列表展示。

---

### 2.3 邀请好友统计 — 下载 App 人数 ⚠️

```
GET /v1/r/user/invitee/list/download
Query: uuid, page_size (default 1), page_num (default 1)
Response:
{
  "code": 200,
  "data": {
    "total": 3
  }
}
```

**当前状态**: App 只读 `data.total`。

---

### 2.4 邀请好友统计 — 挖矿节点数 ⚠️

```
GET /v1/r/user/invitee/mining
Query: uuid
Response:
{
  "code": 200,
  "data": {
    "total": 2
  }
}
```

---

### 2.5 邀请好友统计 — 挖矿奖励 ⚠️

```
GET /v1/r/user/invitee/mining/fullnode
Query: uuid
Response:
{
  "code": 200,
  "data": {
    "total_reward": "12.50"    // 字符串格式的 N 代币数量
  }
}
```

**重要**: App 使用 `double.parse(dataList['total_reward'])` 解析，需确保返回字符串形式的数字。

---

### 2.6 注册时绑定邀请码 ✅

```
POST /v1/r/user/register/email    (或 /v1/user/registerEmail，以实际路由为准)
Body: {
  "email": "xx@xx.com",
  "pwd": "...",
  "invite_code": "XXXXX",        // 可选，邀请码
  "source": "app",
  "mobile_model": "...",
  "mobile_name": "...",
  "os": "iOS/Android"
}
```

---

## 三、DEX Swap 模块

**Base URL**: `exchangeHost` = `https://api.n42.ai/swap`

### 3.1 查询可交换代币列表 ❌

```
GET /v1/dex/tokens
Query:
  chain: string    // 链标识符，如 "ETH", "BNB", "POLYGON"
  q: string        // 可选，按 symbol/name/address 模糊搜索

Response:
{
  "code": 200,
  "data": [
    {
      "symbol": "USDT",
      "name": "Tether USD",
      "address": "0xdac17f958d2ee523a2206206994597c13d831ec7",
      "decimals": 6,
      "logo": "https://...",
      "chain": "ETH"
    }
  ]
}
```

**说明**: App 在 token 选择界面调用，支持合约地址精确搜索（输入完整 address 时）。

---

### 3.2 获取兑换报价 ❌

```
POST /v1/dex/quote
Body:
{
  "chain": "ETH",
  "token_in": "0x...",           // 输入代币合约地址（或 "0xeeee...eeee" 表示原生币）
  "token_out": "0x...",
  "amount_in": "1000000",        // 原始单位（未除以 decimals）
  "user_addr": "0x...",
  "slippage_bps": 50             // 默认 50 = 0.5%
}

Response (成功):
{
  "code": 200,
  "data": {
    "order_id": "uuid-xxx",      // 后端生成的订单 ID，后续 commit 时使用
    "amount_out": "999000",      // 预期输出量（原始单位）
    "price_impact": "0.12",      // 价格影响百分比
    "fee": "0.003",              // 手续费率
    "route": [...],              // 可选：路由路径描述
    "tx": {                      // 链上交易参数
      "to": "0x...",
      "data": "0x...",
      "value": "0",
      "gas_limit": "200000"
    },
    "expires_at": 1700000000     // unix timestamp，报价有效期
  }
}

Response (失败):
{
  "code": 400,
  "msg": "Insufficient liquidity",
  "err": "..."
}
```

---

### 3.3 提交兑换结果（链上 tx 发送后通知后端）❌

```
POST /v1/dex/commit
Body:
{
  "uuid": "用户 UUID",
  "order_id": "来自 quote 的 order_id",
  "tx_hash": "0x链上交易哈希"
}

Response:
{
  "code": 200,
  "data": true
}
```

**说明**: App 在用户签名并广播交易后调用，后端跟踪订单状态。

---

### 3.4 查询兑换历史 ❌

```
GET /v1/dex/history
Query:
  user: string     // 用户 UUID
  page: int        // 默认 1
  size: int        // 默认 20

Response:
{
  "code": 200,
  "data": {
    "list": [
      {
        "order_id": "xxx",
        "chain": "ETH",
        "token_in_symbol": "ETH",
        "token_in_amount": "0.1",
        "token_out_symbol": "USDT",
        "token_out_amount": "250.00",
        "tx_hash": "0x...",
        "status": "success",       // success | pending | failed
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "total": 42
  }
}
```

---

## 四、用户账户模块

**Base URL**: `userInfoHost`

### 4.1 修改邮箱 — 三步流程 ✅（已实现）

```
Step 1: POST /v1/l/user/send/update/email/code
  Body: { uuid, token, source, new_email }
  → 发送验证码到新邮箱

Step 2: POST /v1/l/user/verify/update/email/code
  Body: { uuid, token, source, code }
  → 验证新邮箱验证码

Step 3: POST /v1/l/user/update/email
  Body: { uuid, token, source, new_email, code }
  → 完成邮箱更换
```

---

### 4.2 修改个人信息 ✅

```
POST /v1/l/user/update/info
Body: {
  uuid, token, source,
  name: "昵称",
  desc: "个人简介",
  image: "头像URL"     // 或 multipart 上传
}
```

---

### 4.3 注销账户 ✅

```
POST /v1/l/user/account/cancel
Body: { uuid, token, source, code }
```

---

## 五、价格预警 / Price Alert 模块

**Base URL**: `userInfoHost` 或独立服务（待确认）

### 5.1 创建/更新价格预警 ❌

```
POST /v1/l/alert/price/set
Body:
{
  "uuid": "用户 UUID",
  "token": "...",
  "symbol": "BTC",
  "coin_gecko_id": "bitcoin",
  "direction": "above",          // "above" | "below"
  "target_price": "70000.00",
  "enabled": true
}

Response: { code: 200, data: { alert_id: "xxx" } }
```

---

### 5.2 查询用户价格预警列表 ❌

```
GET /v1/l/alert/price/list
Query: uuid, token

Response:
{
  "code": 200,
  "data": [
    {
      "alert_id": "xxx",
      "symbol": "BTC",
      "direction": "above",
      "target_price": "70000.00",
      "current_price": "65000.00",
      "enabled": true,
      "triggered": false,
      "created_at": "..."
    }
  ]
}
```

---

### 5.3 删除价格预警 ❌

```
DELETE /v1/l/alert/price/remove
Body: { uuid, token, alert_id }
```

---

### 5.4 推送通知 — 价格触达 🔧

后端在价格触达目标时，通过 FCM/APNs 推送到 App：
```json
{
  "type": "price_alert",
  "symbol": "BTC",
  "direction": "above",
  "target_price": "70000.00",
  "current_price": "70123.45"
}
```

---

## 六、推送通知 Push 模块

App 在登录后注册 FCM Token，后端存储并在以下事件推送：

| 事件 | push type | 当前状态 |
|------|-----------|---------|
| 邀请成功 | `invite_success` | ✅ |
| 挖矿奖励到账 | `mining_reward` | ✅ |
| 价格预警触达 | `price_alert` | ❌ 待实现 |
| 兑换完成 | `swap_complete` | ❌ 待实现 |
| 账户安全告警 | `security_alert` | 🔧 |

---

## 七、待确认事项

| 序号 | 问题 | 优先级 |
|------|------|--------|
| 1 | DEX Swap 全部 4 个接口是否已开发？链上广播由谁负责（前端 or 后端代理）？ | P0 |
| 2 | 邀请统计接口 `/invitee/list` 是否返回 list 字段，还是只有 total？ | P1 |
| 3 | 价格预警推送接入哪个推送服务（Firebase/APNs）？推送 payload 格式？ | P1 |
| 4 | `total_reward` 在 `/invitee/mining/fullnode` 中是字符串还是浮点数？ | P2 |
| 5 | DEX Swap 支持哪些链（chain 参数的合法值）？ | P2 |
| 6 | 兑换的链上签名由 App 端完成还是后端代理签名？ | P0 |

---

*最后更新: 2026-02-22*
