# 账户控制与恢复边界

三条流程是威胁模型，不是三种 N42 账户都已生产可用的声明。Passkey 的设备绑定/同步取决于具体 provider；不能把 Passkey 登录等同于链上账户控制权。

```mermaid
sequenceDiagram
  participant U as 用户
  participant A as 本地钱包
  participant K as 设备密钥存储
  participant C as 区块链
  U->>A: 创建或导入助记词
  A->>K: 保存受保护的本地密钥
  U->>A: 确认网络、资产、金额、地址、费用
  A->>K: 请求签名
  K-->>A: 签名结果
  A->>C: 广播并查询确认
  U->>A: 备份或恢复助记词
  Note over U,C: 丢失旧设备不撤销已复制的助记词；需转移资产到新密钥
```

```mermaid
sequenceDiagram
  participant U as 用户
  participant A as Passkey / AA 宿主
  participant P as 系统或同步 provider
  participant C as 智能账户
  U->>P: 注册 WebAuthn 凭证
  P-->>A: 公钥与凭证标识
  A->>C: 经 owner 授权配置账户 signer
  U->>A: 确认 UserOperation
  A->>P: 发起与 payload 绑定的 challenge
  P-->>A: P-256 assertion
  A->>C: 验证并执行
  Note over U,P: 同步恢复依赖 provider；通常不能导出 Passkey 私钥
  U->>C: 通过独立恢复机制更换 signer
  Note over U,C: 删除本地凭证不等于撤销链上 owner；provider 被封恢复需独立演练
```

```mermaid
sequenceDiagram
  participant U as 用户
  participant A as 嵌入式钱包宿主
  participant I as 身份提供方
  participant G as 远端策略服务
  participant E as 远端签名 enclave
  U->>I: 身份认证
  I-->>A: 身份会话
  A->>E: 注册远端账户与客户端认证公钥
  U->>A: 确认交易意图
  A->>G: 经客户端认证密钥签署的请求
  G->>E: 策略允许的精确 payload
  E-->>A: 交易签名
  Note over U,E: 这是外部架构对照，不是 N42 已部署 KMS
  U->>G: 恢复、撤销 authenticator 或请求导出
  Note over U,E: 必须单独验证服务中断退出、IdP 封禁恢复、独立导出和恢复人权限
```

源码证据：`core/wallet_sdk`、`core/passkey`、`features/wallet/aa/recovery`、`features/wallet/mpc`。接口存在不保证供应商可用、门限 MPC/远端 enclave 实际部署或独立退出路径通过。
