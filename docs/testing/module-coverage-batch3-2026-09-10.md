# 分模块补覆盖率：第三批（2026-09-10）

在[第二批](module-coverage-batch2-2026-09-10.md)之后持续推进核心安全及验证码绑定 UI。本批基线为 **3,770 项完整测试通过、全项目行覆盖率 18.40%**，详见[基线快照](coverage-baseline-batch3-2026-09-10.json)。

## 验收结果

完整结果见[第三批覆盖率明细](module-coverage-batch3-details-2026-09-10.md)。

| 范围 | 本批前 | 本批后 | 已覆盖 / 可执行行 |
|---|---:|---:|---:|
| 核心安全（18 文件） | 76.35% | 88.36% | 1,093 / 1,237 |
| 安全设置（4 文件） | 30.78% | 38.01% | 195 / 513 |
| 全项目（含生成代码） | 18.40% | 18.59% | 22,600 / 121,580 |

重点子范围：TOTP **100%**、钓鱼警告 **100%**、验证码绑定页 **100%**、GoPlus 客户端 **89.58%**。子范围已经包含在模块整体中，不重复相加；行覆盖不代表全部分支或真机安全能力已验收。

- 完整 Flutter 回归：**3,814 项全部通过**，用时 **5 分 50 秒**，较本批基线新增 **44 项**；第二、三批累计新增 **103 项**。
- 独立模块：security **221 项**、security_setup **5 项**全部通过；独立 trace 分别为 **88.20%** 和 **23.20%**。上表使用完整测试集，包括既有其他测试对手势页等文件的执行。
- `flutter analyze --no-pub --no-fatal-infos`：**0 error、0 warning、139 条既有 info**，无新增诊断。
- 本批 9 个 Dart 文件格式检查、4 项 Python 统计测试、入口清单一致性和 `git diff --check` 通过。
- 4 张警告截图已逐张检查。第二批 DEX **72.56%**、Bridge **45.76%**、WalletConnect **18.73%** 均保持不变。
- 未运行真实设备、系统认证器、GoPlus 线上服务或钱包链上签名。全项目仍未达到原 70% 门槛。

## 测试范围与发现

新增 44 项 Flutter 用例：TOTP 15 项、GoPlus 客户端 14 项、钓鱼警告 6 项、验证码绑定页 5 项、深浅色/大字体截图 4 项。

### TOTP 验证与二维码参数

