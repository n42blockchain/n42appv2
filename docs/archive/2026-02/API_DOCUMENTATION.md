# N42 后端 API 接口文档

## 目录

1. [Chat 第三方登录接口](#一chat-第三方登录接口)
2. [主项目核心接口](#二主项目核心接口)

---

## 一、Chat 第三方登录接口

### 基础信息

| 项目 | 值 |
|-----|---|
| 基础 URL | `https://api.n42.network` |
| Content-Type | `application/json` |
| 来源标识 | `source: "app"` |

---

### 1. 社交账号登录

**端点：** `POST /v1/user/loginSocial`

**功能：** 使用第三方社交账号登录，返回用户信息和 Matrix 聊天凭证

#### 1.1 Google 登录

**请求体：**
```json
{
  "provider": "google",
  "id_token": "Google ID Token",
  "access_token": "Google Access Token (可选)",
  "source": "app"
}
```

#### 1.2 Apple 登录

**请求体：**
```json
{
  "provider": "apple",
  "id_token": "Apple Identity Token",
  "access_token": "Apple Authorization Code",
  "source": "app"
}
```

#### 1.3 Facebook 登录

**请求体：**
```json
{
  "provider": "facebook",
  "id_token": "Facebook Access Token",
  "access_token": "Facebook Access Token",
  "source": "app"
}
```

#### 1.4 Twitter 登录

**请求体：**
```json
{
  "provider": "twitter",
  "id_token": "Twitter Auth Token",
  "access_token": "Twitter Auth Token Secret (可选)",
  "source": "app"
}
```

#### 1.5 微信登录

**请求体：**
```json
{
  "provider": "wechat",
  "id_token": "微信授权码 (code)",
  "source": "app"
}
```

#### 响应体（成功）

```json
{
  "code": 200,
  "data": {
    "uuid": "用户唯一标识",
    "token": "认证令牌",
    "email": "用户邮箱",
    "nickname": "用户昵称",
    "avatar": "头像URL",
    "matrix_user_id": "@user:server.com",
    "matrix_access_token": "Matrix访问令牌",
    "matrix_device_id": "Matrix设备ID",
    "matrix_homeserver": "https://matrix.server.com"
  }
}
```

#### 响应体（失败）

```json
{
  "code": 401,
  "err": "错误描述"
}
```

---

### 2. 绑定社交账号

**端点：** `POST /v1/l/user/bind/social`

**功能：** 将社交账号绑定到已有用户

**请求体：**
```json
{
  "uuid": "用户UUID",
  "token": "用户认证令牌",
  "source": "app",
  "provider": "google|apple|facebook|twitter|wechat",
  "id_token": "社交平台凭证"
}
```

**响应体：**
```json
{
  "code": 200
}
```

---

### 3. 解绑社交账号

**端点：** `POST /v1/l/user/unbind/social`

**功能：** 解除社交账号绑定

**请求体：**
```json
{
  "uuid": "用户UUID",
  "token": "用户认证令牌",
  "source": "app",
  "provider": "google|apple|facebook|twitter|wechat"
}
```

**响应体：**
```json
{
  "code": 200
}
```

---

### 4. 获取已绑定社交账号

**端点：** `GET /v1/lr/user/social/accounts`

**功能：** 获取用户已绑定的所有社交账号列表

**查询参数：**
```
?uuid=用户UUID&token=用户令牌&source=app
```

**响应体：**
```json
{
  "code": 200,
  "data": [
    {
      "provider": "google",
      "email": "user@gmail.com",
      "display_name": "用户名",
      "bound_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

---

### 社交登录提供商汇总

| 提供商 | provider 值 | 主要凭证 | 说明 |
|-------|------------|---------|------|
| Google | `google` | id_token | 可选传 access_token |
| Apple | `apple` | id_token + authorizationCode | 需要授权码 |
| Facebook | `facebook` | access_token | 使用 access_token |
| Twitter | `twitter` | authToken | 可选传 authTokenSecret |
| 微信 | `wechat` | code (授权码) | 后端换取 access_token |

---

## 二、主项目核心接口

### 1. 用户与认证

#### 1.1 用户信息接口

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/user/info` | GET | 获取用户信息 |
| `/v1/user/update` | POST | 更新用户信息 |

---

### 2. 钱包相关接口

#### 2.1 链和代币列表

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/chain/list` | GET | 获取所有支持的主链列表 |
| `/v1/token/list` | GET | 获取指定主链的所有代币 |

#### 2.2 市场数据

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/market/coins` | GET | 获取币种价格信息 |
| `/v1/market/coin/detail` | GET | 获取币种详细信息 |

**请求参数：**
```
?symbols=ETH,BTC,USDT
```

**响应体：**
```json
{
  "error": false,
  "data": {
    "data": [
      {
        "coin": "ETH",
        "price": 3500.00,
        "price_change_per_24h": 2.5,
        "image": "https://icon.url"
      }
    ]
  }
}
```

---

### 3. 余额查询接口

#### 3.1 通用余额查询

**端点：** `POST /v1/balance`

**支持的区块链：**
- EVM 兼容链：ETH, BSC, MATIC, AVAX, FTM, ARB, OP 等
- 比特币类：BTC, LTC, DOGE, BCH
- 其他链：SOL, TRX, ATOM, DOT, XRP, ALGO, FIL, APT, SUI, TON, NEAR

**请求体：**
```json
{
  "blockchain": "Ethereum",
  "chain": "ETH",
  "address": "0x...",
  "contract": "代币合约地址 (可选)",
  "isTest": false
}
```

**响应体：**
```json
{
  "error": false,
  "data": "1000000000000000000"
}
```

---

### 4. 交易相关接口

#### 4.1 发送交易

**端点：** `POST /v1/tx/send`

**请求体：**
```json
{
  "blockchain": "Ethereum",
  "chain": "ETH",
  "signedTx": "0x签名后的交易数据"
}
```

**响应体：**
```json
{
  "error": false,
  "data": "0x交易哈希"
}
```

#### 4.2 获取 Gas 价格

**端点：** `GET /v1/gas/price`

**查询参数：**
```
?chain=ETH
```

**响应体：**
```json
{
  "error": false,
  "data": {
    "gasPrice": "30000000000",
    "maxFeePerGas": "35000000000",
    "maxPriorityFeePerGas": "2000000000"
  }
}
```

#### 4.3 获取交易记录

**端点：** `GET /v1/tx/list`

**查询参数：**
```
?chain=ETH&address=0x...&page=1&pageSize=20
```

**响应体：**
```json
{
  "error": false,
  "data": {
    "list": [
      {
        "hash": "0x...",
        "from": "0x...",
        "to": "0x...",
        "value": "1000000000000000000",
        "timestamp": 1704067200,
        "status": "success"
      }
    ],
    "total": 100
  }
}
```

---

### 5. ENS 域名服务

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/ens/resolve` | GET | ENS 正向解析 (域名→地址) |
| `/v1/ens/reverse` | GET | ENS 反向解析 (地址→域名) |
| `/v1/ens/avatar` | GET | 获取 ENS 头像 |
| `/v1/ens/records` | GET | 获取 ENS 文本记录 |

**正向解析请求：**
```
?name=vitalik.eth
```

**响应体：**
```json
{
  "error": false,
  "data": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
}
```

---

### 6. 地址簿接口

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/addressbook/list` | GET | 获取地址簿列表 |
| `/v1/addressbook/save` | POST | 保存地址 |
| `/v1/addressbook/update` | POST | 更新地址 |
| `/v1/addressbook/delete` | POST | 删除地址 |

---

### 7. IPFS 文件服务

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/ipfs/upload` | POST | 上传文件到 IPFS |
| `/v1/ipfs/info` | GET | 获取 IPFS 文件信息 |
| `/v1/ipfs/download` | GET | 下载 IPFS 文件 |

---

### 8. Mining 挖矿接口

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/mining/keypair` | POST | 生成 BLS12-381 密钥对 |
| `/v1/mining/deposit` | POST | 创建存款交易 |
| `/v1/mining/exit` | POST | 创建退出交易 |
| `/v1/mining/validator` | GET | 获取验证器信息 |
| `/v1/mining/withdrawals` | GET | 获取提取记录 |
| `/v1/mining/summary` | GET | 获取收益汇总 |

---

### 9. 跨链桥接 (LI.FI)

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/lifi/chains` | GET | 获取支持的链列表 |
| `/v1/lifi/tokens` | GET | 获取链上代币列表 |
| `/v1/lifi/quote` | GET | 获取跨链报价 |
| `/v1/lifi/routes` | POST | 获取所有可用路由 |
| `/v1/lifi/status` | GET | 查询交易状态 |

---

### 10. 应用版本

**端点：** `GET /v1/app/version`

**响应体：**
```json
{
  "error": false,
  "data": {
    "version": "2.0.0",
    "build": "100",
    "force_update": false,
    "download_url": "https://..."
  }
}
```

---

### 11. 新闻资讯

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/news/list` | GET | 获取新闻列表 |
| `/v1/news/detail` | GET | 获取新闻详情 |

---

### 12. 人脸识别

| 端点 | 方法 | 说明 |
|-----|------|-----|
| `/v1/face/bind` | POST | 绑定人脸 |
| `/v1/face/match` | POST | 人脸匹配验证 |
| `/v1/face/unbind` | POST | 解除人脸绑定 |

---

## 三、通用响应格式

### 成功响应

```json
{
  "error": false,
  "data": { ... }
}
```

### 失败响应

```json
{
  "error": true,
  "message": "错误描述"
}
```

或

```json
{
  "code": 400,
  "err": "错误描述"
}
```

---

## 四、支持的区块链

| 类型 | 链 |
|-----|---|
| EVM 兼容 | ETH, BSC, MATIC, AVAX, FTM, ARB, OP, BASE, N |
| 比特币类 | BTC, LTC, DOGE, BCH |
| 独立链 | SOL, TRX, ATOM, DOT, XRP, ALGO, FIL, APT, SUI, TON, NEAR, XTZ, ZIL, ADA, XLM, VET, ONE, IOTX, EGLD, THETA |

---

*文档版本：v1.0*
*更新日期：2026-02-01*
