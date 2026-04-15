# P0: Chrome 浏览器扩展实现计划

> **状态**: ✅ Phase 1-3 核心已完成 | Phase 4-6 待后续迭代
> **完成日期**: 2026-04-14

## 技术方案：混合方案 C
- Manifest V3 + Vite + React/TypeScript Popup
- Content Script JS 从 `ethereum_provider.dart` 直接移植
- 安全模块从 Dart 移植到 TS（phishing_detector / dapp_security / tx_risk）
- 签名层用 `@noble/secp256k1` + `@scure/bip39/bip32` 替代 Trustdart
- AES-256-GCM 加密存储密钥于 `chrome.storage.local`

## 实现状态

### Phase 1：基础骨架 ✅
- `manifest.json` — Manifest V3 配置
- `package.json` / `tsconfig.json` / `vite.config.ts` — 构建工具链
- `popup.html` — Popup 入口 HTML
- `src/shared/types/rpc.ts` — 共享类型定义

### Phase 2：核心能力 ✅
- `src/content/inpage.ts` — EIP-1193 Provider 注入（EIP-6963 + MetaMask 兼容）
- `src/content/bridge.ts` — 页面 ↔ Service Worker 消息桥
- `src/background/index.ts` — Service Worker 入口 + 消息分发
- `src/background/rpc-router.ts` — RPC 路由器（7 条 EVM 链 + 签名审批流）
- `src/background/keyring.ts` — HD 钱包密钥管理（PBKDF2 + AES-256-GCM）

### Phase 3：安全模块 ✅
- `src/shared/security/phishing.ts` — 钓鱼检测（种子名单 + MetaMask 远程同步）
- `src/shared/security/dapp-security.ts` — DApp 4 级安全评估（verified/safe/caution/blocked）
- `src/shared/security/tx-risk.ts` — 交易风险分析（EVM selector 表 + 无限授权检测）

### Phase 3.5：Popup UI ✅
- `src/popup/App.tsx` — 主应用（路由 + 状态管理）
- `src/popup/pages/Setup.tsx` — 创建/导入钱包
- `src/popup/pages/Unlock.tsx` — 密码解锁
- `src/popup/pages/Home.tsx` — 资产主页
- `src/popup/pages/SignRequest.tsx` — 签名确认（风险分析 + 安全徽章）

### Phase 4：钱包管理 UI 🔲 待实现
### Phase 5：移动端同步 🔲 待实现
### Phase 6：打磨与发布 🔲 待实现

## Simplify 审查修复（2026-04-15）
- `rpc-router.ts` pendingApprovals 添加 5 分钟 TTL 清理机制 `pruneStaleApprovals()`，防止 SW 重启导致内存泄漏

## 关键文件
```
chrome-extension/
├── manifest.json
├── package.json
├── src/
│   ├── background/
│   │   ├── index.ts          # SW 入口
│   │   ├── rpc-router.ts     # RPC 路由 + 审批
│   │   └── keyring.ts        # HD 密钥管理
│   ├── content/
│   │   ├── inpage.ts         # window.ethereum 注入
│   │   └── bridge.ts         # 消息桥
│   ├── popup/
│   │   ├── App.tsx           # 主应用
│   │   └── pages/            # UI 页面
│   └── shared/
│       ├── security/         # 安全模块
│       └── types/            # 共享类型
└── popup.html
```

## 验证
- `tsc --noEmit` — 零错误
- `npm install` — 成功
