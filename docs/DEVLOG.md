# N42 Wallet — 开发日志

> 格式：`## [日期] 标题`，新记录置顶。
> **提交规范**：每个独立步骤（i18n / 逻辑修复 / UI / 测试）单独提交，便于 bisect 与 review。

---

## [2026-02-21] DeFi 模块三连：跨链桥 + 多链质押 + BTC 自托管质押

### 背景

三个 DeFi 模块功能不完整或存在关键缺陷：
- **跨链桥（Li.Fi）**：缺少状态追踪、成功/失败通知，路由对比无展示
- **质押（ETH/SOL/ATOM）**：APY 全部静态硬编码，解质押流程仅弹 "coming soon"
- **BTC 自托管质押**：`self_custody.dart` 是空壳，无流程说明，无风险提示

---

### 模块一：跨链桥修复 `e433e05`

#### 改动文件

| 文件 | 说明 |
|------|------|
| `lib/src/bridge/pages/bridge_home_page.dart` | 路由对比卡（多 provider 价格/时间并排），轮询状态追踪 |
| `lib/src/bridge/pages/bridge_history_page.dart` | 状态变化本地通知，持久化历史（SharedPreferences） |
| `lib/src/bridge/pages/bridge_select_chain_page.dart` | 搜索、选中态、i18n |
| `lib/l10n/intl_*.arb` + `lib/generated/l10n.dart` | 新增 bridge 相关 i18n key |

#### 核心改动

- **路由对比**：`_routeCards()` 横向 PageView，展示 Uniswap / Li.Fi / 1inch 三路由的 amountOut / gas / 预估时间，高亮最优选项
- **状态轮询**：`Timer.periodic(10s)` 对 `pending` 状态桥接历史轮询 `LifiApi().getStatus(txHash)`；`_completedTxHashes Set<String>` 防重入
- **本地通知**：`FlutterLocalNotificationsPlugin` 在状态变为 `DONE`/`FAILED` 时弹出通知
- **历史持久化**：`SharedPreferences` key `bridge_history`，JSON 数组存储，页面销毁前写盘
- **路由优化展示**：每条路由卡显示 Provider Logo / 金额差额 / gas 费 / 时间，`_bestRouteIndex` 自动定位最优

---

### 模块二：ETH/SOL/ATOM 多链质押 `0a44206`

#### 改动文件

| 文件 | 说明 |
|------|------|
| `lib/src/staking/pages/staking_home_page.dart` | 实时 APY 并行加载，协议卡/持仓卡动态显示 |
| `lib/src/staking/pages/stake_page.dart` | ETH 解质押 → DEX，SOL/ATOM 真实解质押流程 |
| `lib/src/staking/pages/validator_list_page.dart` | AppBar / 搜索 / 排序 / 空状态全量 i18n |
| `lib/l10n/intl_*.arb` + `lib/generated/l10n.dart` | 新增 19 个 staking i18n key |

#### 核心改动

**实时 APY 加载**（`staking_home_page.dart`）：

```dart
// Future.wait 并发三链 API，setState 后协议卡 / 持仓卡均使用 live 数据
await Future.wait([
  EthStakingApi().getLidoApy(),      // https://eth-api.lido.fi/v1/protocol/steth/apr/sma
  SolStakingApi().getEstimatedApy(), // getInflationRate JSON-RPC
  AtomStakingApi().getInflationAndApy(), // Cosmos REST API
]);
```

加载期间显示 `CircularProgressIndicator`，失败后静默降级至静态值。

**解质押流程**（`stake_page.dart`）：

| 链 | 流程 |
|----|------|
| ETH Lido | 液态代币 stETH → 跳转 `DexSwapHome` 直接 swap，无锁定期 |
| SOL | 选择持仓 → 全额注销 stake account（`buildUnstakeTransaction(position:)`） |
| ATOM | 选择持仓 → 输入金额（支持 25/50/75/MAX 快捷按钮）→ 部分解委托 |

**异步安全**：`ScaffoldMessenger.of(context)` 在 `await` 前捕获到局部变量，消除 `use_build_context_synchronously` 警告。

**测试**：`flutter test test/features/staking/` → `+22: All tests passed!`

---

### 模块三：BTC 自托管质押 `c7f1d61`

#### 背景

