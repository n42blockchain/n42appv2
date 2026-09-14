# 邮箱验证修复候选 — 2026-09-14

后续发布记录：本报告所述修复已于 2026-09-14 随 Chat [ebaa003](https://github.com/n42blockchain/n42_chat/commit/ebaa003b3dd882be9f951cb73c88633fa618f76c) 提交并推送；钱包随后已完成[依赖集成](WALLET_INTEGRATION_2026-09-14.md)。以下保留验证当时的状态与证据。

状态：正式 Chat 工作树已实现并验证的本地候选，尚未提交、发布或更新钱包 Git pin。包含上一轮收藏修复；当前钱包仍使用 `c1d222e3ea9c49a5f8bc51444154eb4026d689ef`，本报告不替换第五轮已交付基线。

## 修复内容

原流程收集验证码和当前密码，却直接使用存储的 secret/sid 调用 add3PID，既不提交验证码，也不核对请求邮箱。第二次请求失败时，还会留下新邮箱、新 secret 与旧 sid 混合的记录。两项真实仓库回归已在旧实现上复现失败。

新增 `EmailChangeService`，由 AuthRepository 委托调用：

- 用一个版本记录保存 secret、sid、目标邮箱、账号、服务器、设备、发送次数和本地到期时间；成功收到完整响应后才写入。旧的、缺少账号归属的分散记录要求重新发起请求。
- 相同邮箱会话重发复用 secret 并递增 sendAttempt。请求或写入失败保留完整旧记录；确认前检查邮箱、身份与到期时间，网络等待期间再次检查账号是否变化。
- 有 submit_url 时，原样提交验证码，不加 Matrix 登录凭据、不跟随重定向；要求 HTTPS 和明确成功响应，然后才调用 add3PID。没有 submit_url 时，页面显示邮件链接验证说明，确认事件传空验证码。这对应 [Matrix 邮箱验证会话协议](https://spec.matrix.org/v1.15/client-server-api/#post_matrixclientv3account3pidemailrequesttoken) 与 [提交验证令牌协议](https://spec.matrix.org/v1.15/identity-service-api/#post_matrixidentityv2validateemailsubmittoken)。
- 服务器要求仅剩密码步骤的 UIA 时，使用确认事件传入的密码和服务器会话完成认证；密码不保存在验证服务或持久化记录里。其他认证步骤继续报错，不能据此声称已支持 SSO 或任意 UIA 流程。[Matrix add3PID / UIA](https://spec.matrix.org/v1.14/client-server-api/#post_matrixclientv3account3pidadd)
- 页面区分验证码与邮件链接模式，支持带加号和长域名的邮箱，防止键盘或按钮重复提交，解析本地化错误键，并及时替换旧提示。重新发送按钮在大字号下限制宽度，避免溢出。

新增三条提示覆盖 26 个 ARB 语言资源；本地化 Dart 输出由 `flutter gen-l10n` 重新生成。

## 验证

新增 **55 项**行为回归：验证服务 45、仓库 2、真实 Bloc 模式传播 1、页面交互/布局 7。

| 范围 | 结果 |
|---|---|
| 插件定向回归 | 272 项通过 |
| 插件完整回归 | 6394 项通过，1 项在线凭据测试跳过 |
| 插件静态分析 | 0 错误、0 警告，173 条既有 info |
| 钱包候选兼容检查 | 481 项通过，包含收藏与邮箱候选 |
| 原始全量行覆盖率 | 29040/131535（22.08%），包含生成代码，CI 门槛未改 |

宿主测试使用临时 package config 指向正式候选源码，并补入插件测试所需的 bloc_test/diff_match_patch；其他宿主运行时依赖版本保持原解析结果。测试结束后临时入口和配置已删除，正式 Git pin、锁文件和缓存镜像未被替换。此测试不能作为“钱包已发布修复”的证据。

三个页面截图均为 320×720、1.6 倍文字，使用系统字体渲染并已检查：

- [英文](email-verification-2026-09-14/email-link-en.png)
- [中文](email-verification-2026-09-14/email-link-zh.png)
- [阿拉伯语](email-verification-2026-09-14/email-link-ar.png)

这是 Widget 渲染证据，不是真机收邮件、点击链接或绑定账号的验收。

完整命令和源码/证据哈希见 [机器统计](email-verification-2026-09-14/summary.json)；[旧实现失败证据](email-verification-2026-09-14/before.log.gz)、[定向日志](email-verification-2026-09-14/targeted.log.gz)、[完整日志](email-verification-2026-09-14/full-tests.log.gz)、[完整覆盖率](email-verification-2026-09-14/final.lcov.gz)、[静态检查](email-verification-2026-09-14/analyze.log.gz)、[宿主候选日志](email-verification-2026-09-14/host.log.gz) 均独立归档。完整插件测试进程使用 `ulimit -n 4096`。

## 仍开放的范围

正式 Chat `OPEN_ISSUES.md` 的 AUTH-001 保持开放，但已更新为客户端修复完成、等待发布与真实服务验收：

- 尚未测试真实邮件送达、目标 homeserver 的验证码/链接行为和线上过期策略；本地一小时到期限制不代表服务器保证。
- 目前 add3PID 添加已验证地址，不会原子替换旧恢复邮箱；多邮箱时 getBoundEmail 仍取服务器返回的第一项。后续需要明确的多邮箱管理/主邮箱规则，不能悄悄删除恢复地址。
- 服务器已绑定成功后，如果本地清理失败，界面仍报告服务器成功；安全存储中可能保留会话记录。此行为已有故障回归，但未建立服务器与本地存储之间的事务。
- SSO 和多步骤 UIA 仍需专门入口与验收；本地候选尚未发布和集成进钱包正式依赖。

本轮没有发送真实邮件、修改真实账号、安装手机应用或清理设备数据。
