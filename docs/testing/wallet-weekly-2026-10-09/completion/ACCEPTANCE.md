# 本次范围完结记录

日期：2026-10-10。范围：n42appv2 仓库内可实施、可自动化验证的当前钱包能力。

用户明确回复“这步跳过”：MoonPay sandbox、测试链/设备及真实用户对照的外部验收。本次不进行这些操作，不用本地假响应替代供应商或设备验收。商店/官网发布身份和安全文案未发布；未来 Agent、MPC/TEE、OEM、Headless、Swift/Kotlin 独立 SDK 和 EIP-7906 部署均不属于当前已交付能力。

## 完成项

| 原建议 | 实施结果 | 本地验收 |
|---|---|---|
| 账户信任边界 | PLAN 的模式、持钥、恢复与退出清单；Passkey 不等于可导出私钥。SocialRecoveryService 部署地址列表为空，不能宣传已部署社会恢复 | 代码路径核对；本地 backup/storage 回归 |
| 钱包账户恢复 | 无效miningIndex回退到选中钱包；仅在初始化账户归属已知且不同的情况下清空旧账户列表，保留新建/观察钱包 | 初次全仓3项失败已独立复现；修复后provider目录100项通过；最终全仓重跑记录见summary |
| Agent 权限/撤销边界 | 现有 Session Key 只有 SQLite 记录。管理页、创建页及保存/撤销结果明确说明本地记录不修改链上权限；26个ARB（含qps）及生成文件同步 | 管理/创建页面 Widget 回归；无链上策略承诺 |
| 错误链 | 缺失/非法 chain ID 拒绝；直连 RPC 的 eth_chainId 与配置必须一致才估算/签名 | loopback RPC 返回其他 chain ID 时，签名和广播均未发生 |
| 错误金额 | 精确整数传递；只有显式 sendMax 才扣减金额。固定金额在新费用下不足时拒绝，不减少用户批准金额 | 精确金额、gas预留、近余额固定金额与显式MAX测试 |
| gas/确认竞态 | 等待gas期间不能发送；金额、地址、备注、钱包、源地址和网络变更使本次确认失效 | 生产mixin与Widget的受控异步测试 |
| 重复提交/广播响应丢失 | 发送页signTx互斥；EVM广播前计算本地hash，先等待SQLite保存；保存失败不广播；本次确认一旦保存hash便不重新签名。RPC错误/外来hash保留本地hash并以Pending处理 | 保存前无广播、保存失败无广播、响应丢失只广播一次、原hash保留、重复signTx阻断 |
| 退出/重启恢复 | 广播前交易记录写入现有TransationRecord。离开页面不取消已授权的写入；启动既有selectUndoneTr读取原hash后查询receipt，不自动付款 | 实际文件SQLite关闭/重开，原hash可读；receipt查询没有第二次广播；账号隔离 |
| receipt错误/重组观察 | 错误文本/抛异常安全重试；丢弃旧请求和退出后的响应；成功null回到Pending；重新入块更新状态/区块；未知status/外来hash不判成功 | Widget receipt变化场景与真实本地HTTP解析 |
| 收据状态解析 | 直接RPC与旧后端envelope都处理pending/null/错误；合法status区分成功、失败；陌生hash/非法status返回未知 | 数据库恢复场景调用实际TransactionStateResolver |
| 连接/回连 | 保留Reown会话、namespace、请求关联、过期和回连原实现 | WalletConnect全目录回归；移动深链/桌面QR真实端到端按用户要求跳过 |
| 可重跑质量门 | verify_wallet_reliability.sh扩展sender、恢复、Session Key、确认竞态和receipt Widget测试，保存退出码、代码patch和source hash清单 | 脚本实际执行；全仓suite另跑，见summary.json |

## 证据限制

这不是全产品生产验收。SQLite重开和受控HTTP能证明当前调用顺序与正常磁盘提交后的恢复，不证明真机掉电、系统Keychain、真实共识最终性或支付厂商到账。假签名只用于本地fixture，从未广播到真实链。

广播不确定时宁可保留Pending，不自动签新nonce。明确拒绝与传输失败未作错误码白名单分类；无receipt并非付款失败证明，也不能删除记录后自动付款。幂等范围是当前确认操作和同一持久化hash；新页面发起另一笔相同金额的付款属于新意图，不实施按金额/地址的全局去重。DApp、AA、BTC等其它发送器尚不使用此EVM钱包页的beforeBroadcast钩子，不宣称全链持久化幂等已覆盖。

详情页Success是观察到status=1的receipt，不是finalized。页面12秒持续查询能纠正可见receipt变化；全局列表、索引事件和余额对真实重组的最终一致性，以及设备P95、跨设备密钥恢复、MoonPay订单闭环和用户完成率仍无实测证据，按用户本次指示排除，不标通过。RPC网络自报chain ID也不是对恶意节点的信任保证。

本次只保存交易hash和既有交易元数据，不保存私钥、助记词或可广播的签名字节。引入广播前数据库保存和一次eth_chainId查询，可能增加本地确认到提交的延迟；设备基线测量已排除。

## 提交与验证版本

实现分为 `1cd85a914`（广播持久化、网络/金额/账户保护）、`7b18d560b`（receipt状态与竞态）和 `4ab96f062`（本地Session Key披露）。英文提交标题在提交前已核对。仓库pre-commit依次将build自动递增到2.5.1+73016；没有构建或上传发布包。本次只创建本地提交，未推送。

首次全仓运行5471项通过、3项失败（退出码1），保留first-full-suite日志。修复后重新执行全仓；最终结果以summary.json、full-suite.log和实际退出码为准。

## 最终结果

全仓 5474 项通过、0失败，退出码0；扩展验收门 702 项通过，退出码0；全仓静态分析退出码0，48项info、0warning/error。格式检查、git diff --check和脚本bash -n通过。测试基于4ab96f062 / 2.5.1+73016；最终文档提交的hook仅继续递增build后缀，不改运行逻辑。未测全局coverage，不作70%覆盖率结论。

证据压缩包的未压缩SHA256、退出码、受测版本和实现提交均写入summary.json；source-sha256.json.gz记录源码与测试文件hash。前两轮验收记录保留为历史，本次以completion目录为最终结果。