使用 RFC 6238 附录 B 的 SHA-1 测试向量，按本项目六位输出取模，覆盖六个标准时间点，包含前导零及 2038 年之后的时间。[RFC 6238](https://www.rfc-editor.org/rfc/rfc6238.html#appendix-B)

- 验证 30 秒边界、当前/前后一个时间窗口、拒绝窗口外验证码、Unix epoch、负时间、默认时钟和随机密钥格式。
- 修复 Base32 解码器静默跳过非法字符的问题。空密钥、非 ASCII 字符、密钥内的标点、空白、错误长度、错误 padding 和非零 padding bits 均不能被当作有效密钥；验证函数返回 false。
- 保留大小写兼容及正确的有/无 padding 形式；生成仍为 160 位随机密钥、SHA-1、六位码、30 秒周期。未把六位实现描述为支持所有 RFC 算法或八位输出。
- `generate` / `verify` 可传入时间供确定性验证，现有调用默认仍使用当前时间。
- 修复二维码 URI 中 issuer 未编码的问题。issuer 与账户名的中文、斜杠、`?`、`#`、`&` 等字符不会破坏路径或注入查询参数；输出 secret 大写且无 padding。

严格拒绝非法 Base32 字符和检查 padding 参考 [RFC 4648 §3.3–3.5](https://www.rfc-editor.org/rfc/rfc4648.html#section-3.3)；URI 标签和 issuer 参数编码参考 [Google Authenticator Key URI Format](https://github.com/google/google-authenticator/wiki/Key-Uri-Format)。本批没有增加验证码重放记录、尝试次数限制或服务器侧认证。

测试：[totp_util_test.dart](../../test/core/security/totp_util_test.dart)。

### GoPlus 风险查询与缓存

保留原有 `GoplusSecurityService` 静态调用入口，将传输和时间依赖放入可独立验证的 `GoplusSecurityClient`。默认实例继续由钱包发送页共享；没有新增依赖。

- 验证现有 10 个链映射、大小写归一化、不同链缓存隔离、非法合约地址与不支持链不发请求。
- 修复“响应只有一个合约时直接拿第一项”的回退：响应必须只有一个与请求地址大小写无关匹配的条目。其他合约的安全结果不能污染当前代币缓存；冲突的同地址重复项、空结果与损坏数据返回未知。
- 正常/危险结果缓存 5 分钟，在到期边界刷新；异常不缓存为安全结果，之后可以重试。
- 同一链/合约的并发请求复用一次在途传输，失败后解除占位；容量仍为 200 条，优先清理过期项，其次淘汰最旧四分之一。
- 验证缓存容量、过期清理、客户端实例隔离与异常重试。网络查询依旧采用既有 fail-open 策略：不可用返回 null，不阻断交易；null 不是安全评级。

请求路径与 `contract_addresses` 参数对应 [GoPlus Token Security API](https://docs.gopluslabs.io/reference/tokensecurityusingget_1)。测试在传输边界注入响应，没有访问 GoPlus 线上接口，也没有验证付费配额或服务可用性。

测试：[goplus_security_service_test.dart](../../test/core/security/goplus_security_service_test.dart)。

### 钓鱼警告及验证码绑定

- 钓鱼警告从嵌套 Navigator 打开时，原按钮关闭的是调用页所在的 Navigator，根对话框仍然存在；改为捕获显示对话框的根 Navigator。根/嵌套导航、返回/继续两种选择均有回归测试。
- 外部点击不会产生同意；系统返回得到 null；只有明确点击继续才得到 true。
- 320 × 640 视口、1.6 倍文字和长 URL 曾出现底部溢出，改为可滚动内容和可增高的按钮，保留安全返回入口。
- 验证 Google Authenticator 绑定页的 QR 展示、手动密钥展开/折叠、复制反馈、错误码停留、编辑清除错误、键盘提交、按钮验证成功返回密钥和取消返回 null。
- 修复手动密钥提示行的横向溢出；修复验证成功后重复确认继续 pop 后方页面的问题。

测试：[钓鱼警告](../../test/core/security/phishing_warning_dialog_test.dart)、[绑定页面](../../test/features/home/setting/security/google_auth_setup_page_test.dart)。绑定测试只生成临时测试密钥，不修改用户安全设置；还未覆盖设置页接收结果后的完整存储/解锁路径。

## UI 证据

在 320 × 640 逻辑像素、真实字体下生成并逐张检查，测试同时断言无布局异常。这些是可复查截图，不是像素差异 golden 基准。

| 显示 | 浅色 | 深色 |
|---|---|---|
| 正常文字 | [截图](../device-test-reports/evidence/2026-09-10-coverage-batch3/phishing-normal-light.png) | [截图](../device-test-reports/evidence/2026-09-10-coverage-batch3/phishing-normal-dark.png) |
| 1.6 倍文字 | [截图](../device-test-reports/evidence/2026-09-10-coverage-batch3/phishing-large-light.png) | [截图](../device-test-reports/evidence/2026-09-10-coverage-batch3/phishing-large-dark.png) |

## 复跑与范围说明

`security` 仍包含 `core/security/` 全部 18 个文件。新增 `security_setup` 包含 `home/setting/security/` 全部 4 个文件；本批重点是其中 Google Authenticator 页面，其他设置/手势文件的缺口保留在模块整体分母内。子文件达到高行覆盖率不代表整个安全设置模块已完成。

```sh
python3 scripts/module_coverage.py test security --baseline docs/testing/coverage-baseline-batch3-2026-09-10.json
python3 scripts/module_coverage.py test security_setup --baseline docs/testing/coverage-baseline-batch3-2026-09-10.json
ulimit -n 8192
flutter test --no-pub --coverage --concurrency=2
flutter analyze --no-pub --no-fatal-infos
python3 scripts/module_coverage.py report --baseline docs/testing/coverage-baseline-batch3-2026-09-10.json --output docs/testing/module-coverage-batch3-details-2026-09-10.md
python3 -m unittest discover -s test/scripts -p 'test_*.py'
python3 scripts/audit_feature_wiring.py --check
```

全项目结果仅使用完整 LCOV；分模块 trace 单独保存。不排除生成代码、不下调 70% CI 门槛。尚未完成设备安全 release/platform 分支、完整手势/生物识别/密码设置、真实服务端风险检测和实际钱包签名验证，详见全量文件明细与此前审计报告。临时日志在 `/tmp/n42-batch3-*.log`。