- `self_custody.dart`：原本是有 TextField 但按钮无回调的空壳
- `self_custody1.dart` / `redeem.dart`：直接返回裸 `WebViewWidget`，无 AppBar / 无提示
- `redeem.dart`：`byteFee: 1` 硬编码，锁定期到期无任何检查或提示

#### 改动文件

| 文件 | 说明 |
|------|------|
| `lib/src/wallet/pages/Staking_btc/self_custody.dart` | 全面改写为流程介绍 + 风险提示入口页 |
| `lib/src/wallet/pages/Staking_btc/self_custody1.dart` | 换用 `AppBarWidget`，加可关闭风险横幅 |
| `lib/src/wallet/pages/Staking_btc/redeem.dart` | 换用 `AppBarWidget`，加锁定状态横幅，`byteFee` 动态化 |
| `lib/l10n/intl_*.arb` + `lib/generated/l10n.dart` | 新增 26 个 btc_stake / btc_redeem i18n key |

#### `self_custody.dart` 改写详情

页面结构：
```
AppBarWidget("BTC Self-Custody Staking")
├── CoinHeader：图标 + 名称 + 余额
├── HowItWorks：4 步流程（带图标、连接线）
│   ① 锁定 BTC（橙色，lock icon）
│   ② 铸造 vBTC（紫色，token icon）
│   ③ 获取奖励（绿色，star icon）
│   ④ 到期赎回（蓝色，lock_open icon）
├── RiskWarning：橙色边框卡，4 条风险说明
│   • CLTV 锁定不可撤销
│   • OP_CHECKLOCKTIMEVERIFY 无法绕过
│   • 智能合约风险
│   • 最低 0.001 BTC / 0.125 天
└── Acknowledgment：勾选框（AnimatedContainer 过渡）
    └── "Continue to Stake" 按钮（未勾选时视觉置灰 + 点击无效）
```

#### 赎回状态横幅（`redeem.dart`）

WebView 发送 `redeem` 消息时捕获 `lock_time`（Unix 秒），横幅三态：

| 状态 | 颜色 | 内容 |
|------|------|------|
| 尚未触发赎回 | 橙色 | 通用提醒 |
| `lock_time > now` | 红色 | "BTC still locked · Locked until YYYY-MM-DD HH:mm" |
| `lock_time ≤ now` | 绿色 | "Unlocked — ready to redeem" |

#### byteFee 修复

```dart
// 修改前
"byteFee": 1,

// 修改后
"byteFee": gasFeeRate, // 动态 gas 费率（已从 API getGasFeeBtc() 获取）
```

#### 分析结果

```
flutter analyze lib/src/wallet/pages/Staking_btc/
→ No issues found!

flutter test test/features/staking/
→ +22: All tests passed!
```

---

## [2026-02-20] 代币置顶：用户常用代币钉在列表顶部

### 背景

主页代币列表仅有资产价值/名称两种排序，缺乏「用户偏好」维度：
用户常用的小市值代币（如某 DeFi 代币）总被价值排序压到列表底部，每次都需要滚动查找。

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/src/wallet/models/wallet_info.dart` | 修改 | 添加 `pinnedCoins: List<String>` 字段 + fromJson/toJson |
| `lib/src/wallet/models/coin_model.dart` | 修改 | 添加 `bool isPinned = false` 运行时标记 |
| `lib/src/wallet/provider/wallet_action_provider.dart` | 修改 | 添加置顶核心逻辑 |
| `lib/src/wallet/pages/wallet_page.dart` | 修改 | 图钉 UI + 分隔行 |

### 功能详情

#### 1. 数据模型

**标识键规则**（`_coinPinKey()`）：
- 主链币：`coinType`（如 `"ETH"`）
- 合约代币：`coinType_miniName`（如 `"ETH_USDT"`），避免主链与代币碰撞

**存储**：`WalletInfo.pinnedCoins: List<String>`，随钱包数据序列化到 SecurePreferences，**按钱包独立管理**。

**运行时标记**：`CoinModel.isPinned: bool`（不序列化），在 coinList 构建完成后由 `_syncPinnedState()` 从 `walletInfo.pinnedCoins` 同步。

#### 2. 排序优先级

```
置顶代币（用户手动）
  > 优先级链（N / BTC / ETH / USDT / USDC，仅无自定义排序时）
  > 用户排序（资产价值 / 名称 A-Z）
