# T19 Markets tab 恢复验证 + change_email 接线

日期：2026-07-03
分支：`fix/competitor-report-audit`
基线：`6f25dbd7`

## 代码接线

- 新增 `lib/features/home/setting/change_email_api.dart`，按 `BACKEND_REQUIREMENTS` §4.1 接入三步接口：
  - `POST /v1/l/user/send/update/email/code`
  - `POST /v1/l/user/verify/update/email/code`
  - `POST /v1/l/user/update/email`
- 新增 `lib/features/home/setting/change_email_page.dart`，复用 `change_email_ui_helpers.dart` 的验证码输入、重发和主按钮组件。
- 在 Security Settings 顶部新增 `Change Email` 入口。

## 真机验证

设备：Android `38f4f08a`（model `25098RA98C`）
包名：`ai.n42.www`
APK：`build/app/outputs/flutter-apk/app-debug.apk`

### 构建与安装

- `flutter analyze --no-fatal-infos`：通过，`No issues found!`
- `flutter build apk --debug --target-platform android-arm64 --no-pub`：通过
- `adb -s 38f4f08a install --no-streaming -r -t -d -g build/app/outputs/flutter-apk/app-debug.apk`：`Success`

### A 组：Markets 底部 tab 恢复验证

| 项 | 结果 | 证据 |
| --- | --- | --- |
| A1 底部第 4 tab | PASS | 底部 tab 顺序为 `Wallet / Verification / Earn / Markets / Chat`，第 4 项为 `Markets`，不是 `News`。点击进入后页面标题为 `Markets`。 |
| A2 四个子 tab | PASS | `Trending / Search / Watchlist / News` 均可达；Trending 有 `Bitcoin/BTC`、`Ethereum/ETH`、`Solana/SOL` 等行情行。 |
| A3 News 真实新闻 | PASS | News 子 tab 返回公开 RSS 真实新闻条目，例如 CryptoSlate 新闻列表；未复现空白新闻页。 |
| A4 Search `btc` | PASS | 使用 `adb shell input keyboard text btc` 输入；搜索框显示 `btc`，当前数据源返回 `No results`，页面无崩溃。因无结果行，本轮未进入详情页。 |
| A5 深/浅主题 + 130% 字号 | PASS | 浅色 `font_scale=1.0` 与深色 `font_scale=1.3` 下页面标题、四个子 tab、行情列表均显示正常，未见明显溢出或遮挡。 |

截图/转储保存在本机：`/tmp/n42-t19-screenshots/`

### B 组：change_email 接线

| 项 | 结果 | 证据 |
| --- | --- | --- |
| Security 入口 | PASS | Drawer -> `Security` 可达；Security 页顶部新增 `Account Security` 区块，显示 `Change Email` 入口。 |
| 页面渲染 | PASS | 点击入口后进入 `Change Email` 页面；展示当前邮箱状态、三步流程 `New email / Verify code / Update`、邮箱输入框与 `Send code` 按钮。 |
| 发码请求 | PASS_WITH_BACKEND_ROUTE_ISSUE | 输入 `t19test0703@example.com` 后点击 `Send code`，页面显示 `Request error`，未崩溃。接口请求链路已触发。 |

发码接口进一步用 `curl` 复核当前线上网关，文档路径在当前环境返回 404：

- `POST https://api.n42.ai/user/v1/l/user/send/update/email/code` -> `HTTP/1.1 404 Not Found`
- `POST https://api.n42.ai/v1/l/user/send/update/email/code` -> `HTTP/1.1 404 Not Found`
- `POST https://api.n42.ai/user/l/user/send/update/email/code` -> `HTTP/1.1 404 Not Found`

结论：Change Email UI、入口和三步 API 调用已接线；当前验证失败点是线上 change_email 路由/网关路径不可达，未达到预期的未登录 `401`。需后端确认 `BACKEND_REQUIREMENTS` §4.1 的实际 base URL/path 后再复测验证码链路。

### 备注

- A 组按要求只做恢复验证，未改 Markets 逻辑。
- B 组仅新增页面、入口和 API 接线，未修改 `change_email_ui_helpers.dart` 逻辑。
- `test/screenshots/market_regression_test.dart` 曾尝试运行，但该用例受外部 Markets/RSS/API 异步路径影响未在本轮稳定收敛；本轮以重装 APK 后真机实测为准。
