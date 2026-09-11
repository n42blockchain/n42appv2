# 深链启动与参数校验补齐（2026-09-11）

接续[聚合稳定币模块](wallet-aggregate-followup-2026-09-11.md)，本批检查应用外部链接的解析、启动交接、导航和销毁路径。修复的是已有 WalletConnect、聊天和 ID Hub 入口的可靠性与参数边界，没有将旧群挖矿／全节点的日志分支标记为功能完成。

## 修复行为

| 问题 | 修复后的行为 |
|---|---|
| 冷启动的链接在 Navigator 或首页未就绪时直接返回 | 路由处理器保留待处理意图；首页首帧就绪或恢复前台时重试；尚未就绪期间只保留最后一个有效意图 |
| 初始链接查询等待期间遗漏实时链接 | 先监听平台流，再等待初始链接；新的实时／手动链接优先于晚返回的旧启动链接 |
| `init()` 重入和销毁后继续交付 | 初始化合并为同一个 Future；销毁时取消流、清空缓存并禁止重启；晚响应不重新导航 |
| 相同链接多次推送导致页面叠加 | 相同 URI 的导航 Future 未结束时合并重复事件；返回后可重新打开 |
| 回调声明为 void，异步异常绕过 try/catch | 导航支持 FutureOr 并等待回调；同步、异步失败均记录异常类型，释放重复事件锁，允许后续重试 |
| `n42://chat/expected?roomId=other` 覆盖路径目标 | 路径目标优先；查询参数不能替换 roomId／userId／groupId |
| 非法字符被删除，生成另一个有效 ID | 对非法目标整项拒绝，不“修复”为其他账户；兼容既有 Matrix 风格 ID 和无 host 的旧路径格式 |
| 重复 query、额外路径和混淆 authority | 拒绝重复参数、控制字符、超长 URI、意外路径层级，以及应用专用路由中的 userInfo／port |
| ID Hub session / hub 值在校验前被改写 | 保留原始值，由已有 UUID 与精确 HTTPS origin 白名单校验；无效 session 不会被删字符后变有效 |
| SSO 存在多个冲突令牌 | 接受既有三种令牌别名；缺失、空白或冲突令牌不进入登录回调 |
| 日志包含登录或配对能力凭据 | 接收与导航只记录类型；toString 对令牌键大小写／下划线变体、重复参数、嵌套 uri、userinfo 和 fragment 脱敏；异常消息不直接写入导航日志 |

宿主 `main.dart` 已实际接入导航就绪判断、首页完成后的恢复和前台恢复钩子；不是只给独立服务新增方法。入口函数返回 `Future<void>`，便于设备测试等待初始化后，在应用首帧前注入待处理链接。

## 模块回归

新增 `deep_links` 模块，覆盖服务、处理器和既有 WalletConnect URI helper，共 3 个源码文件。模块套件 **110 项通过，236/249 行（94.78%）**；服务为 97.18%，处理器为 100%，URI helper 为 77.50%。宿主 `main.dart` 不计入这三个文件的模块百分比，接线另通过设备测试验证。

基线来自上批 **4,013 项完整套件的原始 LCOV**：157/187（83.96%）。旧 JSON 仅保存当时已登记模块的文件明细，因此新增模块前，使用未改写的完整 LCOV 补建了 [本批基线](testing/coverage-before-deep-links-2026-09-11.json)，并核对整体仍为 24,795/122,163、914 文件。基线测试集与本次独立模块测试集不同，不能将 +10.82 个百分点全都归因于新测试。

[模块明细](testing/module-coverage-deep-links-2026-09-11.md)。

```sh
python3 scripts/module_coverage.py test deep_links \
  --baseline docs/testing/coverage-before-deep-links-2026-09-11.json
flutter test --no-pub --coverage --concurrency=2 --reporter expanded
flutter analyze --no-pub --no-fatal-infos
```

回归覆盖：初始／实时／手动输入竞态、五秒超时、错误后恢复、重复初始化、销毁晚响应、目标覆盖、非法目标、令牌冲突、可信／不可信 hub、同步与异步导航异常、待处理意图替换、重新监听、返回后重开，以及真实 Navigator 页面栈。

最终全量 **4,059 项通过，7 分 27 秒**，本批新增 46 项。完整 LCOV 为 **24,874/122,234 行（20.35%）**，上批为 20.30%，仍未达到 70%。全量套件中的深链范围同为 236/249（94.78%）。[全量明细](testing/coverage-deep-links-full-2026-09-11.md)。

全项目静态分析：0 error、0 warning、160 info；本批 5 个 Dart 文件格式检查无改动。脚本单测 8 项通过，入口清单重新生成并通过 `--check`，`git diff --check` 通过。既有首页、聚合资产、交易和安全回归保留在完整套件内。

小米完整导航 **88 秒通过**，iPhone 13 Pro Max 重试 **77 秒通过**，均包含冷启动待处理链接、重复页面拦截、不可信 hub 拦截及上一批首页／聚合资产／侧栏回归。计时不包含构建，两端均排除另行登录的 Chat；行情实际返回部分报价，测试核对对应提示，未将它标为完整行情。

iPhone 首轮已安装并启动进程，但停在原生启动屏，调试端口探测超时，尚未出现用例执行标记。结束该次测试并清理其遗留端口转发后，使用同一份源码重试通过；未修改断言或跳过新增用例。该次连接失败单独保留在[首轮记录](device-test-reports/evidence/2026-09-11-deep-links/ios-first-attempt.json)，不计作通过。

[小米检查标记](device-test-reports/evidence/2026-09-11-deep-links/android-navigation.txt) · [iPhone 重试检查标记](device-test-reports/evidence/2026-09-11-deep-links/ios-navigation.txt)。仅归档固定 `DEVICE_*` 标记和结果，原始日志不进入仓库。

两端最后均使用 `--no-uninstall` 保留数据，覆盖安装并启动 **2.4.8+2026072637 / Profile / lib/main.dart** 普通入口。最终首页截图已检查，紧凑列表、部分行情提示和导航正常；小米原有系统指针叠层、备份提醒保留。没有遗留集成测试入口。

[小米普通版首页](device-test-reports/evidence/2026-09-11-deep-links/android-after.png) · [iPhone 普通版首页](device-test-reports/evidence/2026-09-11-deep-links/ios-after.png) · [结构化验收](device-test-reports/evidence/2026-09-11-deep-links/validation.json) · [最终源码哈希](device-test-reports/evidence/2026-09-11-deep-links/source-sha256.json)。

## 验收边界

设备冷启动用例通过真实 App 的服务、路由处理器和 ID Hub 页面，但输入由测试在首帧前交给服务；不能据此宣称 iOS Associated Domains、Android App Links 验证、操作系统点击链接以及完整 SSO 登录全部验收。

测试只使用固定非真实会话 UUID，打开请求页并返回，不点击签名确认、不完成账号绑定、不广播链上交易。可信 hub 的请求页能打开不等于真实会话授权通过。不可信 origin 在页面打开前被拒绝。

`groupMining` 和 `fullNode` 在主入口中仍是未实现的产品路由，本批仅补空／非法群 ID 校验；群挖矿缺少当前产品对应页面与流程，不能随意跳到聊天群或现有节点详情代替。硬件 signer、授权撤销中心、链上预测及 Sui 真机付款仍保留在[缺口台账](wallet-gap-audit-2026-09-11.md)。