```

核心方法：
- `_syncPinnedState()` — coinList 构建后调用，同步 `isPinned` 字段
- `_elevatePinnedToTop()` — 稳定地将置顶代币移到列表前端（保持组内顺序）
- `coinSortAssets()` 末尾自动调用 `_elevatePinnedToTop()`，无需每个排序路径单独处理

#### 3. 切换置顶

```dart
void togglePinCoin(CoinModel cm) {
  // 聚合代币（isAggregated）不允许置顶
  // 更新 walletInfo.pinnedCoins + cm.isPinned
  // 重新排序 → _elevatePinnedToTop → saveCoinSort → notifyListeners
}
```

#### 4. UI

**图钉按钮**（每个代币行右侧）：
- 未置顶：`push_pin_outlined`，35% 透明灰色
- 已置顶：`push_pin`，蓝色（`mainBlueColor`）
- 聚合代币（USDT/USDC 聚合）不显示图钉按钮
- 触控区独立于代币行 onTap（`HitTestBehavior.opaque`），不会触发跳转

**名称行角标**（已置顶时）：蓝色小图钉显示在 symbol 左侧，`22sp`

**分隔行**（置顶与普通代币之间）：两侧分隔线 + 中间 "Other assets" 灰色标签，仅在混合列表时显示。

### 技术备注

- `isPinned` 不写入 `CoinModel.toJson()`，避免污染链配置数据
- `_syncPinnedState()` 在两处 coinList 初始化路径（initWallet / refreshWallet）均有调用，确保重启后状态正确还原
- `_elevatePinnedToTop()` 使用稳定分区（preserve relative order within pinned group）

---

## [2026-02-20] 资产搜索优化：相关性排序 + 搜索历史记录

### 背景

`WalletSearchCoin` 组件（转账/收币选币弹窗）存在三个问题：
1. 搜索结果按 coinList 原始顺序返回，无相关性排序——输入"ETH"时 ETHW/ETHEREUM 可能排在 ETH 前面
2. 无搜索历史——关闭弹窗后关键词丢失，每次重新输入
3. `address.substring()` 未做长度守卫，短地址（< 12 字符）会 `RangeError` 崩溃

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/core/storage/sp_util.dart` | 修改 | 新增 `coinSearchHistory` SPkey + `getCoinSearchHistory()` / `saveCoinSearchHistory()` |
| `lib/src/wallet/widgets/wallet_search_coin.dart` | 重写 | 相关性排序 + 历史记录 + 实时搜索 + 清除按钮 + 地址安全截断 |

### 功能详情

#### 1. 相关性排序

搜索结果按以下权重降序排列，同权时按持仓 USD 价值降序：

| 权重 | 条件 |
|------|------|
| 5 | symbol 完全相同（如 "eth" → ETH）|
| 4 | symbol 前缀匹配（如 "eth" → ETHW）|
| 3 | name 前缀匹配 |
| 2 | symbol 包含关键词 |
| 1 | name 包含关键词 |

```dart
int _rankScore(CoinModel cm, String input) {
  final sym = cm.coin['miniName'].toString().toLowerCase();
  final name = cm.coin['name'].toString().toLowerCase();
  if (sym == input) return 5;
  if (sym.startsWith(input)) return 4;
  if (name.startsWith(input)) return 3;
  if (sym.contains(input)) return 2;
  return 1;
}
```

#### 2. 搜索历史

- 存储：`SharedPreferences`，JSON 字符串数组，key = `coinSearchHistory`
- 容量：最近 10 条，同关键词自动去重后置顶
- **保存时机**：键盘 submit（`onSubmitted`）或点击代币进入下一页时
- **UI**：搜索框为空时在代币列表上方展示 Wrap 形式的 chip 行
  - 点击 chip → 填充搜索框并立即执行搜索
  - chip 右侧 ✕ → 删除单条历史
  - "Clear All" 按钮 → 清空全部历史

#### 3. 实时搜索（300 ms 防抖）

`onChanged` 触发，防抖 300ms 后执行搜索，无需点击搜索按钮。搜索框为空时防抖取消并立即清空结果列表。

#### 4. 搜索框 UX

- 左侧搜索图标（不可点击）
- 有文字时右侧显示 ✕ 清除按钮（替代"Search"按钮）；无文字时显示"Search"触发按钮（保留原有显式搜索入口）

