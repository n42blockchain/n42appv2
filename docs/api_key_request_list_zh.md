# API Key 申请清单（中文简版）

最后更新：2026-03-18

用途：可直接转发给后端 / 运维 / 商务同事。  
范围：仅包含当前 `P0` 和 `P1` 项，每项只保留一句说明和官方申请链接。

## P0

| Key | 建议负责方 | 一句话说明 | 官方申请 / 文档链接 |
| --- | --- | --- | --- |
| `MOONPAY_SECRET_KEY` | 商务 / 支付 / 后端 | 用于 MoonPay 买币签名，必须放服务端，客户端不能持有。 | https://dev.moonpay.com/docs/on-ramp-enhance-security-using-signed-urls |
| `TON_API_KEY_MAINNET` | 后端 / 运维 | 用于 TON Center 主网接口，当前钱包 TON 代理链路依赖它。 | https://toncenter.com/ |
| `SONICSCAN_API_KEY` | 后端 / 运维 | 用于 Sonic 浏览器查询，当前 Sonic 交易历史代理链路依赖它。 | https://docs.sonicscan.org/ |
| `BUNDLER_API_KEY` | 钱包后端 / AA 负责人 | 用于 ERC-4337 Bundler，当前应只放 `n42-api-proxy`，不再下发到 App。 | https://docs.pimlico.io/ |

## P1

| Key | 建议负责方 | 一句话说明 | 官方申请 / 文档链接 |
| --- | --- | --- | --- |
| `AI_API_KEY` | 产品 / 后端 / AI 负责人 | 用于 Chat AI 能力，当前策略是 App 直连，不走 proxy。 | https://console.groq.com/docs/quickstart |
| `GOOGLE_TRANSLATE_API_KEY` | 运维 / Google Cloud 管理员 | 用于 Google 翻译，需在 Google Cloud 开项目、开通 Translation API 并创建 API Key。 | https://docs.cloud.google.com/translate/docs/setup |
| `GOOGLE_SPEECH_API_KEY` | 运维 / Google Cloud 管理员 | 用于 Google Speech，需在 Google Cloud 开项目、开通 Speech-to-Text 并创建 API Key。 | https://docs.cloud.google.com/speech-to-text/docs |
| `AZURE_SPEECH_API_KEY` | 运维 / Azure 管理员 | 用于 Azure Speech，创建 Speech 资源后获取 key。 | https://learn.microsoft.com/en-us/azure/ai-services/speech-service/get-started-speech-to-text |
| `AZURE_SPEECH_REGION` | 运维 / Azure 管理员 | 与 `AZURE_SPEECH_API_KEY` 同时获取，创建 Azure Speech 资源时一并记录 region。 | https://learn.microsoft.com/en-us/azure/ai-services/speech-service/get-started-speech-to-text |
| `GIPHY_API_KEY` | 产品 / 运营 / 开发 | 用于 GIF 搜索与趋势内容，当前策略是 App 直连。 | https://developers.giphy.com/docs/api |
| `DEBANK_API_KEY` | 产品 / 钱包后端 | 用于 DeBank 资产与地址画像能力，当前策略是 App 直连。 | https://docs.cloud.debank.com/en/readme/open-api |
| `ALCHEMY_API_KEY` | 钱包 / Web3 / 运维 | 用于 Alchemy 相关链上与社交图谱能力，当前策略是 App 直连。 | https://www.alchemy.com/docs/create-an-api-key |

## 备注

- 当前 `P0` 只需要补到 [../n42-api-proxy/.env](/Users/jieliu/Documents/n42/n42-api-proxy/.env)。
- `BUNDLER_API_KEY` 现在是 `proxy-only`，不需要再填到 App `.env`。
- `GOOGLE_TRANSLATE_API_KEY` 与 `GOOGLE_SPEECH_API_KEY` 都在 Google Cloud 体系内申请，但需要分别确认对应 API 已启用。
- `AZURE_SPEECH_API_KEY` 和 `AZURE_SPEECH_REGION` 是同一个 Azure Speech 资源配套产物。
