# 竞品对比更新（2026-10-04）

本页补充 Chat 对比（原研究日期 2026-09-12）和钱包对比（原研究日期 2026-07-14）。保留旧报告正文和历史判断。以下只记录本次从官方资料核实的变化，并说明对 N42 当前功能入口和能力判断的影响。

## Chat 产品

| 官方更新 | 对比结论 |
|---|---|
| Telegram 于 2026-08-25 发布群/频道欢迎消息，以及可放在消息正文里的交互按钮和临时消息流程。[Telegram 官方更新](https://www.telegram.org/blog/welcome-messages-buttons-TG-13) | N42 当前审计确认频道发现、群聊和欢迎语相关代码入口，但没有核实到等价的“新成员专属欢迎消息 + 消息内多按钮/临时流程”生产闭环。不能把普通欢迎语或消息菜单算作等价功能。 |
| WhatsApp 于 2026-07-28 公布 Web 端音视频通话、设备间转移通话、群组等候室、即时 HD 和降噪。[WhatsApp 官方更新](https://about.fb.com/news/2026/07/whatsapp-web-calling-new-features/) | 这些是浏览器/多设备通话能力。N42 的通话入口和 Matrix/LiveKit 接入须单独按平台、信令及真机测试验收；不能仅凭 SDK 集成等同于 Web 通话、设备接力或等候室。 |
| WhatsApp 于 2026-08-25 公布更强的两步验证密码、陌生来电上下文和同一账号多个 Passkey。[WhatsApp 官方更新](https://about.fb.com/news/2026/08/new-account-security-features-for-whatsapp/) | N42 有账号安全和设备管理入口，但本轮没有逐项核实这些 WhatsApp 机制的等价实现。 |

## 钱包产品

| 官方更新 | 对比结论 |
|---|---|
| MetaMask 于 2026-09-17 发布 Added Protection：在支持的 EVM 网络上把模拟预览结果写为交易执行条件；实际结果不符时交易回滚。官方称当时已在支持智能账户的 13 个 EVM 网络的扩展端上线，移动端后续推出。[MetaMask 官方公告](https://metamask.io/news/added-protection-prevents-red-pill-attacks) | N42 当前有钓鱼检测和签名前风险提示，但未核实到强制执行结果与模拟预览一致的链上保护。风险提示不等于 Added Protection。 |
| Trust Wallet 的预测市场入口可从 Markets 进入，并通过合作方提供链上事件市场。[Trust Wallet 官方说明](https://trustwallet.com/blog/company/introducing-predictions-in-trust-wallet) | N42 永续页当前是只读行情。没有预测市场交易流程，不能按页面代码或市场卡片把该项记作可交易。 |

## 资料口径

厂商公告证明厂商公布了该功能，不证明所有地区、账号或客户端版本均已开放。N42 状态按生产入口、核心逻辑、自动化测试、真机或链上证据分别核对。下一轮完整竞品审查应继续检查各厂商 2026 年后续公告，不应把本次几个官方公告当作全部市场更新。