#### 5. 地址截断安全修复

```dart
String _formatAddress(dynamic address) {
  if (address == null) return '';
  final s = address.toString();
  if (s.length < 12) return s; // 短地址直接显示，不截断
  return '${s.substring(0, 6)}...${s.substring(s.length - 5)}';
}
```

### 技术备注

- `Timer? _debounce` 在 `dispose()` 中取消，无内存泄漏
- `FocusNode` 在 `dispose()` 中释放
- `_searchResults` 始终为独立 List，不修改 `waValue.coinList` 原始数据
- 历史 chip 的 ✕ 使用 `HitTestBehavior.opaque` 防止点击事件穿透到外层 chip GestureDetector
- `g_key_batch_clear_all`（"Clear All"）复用现有 l10n key；"Recent" 暂为英文内联（TODO: 添加 `g_key_coin_search_recent` l10n key）

---

## [2026-02-20] 法币价格与总资产展示优化

### 背景

主页资产面板存在三个问题：
1. CNY 折算汇率硬编码为 7.3，不随市场波动更新
2. 价格完全依赖手动刷新，页面停留期间数据可能过时数分钟
3. 总资产数字（40sp，无加粗）在主页视觉层级不突出

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/src/wallet/provider/wallet_action_provider.dart` | 修改 | 动态 CNY 汇率 + 30 s 去重 + priceLastUpdated |
| `lib/src/wallet/widgets/wallet_board.dart` | 修改 | 接收动态汇率 + 显示更新时间 + 突出总资产 |
| `lib/src/wallet/pages/wallet_page.dart` | 修改 | 60 s 自动刷新 Timer |

### 功能详情

#### 1. 动态 USD→CNY 汇率（wallet_action_provider.dart）

**原理**：CoinGecko `simple/price` 接口已支持 `vs_currencies=usd,cny`，通过 USDT 的 CNY 报价与 USD 报价之比推算汇率（USDT ≈ $1，精度满足需求）。

**实现**：
- `_fetchStablecoinPrices()` URL 追加 `,cny` → 解析 USDT 的 `cny` 字段
- 汇率有效性校验：仅在 `[5.0, 12.0]` 范围内更新 `_usdToCnyRate`，防止异常值
- 对外暴露 `double get usdToCnyRate` 与 `DateTime? get priceLastUpdated`

**新增字段**：
```dart
double _usdToCnyRate = 7.3;           // 动态汇率，初始值为备用常量
DateTime? _priceLastUpdated;          // 最后一次成功价格刷新时间
DateTime? _coinMarketInfoFetchTime;   // 市场数据请求时间戳（去重用）
static const Duration _marketInfoMinInterval = Duration(seconds: 30);
```

#### 2. 市场数据 30 s 去重（wallet_action_provider.dart）

`getCoinInfo()` 增加 30 秒最小间隔守卫：
- Timer 触发与手动下拉刷新同时发生时，第二次请求被跳过
- 有缓存时网络失败不弹 Toast（静默降级），无缓存时才提示用户

#### 3. 60 s 自动刷新（wallet_page.dart）

```dart
Timer.periodic(const Duration(seconds: 60), (_) {
  if (!mounted) return;
  ref.read(wapBridgeProvider).refreshWalletCoinInfo(refresh: false);
});
```
- `refresh: false` 避免触发 loading 状态，用户无感知后台刷新
- Timer 在 `dispose()` 中取消，无内存泄漏

#### 4. 总资产展示突出（wallet_board.dart）

- USD 字号：40sp → **44sp**，`fontWeight: FontWeight.bold`
- CNY 副标题保留，汇率来自父组件动态传入（`usdToCnyRate` 参数）
- 更新时间标签（右侧细灰字）：`Just updated` / `Updated Xm ago` / `Updated Xh ago`

### 技术备注

- 汇率来源为 CoinGecko USDT CNY 报价，无需额外 FX API 调用，与现有稳定币价格请求合并（零额外网络开销）
- `_priceLastUpdated` 在每次 `getCoinInfo()` 完成后（无论是否发起网络请求）更新，使"更新时间"反映用户感知到的实际数据时刻
- `withValues(alpha: 0.5)` 替换废弃的 `withOpacity(0.5)`，适配 Flutter 3.x 精度要求

---

## [2026-02-20] 多链交易历史补齐：SOL / DOT / APT / TON

### 背景

各链功能深度不均：SOL 历史记录代码已注释、DOT / APT / TON 完全缺失历史记录获取逻辑。

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/src/wallet/api/transaction_api.dart` | 修改 | 添加 `dotTransactionList` / `aptTransactionList` / `tonTransactionList` 三个方法 |
| `lib/src/wallet/pages/wallet_chain_info.dart` | 修改 | 恢复 `getTransactionDataNetworkSol()`；新增通用处理器 `getTransactionDataNetworkGeneric()`；调度器中启用 SOL / DOT / APT / TON |

