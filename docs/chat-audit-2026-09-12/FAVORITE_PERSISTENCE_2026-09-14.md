# 收藏持久化修复候选 — 2026-09-14

后续发布记录：本报告所述修复已于 2026-09-14 随 Chat [ebaa003](https://github.com/n42blockchain/n42_chat/commit/ebaa003b3dd882be9f951cb73c88633fa618f76c) 提交并推送；钱包随后已完成[依赖集成](WALLET_INTEGRATION_2026-09-14.md)。以下保留验证当时的状态与证据。

状态：正式 Chat 审计工作树中的本地修复，尚未提交或发布。钱包当前 Git pin 和缓存镜像仍为 `c1d222e3ea9c49a5f8bc51444154eb4026d689ef`，尚未包含本次修复。本报告不替换第五轮已交付基线。

## 问题与修复

`MessageActionRepositoryImpl.unsaveMessage` 原先先写收藏消息列表，再读取和清理另一条偏好设置中的标签、备注。元数据读取损坏或第二次写入被拒绝时，会出现界面报错但消息已删除的部分成功状态。两项回归在原实现上分别复现这两条路径。

候选实现将消息和元数据放进 `n42_chat_favorite_record` 的同一条 JSON 记录，包含 `version: 1`、`messages` 和 `metadata`。所有收藏修改只提交一次平台写入，成功后才更新两个内存缓存；加载也先完整解析两部分，再一起发布缓存。首次并发读取共用一个加载请求。

旧数据只读访问不会触发写入。首次成功修改迁移完整记录，并保留旧键；新记录存在时成为唯一读取来源，损坏或未知版本会报错，不回退到旧数据。这样不会因迁移中断丢弃旧记录，也不会在新版本重新打开时恢复已删除的收藏。旧键不提供降级同步。

真实 FavoriteBloc 的失败/重试回归确认：失败时列表保留原收藏，重试成功后才移除，并清除错误状态。此次无需修改页面或 Bloc 的生产代码。

## 验证

新增 18 项行为回归，覆盖单次删除写入、元数据损坏、迁移前后返回 false/抛错、从平台存储重新加载、保留旧键后的重新打开、未知/损坏版本、页面 Bloc 重试和初始并发读取。原有持久化用例的故障注入点改为整条记录写入，原有失败断言保留。

- 插件定向测试：200 项通过。
- 插件静态检查：0 错误、0 警告，173 条既有 info。
- 钱包候选兼容检查：393 项通过，包含现有 Chat/quality 检查及候选收藏测试。使用临时 package config 将 `n42_chat` 指向正式工作树；测试结束后已移除临时入口和配置。此结果验证候选源码的兼容性，不表示钱包正式依赖已经更新。
- 插件全量：6339 项通过、1 项跳过。原始行覆盖率 28718/131301（21.87%），包含生成代码。没有修改 CI 门槛。
- 全量结果及源码哈希见 [机器统计](favorite-persistence-2026-09-14/summary.json)。

命令：

```sh
# 正式 Chat 工作树
flutter analyze --no-pub --no-fatal-infos
ulimit -n 4096
flutter test --no-pub --coverage --concurrency=4 --reporter expanded
```

原进程的打开文件上限 256 在全量运行到 4,418 项时导致 `Too many open files`；中止该次测试后，仅提高新测试进程的上限重新运行，未修改系统设置或测试用例来绕过该错误。

## 证据与交付范围

证据目录：`favorite-persistence-2026-09-14/`，保留旧实现失败日志、定向/全量测试日志、静态检查、宿主候选日志和完整 lcov。

正式源码工作树：`../n42_chat_audit_20260912`；修改文件为：

- `lib/src/data/datasources/local/preferences_datasource.dart`
- `lib/src/data/repositories/message_action_repository_impl.dart`
- `test/unit/repositories/message_action_persistence_test.dart`
- `test/unit/repositories/favorite_record_persistence_test.dart`
- `OPEN_ISSUES.md`

`STORAGE-001` 台账标记为本地已修复、等待集成。下一步为发布经验证的插件版本，再更新钱包 Git pin、锁文件和缓存镜像。`UI-001` 的收藏标签/备注界面入口问题仍独立开放。

测试使用合成消息和模拟平台存储，重建偏好设置缓存来验证保存结果，不是手机进程强杀或断电测试。SharedPreferences 的物理落盘保证、跨 isolate 锁没有在本次建立，也没有进行真机安装、线上消息或真实账户操作。