### 功能详情

#### 1. Solana 历史恢复

- 原因：注释掉的代码使用了错误的字段名（ETH 格式 `cri.hash / cri.from` 等），`SOLTransactionItem` 实际字段为 `txHash / src / dst / lamport / blockTime / fee / status`
- 恢复后字段映射：`price = lamport`、`gasPrice = fee`、`txTime = blockTime`（Unix 秒）、`state = (status == 'Success') ? 1 : 0`
- 双参 `db.selectTransationRecordTxHash(hash, address)` 匹配当前 DB API

#### 2. Polkadot（DOT / KSM / ACA）

- **API**：Subscan v2 `POST {api}api/v2/scan/transfers`，需要 `x-api-key: ApiKeysConfig.dotApiKey`
- **金额转换**：Subscan 返回人类可读字符串（"1.5000000000"），`_parseToSmallestUnit()` 静态方法转为 planck（DOT 10位、KSM/ACA 12位）
- 返回 `List<CommonResponseItemModel>`，由通用处理器落库

#### 3. Aptos（APT）

- **API**：Aptos REST `GET {rpc}accounts/{addr}/transactions?limit=25`
- 只处理 `type == 'user_transaction'`，跳过区块元数据
- 收款方从 `payload.arguments[0]` 提取，金额从 `payload.arguments[1]` 提取（octas，10^8 per APT）
- 时间戳为微秒，`÷ 1,000,000` 转为 Unix 秒
- 手续费 = `gas_used × gas_unit_price`（octas）

#### 4. TON（TON Center v2）

- **API**：`GET {rpc}getTransactions?address={addr}&limit=20`
- 转账来源 `in_msg.source`，接收方 `in_msg.destination`，金额 `in_msg.value`（nanoTON）
- `utime` 已是 Unix 秒，无需转换
- 已上链即视为成功（`txreceiptStatus = "1"`）

#### 5. 通用处理器 `getTransactionDataNetworkGeneric()`

- 适用于所有返回 `List<CommonResponseItemModel>` 的链（DOT / APT / TON）
- 与 ETH 处理器逻辑一致，增加 `?? 0` 安全默认值处理 `coinId` 可能为 null 的情况
- 不做 hex input 解码（非 EVM 链无此字段）

### 技术备注

- `_parseToSmallestUnit(String amount, int decimals)` 为静态辅助方法，纯字符串运算，避免浮点精度丢失
- SOL mainnet API URL 当前为空（需付费 Solscan Pro API），testnet 可正常拉取；handler 代码已就绪，接入 API 只需填写 URL 即可
- 调度器中增加对 `BlockchainType.Polkadot / Aptos / TheOpenNetwork` 的分支，保持与 ETH/BTC/TRX/SOL 的统一模式

---

## [2026-02-20] 自定义代币添加：热门代币推荐 + 合约自动校验

### 背景

代币添加页（`WalletCoinAddAll`）现有 Search 和 Custom 两个 Tab。
- Search Tab 直接展示全量代币列表，无热门推荐，首屏辨识度低
- Custom Tab 手动输入合约地址后，symbol 和 decimals 仍需完全手动填写，体验差且容易出错

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/src/wallet/api/chain_api/eth_api.dart` | 修改 | 添加 `getErc20TokenInfo()` 静态方法 |
| `lib/src/wallet/pages/add_token/wallet_coin_add_all.dart` | 修改 | 热门代币推荐区 + 合约自动校验 |

### 功能详情

#### 1. 热门代币推荐列表（Search Tab）

**触发条件**：搜索框为空且未选择网络过滤时，在全量列表上方展示推荐区。

**白名单**（13 个）：USDT、USDC、DAI、WBTC、WETH、UNI、LINK、AAVE、SHIB、PEPE、ARB、OP、MATIC

**数据来源**：从 `getChainListAll()` 返回的 `coinlist` 中过滤（不额外 API 请求），同 symbol 按链去重。

**卡片 UI**：圆角 chip，左侧 icon + symbol/chain 文字，右侧：
- 未添加：蓝色 `+` 图标，点击触发 `addCoinToken()`
- 添加中：小 loading 圆圈
- 已添加：蓝色 `✓` 图标，背景染浅蓝色，禁止重复点击

**布局**：横向滚动 ListView，高度 100dp，自适应内容宽度。

#### 2. 合约地址自动校验（Custom Tab）

**触发时机**：用户在合约地址输入框中停止输入 800ms 后自动触发（防抖，避免频繁请求）。

**校验流程（三级）**：
1. **格式校验**：调用 `Trustdart().validateAddress(coinType, address)` 验证地址格式
2. **本地匹配**：在 `coinlist` 中按合约地址查找 → 若命中直接填充 symbol/decimals，避免链上 RPC 调用
3. **链上查询**（仅 EVM 链 `blockchainType == Ethereum`）：调用 `EthAPI.getErc20TokenInfo()` → RPC `eth_call` 读取 `name()`/`symbol()`/`decimals()`

**状态显示**（地址框下方）：
- `loading`：转圈 + "Looking up token info…"
- `found`：✅ 绿色 "Token found: USDT · 6 decimals"（同时自动填充表单）
- `notFound`：⚠️ 橙色 "Token not found in list — fill symbol & decimals manually"
- `error`：不显示额外提示（地址格式错误由 `tokenErrorMessage` 展示）

#### 3. ERC20 链上信息读取（eth_api.dart）

**方法**：`static Future<({String name, String symbol, int decimals})?> getErc20TokenInfo(String contractAddress, String rpcUrl)`

**实现**：并行调用三个 ERC-20 view 函数：
- `name()` → 函数选择器 `0x06fdde03`
- `symbol()` → `0x95d89b41`
- `decimals()` → `0x313ce567`

**ABI 解码**：手动解码 hex 响应（`_abiDecodeString` 处理 dynamic string，`_abiDecodeUint8` 处理 uint8），无需引入额外的 ABI JSON 文件。

**容错**：任一 RPC 调用失败或 symbol/name 均为空时返回 `null`，调用方降级为"手动填写"提示。

### 技术备注

- 合约校验状态通过 `_contractState: String` 枚举管理（`''|loading|found|notFound|error`），采用 `Timer(_contractDebounce)` 防抖，在 `dispose()` 中取消，避免内存泄漏
- 热门代币提取在 `getChainList()` 完成后调用 `_extractPopularTokens()`，复用已有的 API 数据，不引入额外网络请求
- `coinListWidget()` 改为 `CustomScrollView + SliverList` 结构，与 `SliverToBoxAdapter`（热门区）组合，支持整页统一滚动

---

## [2026-02-20] 代币余额显示优化：小额资产隐藏 + 法币折算

### 背景

主页钱包资产面板存在两个体验痛点：
1. 总资产仅展示 USD，对中国用户不直观——缺少人民币参考
2. 小额"粉尘"资产（如 Gas 找零、测试代币）混入列表，干扰核心资产查看

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/core/storage/sp_util.dart` | 修改 | 添加 `hideSmallAssets` SPkey 及 getter/setter |
| `lib/src/wallet/widgets/wallet_board.dart` | 修改 | 总资产显示增加 CNY 折算副标题 + 极值格式化 |
| `lib/src/wallet/pages/wallet_page.dart` | 修改 | 添加小额资产隐藏开关 + 过滤逻辑 |

### 功能详情

#### 1. 小额资产隐藏开关

**阈值**：USD 价值 `< $1.0` 的代币视为小额资产。

**开关位置**：代币列表粘性 header 底部行（排序按钮右侧）。

**交互设计**：
- 关闭（默认）：`👁 < $1` 浅色图标，显示全部资产
- 开启：`👁‍🗨 < $1` 图标高亮蓝底，隐藏小额资产
- 全部资产都是小额时：展示"All assets are below $1 · Tap to show all"提示，避免空列表困惑

**数据流**：
- 状态 `_hideSmallAssets: bool` 存于 `_WalletPageState`
- `initState()` 异步读取 `SPUtil().getHideSmallAssets()` 恢复偏好
- 切换时立即 `setState` + 异步写入 SP，无感知延迟
- 过滤只在渲染层（`coinListWidget1()`）完成，**不修改 `coinList` 本身**，`balanceTotal`（总资产）始终包含全部代币，不受开关影响

#### 2. 总资产 CNY 折算展示

**位置**：`WalletBoard` 组件，USD 大字下方。

**展示规则**：
- USD ≥ $0.01：正常格式 `$1,234.56` + 副标题 `≈ ¥9,013`
- USD 在 (0, $0.01)：显示 `< $0.01`（避免 `$0.00` 误导）
- USD ≥ $1M：缩写 `$1.23M`；≥ $1B：缩写 `$1.23B`
- USD = 0：不显示 CNY 副标题（保持界面整洁）

**汇率**：内置常量 `_usdToCny = 7.3`（参考汇率，仅提供数量级感知，不实时拉取）。
后续可接入汇率 API 替换。

**NumberFormat**：
- USD：`"#,##0.0#"` → 最少 1 位、最多 2 位小数
- CNY：`"#,##0"` → 取整，符合中文金额习惯

### 技术备注

- `AggregatedCoinModel extends CoinModel`，`value` 字段已继承，过滤逻辑对聚合代币（USDT 多链聚合）同样生效
- header 高度 `minHeight/maxHeight = 165.0` 不变，toggle 与排序按钮共用同一行

---

## [2026-02-20] 多钱包管理 UX 改进：分组 + 侧滑 + 一键切换

### 背景

`wallet_list.dart` 功能完整但交互繁琐：切换钱包需要 4-5 步操作，缺少钱包分组视觉。

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/src/wallet/pages/wallet_manage/wallet_list.dart` | 修改 | 重写 `_buildList()` 实现分组、侧滑、快速切换 |

### 功能详情

- **钱包分组**：HD 钱包（hasMnemonic=true）与单链导入钱包两组，带 section 标题
- **一键切换**：点击非活跃钱包直接调用 `setMainWallet(index)`，无需密码
- **活跃状态标识**：蓝色边框 + `check_circle` 图标；其他为灰色空心圆
- **侧滑操作**：`flutter_slidable` 左滑弹出 Edit + Delete
- **`_IndexedWallet` 辅助类**：分组后保留原始索引，确保 `setMainWallet` 和 `jumpWalletInfoPage` 参数正确

---

## [2026-02-20] 钱包云端备份导入/导出

### 背景

现有导入方式（助记词/私钥/Keystore）缺少加密备份文件的支持，无法利用 iCloud/Google Drive。

### 改动文件

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/src/wallet/utils/wallet_backup_crypto.dart` | 新建 | AES-256-CBC + PBKDF2-SHA256 加解密工具 |
| `lib/src/wallet/pages/create_wallet/import/import_cloud_backup.dart` | 新建 | 云备份导入页面 |
| `lib/src/wallet/pages/wallet_backup/export_cloud_backup.dart` | 新建 | 云备份导出页面 |
| `lib/src/wallet/widgets/create_wallet_button.dart` | 修改 | 添加 "Cloud Backup" 入口 |
| `lib/main.dart` | 修改 | 注册 `/ImportCloudBackup` 路由 |

### 安全设计

- 加密：AES-256-CBC，密钥由 PBKDF2-SHA256（60 万次迭代）衍生
- 完整性：HMAC-SHA256 校验，防止篡改
- 密码不存储，解密时实时衍生
- 仅导出恢复所需最小字段（walletName/mnemonic/privateKey/timestamp）

---

## [2026-02-19] iOS 视频播放修复

### 背景

接收到的视频在 iOS 上无法播放，Android 正常。

### 根因

iOS AVFoundation 在 HTTP 302 重定向时会丢弃 `Authorization: Bearer` 头，而 Matrix 媒体 API 需要此头。

### 修复方案

iOS 分支：使用 `http.Client().send()` 带认证头流式下载到临时文件（`getTemporaryDirectory()`），再用 `VideoPlayerController.file()` 播放。Android 保持原 `VideoPlayerController.networkUrl(url, httpHeaders: headers)`。

### 技术备注

属于临时方案。完整解决方案（持久化媒体缓存）记录于 `docs/research/media_storage_strategy.md`。

---
